import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iwi_bulletinboard/widgets/privacy_page.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.schwarzesBrett, required this.onSchwarzesBrettChanged, required this.onIntervalChanged, required this.interval});

  final String schwarzesBrett;
  final int interval;
  final Function(String) onSchwarzesBrettChanged;
  final Function(int) onIntervalChanged;

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {

  late String courses;
  late int interval;

  @override
  void initState() {
    super.initState();
    courses = widget.schwarzesBrett;
    interval = widget.interval;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Über die Inhalte'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.person),
                title: Text('Urheber aller gezeigten Inhalte'),
                value: Text("Hochschule Karlsruhe – Technik und Wirtschaft"),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text('Datenschutzerklärung des Urhebers'),
                onPressed: (_) =>
                    launchUrl(Uri.parse(
                        "https://intranet.hka-iwi.de/iwii/info/dataprotection")),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Über die App'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.email_outlined),
                title: Text('Kontakt'),
                onPressed: (_) =>
                    Clipboard.setData(
                        ClipboardData(text: "lr.dev.projects@gmail.com")).then((
                        _) =>
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Email copied to clipboard")))
                    ),
                value: Text("lr.dev.projects@gmail.com"),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text('Datenschutzerklärung'),
                onPressed: (_) =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PrivacyPage()),
                    ),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Anpassungen'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.newspaper_outlined),
                title: Text("Studiengang"),
                value: Text(courses),
                description: Text("Das schwarze Brett des st"),
                onPressed: (_) => _showSettingsDialog(context),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.timelapse_outlined),
                title: Text('Aktualisierungsintervall'),
                value: Text(interval.toString() + " Minuten"),
                onPressed: (_) => _showIntervalDialog(context),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.notifications),
                title: Text('Push-Benachrichtigung'),
                value: Text("Drücken zum Testen"),
                onPressed: (_) {
                  NotificationService().showLocalNotification(
                      id: 1,
                      title: "Test-Benachrichtigung",
                      body: "Subtitel",
                      payload: "Dies ist der Testinhalt"
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }



  void _showIntervalDialog(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final TextEditingController _controller = TextEditingController();
    _controller.text = prefs.getInt("interval")?.toString() ?? "15";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aktualisierungsintervall'),
          content: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Minuten (>= 15)',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Speichern'),
              onPressed: () {
                int value = int.tryParse(_controller.text) ?? 0;
                if (value >= 15) {
                  widget.onIntervalChanged(value);
                  setState(() {
                    interval = value;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bitte einen Wert >= 15 eingeben'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
                  groupValue: widget.schwarzesBrett,
                  onChanged: (String? value) {
                    if (value != null) {
                      prefs.setString('setting', value);
                      setState(() {
                        courses = value;
                      });
                      widget.onSchwarzesBrettChanged(value);
                    }
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