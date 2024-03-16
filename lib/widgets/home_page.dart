import 'dart:convert';
import 'package:iwi_bulletinboard/widgets/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:iwi_bulletinboard/api/fetch_news.dart';
import 'package:iwi_bulletinboard/api/rest_api.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:background_fetch/background_fetch.dart';
import '../entity/announcement.dart';
import '../util/notification_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver  {
  List<Announcement> list = [];
  List<String> schwarzesBrett = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>  _refreshAll());
    _requestPermission(); // Request for alert permission
    WidgetsBinding.instance.addObserver(this); // Observer for detecting when the app is opened (via a notification)
    _initPlatformState(); // Register background task
  }


  Future<void> _initPlatformState([int? fetchInterval]) async {
    final prefs = await SharedPreferences.getInstance();
    if (fetchInterval == null) {
      fetchInterval = prefs.getInt("interval") ?? 15;
    } else {
      prefs.setInt("interval", fetchInterval);
    }

    await BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: fetchInterval,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY
    ), (String taskId) async {  // <-- Event handler
      _refreshAll();
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {  // <-- Task timeout handler.
      print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    if (!mounted) return;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _requestPermission() async {
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
  }

  Future<void> _refreshAll() async {
    await _loadSettings();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    this.list = await FetchNews.fetchAnnouncements();
    this.list.removeWhere((element) => element.publicationDate.isBefore(DateTime.now().subtract(Duration(days: 60))));
    setState(() {});
    prefs.setStringList("announcements", list.map((e) => json.encode(e.toJson())).toList());
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    schwarzesBrett = prefs.getStringList("setting") ?? ["INFB"];
    if (schwarzesBrett.isEmpty) {
      schwarzesBrett = ["INFB"];
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
                  onSchwarzesBrettChanged: (List<String> newSetting) {
                    setState(() {
                      schwarzesBrett = newSetting;
                      _refreshAll(); // Update the main page with new settings
                    });
                  },
                  onIntervalChanged: (int) {
                    _initPlatformState(int);
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