import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iwi_bulletinboard/widgets/privacy_page.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.schwarzesBrett, required this.onSchwarzesBrettChanged, required this.interval});

  final String schwarzesBrett;
  final int interval;
  final Function(String newSetting) onSchwarzesBrettChanged;

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
            ],
          ),
        ],
      ),
    );
  }


  Future<void> _showSettingsDialog(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Studiengänge:'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <String>['INFB', 'INFM', 'MINB', 'MKIB'].map((String setting) {
                return RadioListTile<String>(
                  title: Text(setting),
                  value: setting,
                  groupValue: courses,
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