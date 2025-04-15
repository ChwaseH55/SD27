import 'dart:convert';
import 'dart:developer';

import 'package:coffee_card/arguments/announcementargument.dart';
import 'package:coffee_card/arguments/eventsargument.dart';
import 'package:coffee_card/arguments/regOrAllargument.dart';
import 'package:coffee_card/main.dart';
import 'package:coffee_card/screens/announcement_info.dart';
import 'package:coffee_card/screens/event_info.dart';
import 'package:coffee_card/screens/listofevents_screen.dart';
import 'package:coffee_card/widgets/slideRightTransition.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

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

  void _handleBackgroundMessage(String type) {
    List<String> parts = type.split(':');

// Storing values in separate variables
    String topic = parts[0]; // "event"
    String value = parts.length > 1 ? parts[1] : ''; // res.eventid.toString()
    //open thing
    if (topic == 'events') {
      navigatorKey.currentState?.pushNamed(
        EventInfo.routeName,
        arguments: EventsArgument(int.parse(value)),
      );
    } else if (topic == 'announcements') {
      navigatorKey.currentState
          ?.push(slideRightRoute(AnnouncementInfo(id: value)));
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    log("Subscribed to $topic");
  }

  Future<void> sendNotification(String title, String body, String type) async {
    String accessToken =
        'ya29.c.c0ASRK0GbsBm7AvxEAS8GGcQgb-_mrsDtRUVjOB1JhfHuO4je_55bNncx4hLAaf8JcT0m-zK3Q3BECUAx9qAkNTDM22v43bE5qLK4Rm5wqQcHsVYzozVxrvbWYC7d0nB7IrxIf1oI-JiKzmhYUCoPxOQDyuFoJxF_OtufNNvrdp7cs9CrNTVHjYZY9f1WNb1m877kUbVgYooPR9FZ1J-pnOOh94PQH2rAxOfKdywHMArJwDdSYatWdPCTHy535FT0ktkJDndV-X9bier6Ut44qTC30vyCCPa6-ON01lw1ErBzmdNTsB1hQOF8NwZUqti6IGtMipWDylJ_bI8wRqrLfG1iD_P30tkgCAFp0ky8fgj_qawfu2rdxjv8elQE387CVbrMi9OWw52Imy32s6jfUY-dc5kxFlfMx9v7qBgWV_xWlU8MgiakUj3eeXedrn-BO50plVhBzVwvj5rRgsX7M5rsQvsRoschdReQdiWSw34WdzwdSmh1OSdW94BJhmYh8pgtfvJXieWmn0q5f1i0gkzm3xk034R0rVOI1m2mhW75UZnz16fI7M8Q6WX348ysq2aR2jFVttxOiOFiRig3u6x-l1Xrivwz1erdf87satqzfzc_qi3J7muSgS28wFyyay1V0xIdWIs-FROU5UxuQXiV7c1mziBg9rOVi6rZJq--M971xFvlXg9bZI84Qur27gjI20YvhpzwzdSz8Z_x_11yqF491tb2h63j-YU2WxhqwIooogIW39qw81X70f7g79zkqW9v7-_dVU-ooiZMm017lBJ-b2JbvOeXZX8jlgrr8v8W0c110IOJ0ghRm_i8e7fMUY5yOqYwamyaBhf7X58nhYtxel_-nnl8OWM7Xiyssz11kjVu8qYMcn-1X0qVJy2axtzWxehQp4w2fwjXUzbM6hJquV3c9bVtFmp0nov42t8s2rc11hpUz2UWoV8Fg903_Q9z48rtJ0x7Szueeua_c6JeMBrUxlQiggjf54m07JqXbUWqlt6U';
    var messagePayload = {
      'message': {
        'topic': "all_devices",
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'type': type, // Used for navigation
        },
        'android': {
          'priority': "high",
          'notification': {
            'channel_id': "high_importance_channel",
          },
        },
      },
    };
    const url =
        "https://fcm.googleapis.com/v1/projects/sd27-87d55/messages:send";

    final headers = {
      'Authorization': 'Bearer $accessToken',
      "Content-Type": "application/json",
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(messagePayload));
    if (response.statusCode == 200) {
      log('Notification sent successfully:${response.body}');
    } else {
      log('Error sending Notifications: ${response.body}');
    }
  }
}
