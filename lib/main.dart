import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iwi_bulletinboard/widgets/home_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
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


