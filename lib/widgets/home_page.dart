import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iwi_bulletinboard/api/fetch_news.dart';
import 'package:iwi_bulletinboard/widgets/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entity/announcement.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver  {

  static const DEFAULT_TOPIC = "INFM";

  List<Announcement> list = [];
  String schwarzesBrett = DEFAULT_TOPIC;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>  _refreshAll());
    _requestPermission(); // Request for alert permission
    WidgetsBinding.instance.addObserver(this); // Observer for detecting when the app is opened (via a notification)
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _refreshAll() async {
    await _loadSettings();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    this.list = await FetchNews.fetchAnnouncements(schwarzesBrett);
    this.list.removeWhere((element) => element.publicationDate.isBefore(DateTime.now().subtract(Duration(days: 60))));
    setState(() {});
    prefs.setStringList("announcements", list.map((e) => json.encode(e.toJson())).toList());
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("setting") == null) {
      schwarzesBrett = DEFAULT_TOPIC;
      await FirebaseMessaging.instance.subscribeToTopic(schwarzesBrett);
      prefs.setString("setting", DEFAULT_TOPIC);
    } else {
      schwarzesBrett = prefs.getString("setting")!;
    }
  }

  bool isNewDay(int index) {
    if (index == 0) {
      return true; // Always show the date for the first item
    }
    DateTime prevDate = list[index - 1].publicationDate;
    DateTime currDate = list[index].publicationDate;
    return DateFormat('yyyy-MM-dd').format(prevDate) != DateFormat('yyyy-MM-dd').format(currDate);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAll();
    }
  }

  Future<void> updateTopics(String newSettings) async {
    print("Subscribing to:" + newSettings);
    await FirebaseMessaging.instance.subscribeToTopic(newSettings);
    print("Unsubscribing from:" + schwarzesBrett);
    await FirebaseMessaging.instance.unsubscribeFromTopic(schwarzesBrett);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(100, 55, 140, 1.0),
        title: Text("Schwarzes Brett"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              int interval =( await  SharedPreferences.getInstance()).getInt("interval") ?? 15;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(
                  schwarzesBrett: schwarzesBrett,
                  interval: interval,
                  onSchwarzesBrettChanged: (String newSetting) {
                    updateTopics(newSetting);
                    setState(() {
                      schwarzesBrett = newSetting;
                      _refreshAll(); // Update the main page with new settings
                    });
                  },
                )),
              );}
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (isNewDay(index))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DateFormat('dd.MM.yyyy').format(list[index].publicationDate),
                      style: const TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
                    ),
                  ),
                Card(
                  margin: const EdgeInsets.all(8.0),

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SelectableText(
                          list[index].title,
                          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SelectableText(
                          list[index].subTitle,
                          style: const TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          list[index].content,
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          "~ " + list[index].nameOwner,
                          style: const TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 5),
                        SelectableText(
                          "~ published in: " + list[index].courseOfStudies.join(", "),
                          style: const TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "2",
            onPressed: _refreshAll, // Refresh action
            tooltip: 'Refresh',
            backgroundColor: const Color.fromRGBO(100, 55, 140, 1.0),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }


}