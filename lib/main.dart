import 'dart:convert';
import 'package:iwi_bulletinboard/widgets/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iwi_bulletinboard/api/fetch_news.dart';
import 'package:iwi_bulletinboard/api/rest_api.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:background_fetch/background_fetch.dart';
import 'entity/announcement.dart';
import 'util/notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher(HeadlessTask task)  async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  try {
    await callNotification();
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
  // Do your work here...
  BackgroundFetch.finish(taskId);
}

Future<void> callNotification() async {
  for (Announcement newNews in await Announcement.getNewElements()) {
    await NotificationService().showLocalNotification(
        id: newNews.id,
        title: newNews.title,
        body: newNews.subTitle,
        payload: newNews.content
    );
  }
}

Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundFetch.registerHeadlessTask(callbackDispatcher);
  await NotificationService().initializePlatformNotifications();
  tz.initializeTimeZones();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IWI Schwarzes Brett',
      theme: ThemeData( brightness: MediaQueryData.fromView(PlatformDispatcher.instance.views.first).platformBrightness),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}


