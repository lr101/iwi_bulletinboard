import 'dart:convert';
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
  String schwarzesBrett = "";

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _refreshAll(); // Load announcements when the widget is first created
    _requestPermission(); // Request for alert permission
    WidgetsBinding.instance.addObserver(this); // Observer for detecting when the app is opened (via a notification)
    initPlatformState(); // Register background task
  }


  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    await BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY
    ), (String taskId) async {  // <-- Event handler
      _refresh();
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    this.list = await FetchNews.fetchAnnouncements();
    setState(() {});
    prefs.setStringList("announcements", list.map((e) => json.encode(e.toJson())).toList());
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    schwarzesBrett = prefs.getString("setting") ?? "INFB";
  }


  Future<void> _refresh() async {
    list.addAll(await Announcement.getNewElements());
    setState(() {});
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
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromRGBO(100, 55, 140, 1.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$schwarzesBrett Schwarzes Brett"),
              IconButton(onPressed: () => launchUrl(Uri.parse("https://intranet.hka-iwi.de/iwii/info/dataprotection")), icon: Icon(Icons.info_outline))
            ],
          )
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
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

                          utf8.decode(list[index].title.codeUnits),
                          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SelectableText(
                          utf8.decode(list[index].subTitle.codeUnits),
                          style: const TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          utf8.decode(list[index].content.codeUnits),
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          utf8.decode(("~ " + list[index].nameOwner).codeUnits),
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
            onPressed: _showSettingsDialog, // Open settings dialog
            tooltip: 'Settings',
            backgroundColor: const Color.fromRGBO(100, 55, 140, 1.0),
            child: const Icon(Icons.settings),
          ),
          const SizedBox(height: 10), // Spacing between the buttons
          FloatingActionButton(
            onPressed: _refresh, // Refresh action
            tooltip: 'Refresh',
            backgroundColor: const Color.fromRGBO(100, 55, 140, 1.0),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Future<void> _showSettingsDialog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Studiengang:'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <String>['INFB', 'INFM', 'MINB', 'MKIB']
                  .map((String setting) {
                return RadioListTile<String>(
                  title: Text(setting),
                  value: setting,
                  groupValue: schwarzesBrett,
                  onChanged: (String? value) {
                    setState(() {
                      if (value != null) {
                        schwarzesBrett = value;
                        prefs.setString('setting', value);
                        _refresh();
                      }
                    });
                    Navigator.of(context).pop(); // Close the dialog
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }



}