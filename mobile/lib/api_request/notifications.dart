import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
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
  final token = await _messaging.getToken();
  log('FCM Token: $token');
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
        AndroidInitializationSettings('@mipamp/ic_launcher');

    //ios
    // final initializationSettingsDarwin = DarwinInitializationSettings(
    //   onDidReceiveLocalNotification: (id, title, body, payload) async {

    //   },
    // );

    final initializationSettings = InitializationSettings(
      android: initializationSettingAndroid,
    );

    //flutter notification setup
    await localNotification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
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
        NotificationDetails(
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
        payload: message.data.toString(),
      );
    }
  }

 Future<void> _setupMessageHandlers() async {
  //foreground message
  FirebaseMessaging.onMessage.listen((message) {
    showNotification(message);
  });

  //background message
  FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

  //opened app
  final initialMessage = await _messaging.getInitialMessage();
  if (initialMessage != null) {
    _handleBackgroundMessage(initialMessage);
  }
}

void _handleBackgroundMessage(RemoteMessage message) {
  if(message.data['type'] == 'chat') {
    //open thing
  }
}
}
