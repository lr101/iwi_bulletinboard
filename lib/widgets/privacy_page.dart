import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datenschutzverordnung'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Datenschutzverordnung für die App "IWI News"\n\n'
              '1. Einleitung\n'
              'Diese Datenschutzverordnung regelt die Verarbeitung von personenbezogenen Daten durch die App "IWI News" (im Folgenden "App"). Alle gezeigten Texte sind allgemein zugänglich und unterliegen des Urheberrechts der Hochschule Karlsruhe – Technik und Wirtschaft. Siehe dazu die folgende Internetseite sein \'https://intranet.hka-iwi.de/iwii/info/dataprotection\'. \n\n'
              '2. Keine Datensammlung\n'
              'Die App sammelt oder speichert keine personenbezogenen Daten der Nutzer. Dies umfasst, ist aber nicht beschränkt auf, Namen, Adressen, Telefonnummern, E-Mail-Adressen und Standortdaten.\n\n'
              '3. Zugriff auf Benachrichtigungen\n'
              'Um Nutzer über aktuelle News und Updates zu informieren, benötigt die App Zugriff auf die Benachrichtigungsfunktionen des Geräts. Die App wird diesen Zugriff ausschließlich verwenden, um relevante Informationen und News-Updates zu senden. Keine Informationen aus diesen Benachrichtigungen werden gespeichert oder weiterverarbeitet.\n\n'
              '4. Hintergrundaktivität\n'
              'Die App benötigt die Berechtigung zur Durchführung von Hintergrundaktivitäten, um neue Inhalte zu laden und die Nutzer über Änderungen und Updates zu informieren. Diese Aktivitäten beinhalten keine Verarbeitung personenbezogener Daten.\n\n'
              '5. Datensicherheit\n'
              'Obwohl keine personenbezogenen Daten gesammelt werden, verpflichtet sich die App zur Einhaltung hoher Sicherheitsstandards, um die Integrität und Vertraulichkeit der App-Funktionalitäten zu gewährleisten.\n\n'
              '6. Änderungen an der Datenschutzverordnung\n'
              'Diese Datenschutzverordnung kann von Zeit zu Zeit aktualisiert werden. Nutzer werden über wesentliche Änderungen informiert, und die aktuellste Version ist stets innerhalb der App einsehbar.\n\n'
              '7. Zustimmung\n'
              'Durch die Nutzung der App stimmen die Nutzer den Bedingungen dieser Datenschutzverordnung zu. Falls die Nutzer den Bedingungen nicht zustimmen, sollten sie die App nicht verwenden.\n\n'
              '8. Kontakt\n'
              'Bei Fragen oder Anliegen bezüglich dieser Datenschutzverordnung können sich Nutzer über die in der App bereitgestellten Kontaktinformationen (info@lr-projects.de) an den Datenschutzbeauftragten wenden.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
