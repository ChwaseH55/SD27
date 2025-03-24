import 'dart:developer';

import 'package:coffee_card/main.dart';
import 'package:coffee_card/screens/listofevents_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Notifications.intsance.setupFlutterNotifications();
  await Notifications.intsance.showNotification(message);
}

class Notifications {
  Notifications._();
  static final Notifications intsance = Notifications._();

  final _messaging = FirebaseMessaging.instance;
  final localNotification = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

Future<void> initialize() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permission
  await _requestPermission();

  // Setup message handlers
  await _setupMessageHandlers();
  await setupFlutterNotifications();
  final token = await _messaging.getToken();
  log('FCM Token: $token');
  subscribeToTopic('all_devices');
}

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    log('Permission status: ${settings.authorizationStatus}');
  }  

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) return;

    //android
    const channel = AndroidNotificationChannel(
        'high_importance_channel', 'High Importance Notification',
        description: 'This channel is used for important notifications',
        importance: Importance.high);

    await localNotification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    //ios
    // final initializationSettingsDarwin = DarwinInitializationSettings(
    //   onDidReceiveLocalNotification: (id, title, body, payload) async {

    //   },
    // );

    const initializationSettings = InitializationSettings(
      android: initializationSettingAndroid,
    );

    //flutter notification setup
    await localNotification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) =>
      _handleBackgroundMessage(details.payload!),
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['type'].toString(),
      );
    }
  }

 Future<void> _setupMessageHandlers() async {
  //foreground message
  FirebaseMessaging.onMessage.listen((message) {
    showNotification(message);
  });

  //background message
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    _handleBackgroundMessage(message.data['type']);
  });

  //opened app
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleBackgroundMessage(initialMessage.data['type']);
  }
}

void _handleBackgroundMessage(String message) {
  if(message == 'events') {
    //open thing
    navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => const EventsListScreen(),
            ));
  }
}
Future<void> subscribeToTopic(String topic) async {
  await FirebaseMessaging.instance.subscribeToTopic(topic);
  log("Subscribed to $topic");
}
}
