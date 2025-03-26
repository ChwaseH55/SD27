import 'dart:convert';
import 'dart:developer';

import 'package:coffee_card/arguments/eventsargument.dart';
import 'package:coffee_card/arguments/regOrAllargument.dart';
import 'package:coffee_card/main.dart';
import 'package:coffee_card/screens/event_info.dart';
import 'package:coffee_card/screens/listofevents_screen.dart';
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
    //open thing
    navigatorKey.currentState?.pushNamed(
      EventInfo.routeName,
      arguments: EventsArgument(int.parse(type)),
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    log("Subscribed to $topic");
  }

  Future<void> sendNotification(String title, String body, String type) async {
    String accessToken =
        'ya29.c.c0ASRK0GZsNl0Nr8rSB59JweXbqB3XIlhW-Op5f-ZVnC8bX2eqGj5Hpk5zojsvYPg2cfRBBkGijnsx1-m1rFK1gR-YtEO4PY9uW5TMq4RrRqYDfWdvnShSTHpbb1lJSKijUt5QuTSb-7XnK78mZ7xFfF_DzD_8aOEWKcUjQkZFB76hJva5KWMjHu3-e86w-HBfHs6ZyTQv8dNae95qd261h1t_IkgeNu7Jyt86IDGmilL0wAgegrPsI4V6HD724r22nf96izAiNA_XIOVIGRQRmvXqvxQlZdERIVZd2u2YzjDZpBVt11ISI0h-Eu6M9DHV9n-vW__51kIELSLf5QmF_FhYtvTo_ANIiS7jgw822dF6lfSza1dokREH384Phhmkb6tbFnrhj_9huOe6bOZZI_8_0x6U1f3Z33ebJ_OxyUamnUqiayUfdnhqFbtce0QlklhW1mmOzObvzWR0eiY83x0Oen_q8cvYivJpY9B9x3x6lVUz2Xzz36veSVe7lidvRn2ZJj_zlm0qRjF9fbkxZUUvpe607UVOvyXlihgFJo5BmymnZsZB0oQjgva_eosvxYo-foonWeaaZR3B2VacfxuynJ69ldkMlsn3l3SmnyOoujR8idcvSWdm2k3Q7ZXlvq8zWISxYJ5YR51jJs-6xwVc57vpt0MfuQU8WIj_4YfIdbBMghvXkrsjQelneaj-B7dyenU6diwVxwg3z5F2wzVV39npWcnt7y4hWXF_8blVmmFMZ5l0X3mubBOpo5Raajx6rJzR-OtpaqQ5YQkrl2Yds-uFlYewWXuirz4jeOFx3z4rqYBJuRFbxWM0W7V5ZhtmujJXOZvjyi1R7Q-qxpn-xeWSdy9S-56r4JXvot2VIW3wBQfwqbZ16IBfSxkxqlnbmrX3IBQZMSFS-nb4_b_SBfx2SUfde_BfR1jjXFo70Sf0fg5fc2ypfVUzdohnR937di0UozxvgJ8UbyaXOXpW3nWrO0IktkJa2kklt6a2Bfg-JsdvhSJ';
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
