
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService();

  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const String channelId = "newsId";
  static const String channelName = 'news';
  static const String groupKey = 'com.lrprojects.iwi_bulletinboard';
  static const String channelDescription = 'All news are displayed here';

  Future<void> initializePlatformNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_stat_iwiwhite');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );



    await _localNotifications.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
        onDidReceiveBackgroundNotificationResponse:
        onDidReceiveBackgroundNotificationResponse);

    AndroidNotificationChannelGroup channelGroup = AndroidNotificationChannelGroup('com.lrprojects.iwi_bulletinboard.alert1', 'news');
    await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannelGroup(channelGroup);
  }

  void onDidReceiveLocalNotification(NotificationResponse? response) {
    var data = response?.payload.toString();
  }

  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse? response) {
    var data = response?.payload.toString();
    print("onDidReceiveBackgroundNotificationResponse");
    print(data);
  }

  // void selectNotification(String? payload) {
  //   if (payload != null && payload.isNotEmpty) {}
  // }

  Future<NotificationDetails> _notificationDetails() async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    const AndroidNotificationDetails(
      channelId,
      channelName,
      groupKey: groupKey,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      color: Color(0xffffffff),
    );

    final details = await _localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {}
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    return platformChannelSpecifics;
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> showScheduledLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required int seconds,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
      platformChannelSpecifics,
      payload: payload,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> showPeriodicLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.everyMinute,
      platformChannelSpecifics,
      payload: payload,
      androidAllowWhileIdle: true,
    );
  }
}
