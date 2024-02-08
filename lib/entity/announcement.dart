
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/fetch_news.dart';

class Announcement implements Comparable<Announcement> {
  bool changed;
  String content;
  List<String> courseOfStudies;
  bool deleteOnExpiration;
  String emailOwner;
  DateTime expirationDate;
  int id;
  int idOwner;
  String nameOwner;
  DateTime publicationDate;
  DateTime publicationTimestamp;
  bool studentCouncil;
  String subTitle;
  String title;
  String type;

  Announcement({
    required this.changed,
    required this.content,
    required this.courseOfStudies,
    required this.deleteOnExpiration,
    required this.emailOwner,
    required this.expirationDate,
    required this.id,
    required this.idOwner,
    required this.nameOwner,
    required this.publicationDate,
    required this.publicationTimestamp,
    required this.studentCouncil,
    required this.subTitle,
    required this.title,
    required this.type,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      changed: json['changed'],
      content: json['content'],
      courseOfStudies: List<String>.from(json['courseOfStudies']),
      deleteOnExpiration: json['deleteOnExpiration'],
      emailOwner: json['emailOwner'],
      expirationDate: DateTime.parse(json['expirationDate']),
      id: json['id'],
      idOwner: json['idOwner'],
      nameOwner: json['nameOwner'],
      publicationDate: DateTime.parse(json['publicationDate']),
      publicationTimestamp: DateTime.parse(json['publicationTimestamp']),
      studentCouncil: json['studentCouncil'],
      subTitle: json['subTitle'],
      title: json['title'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'changed': changed,
      'content': content,
      'courseOfStudies': courseOfStudies,
      'deleteOnExpiration': deleteOnExpiration,
      'emailOwner': emailOwner,
      'expirationDate': expirationDate.toIso8601String(),
      'id': id,
      'idOwner': idOwner,
      'nameOwner': nameOwner,
      'publicationDate': publicationDate.toIso8601String(),
      'publicationTimestamp': publicationTimestamp.toIso8601String(),
      'studentCouncil': studentCouncil,
      'subTitle': subTitle,
      'title': title,
      'type': type,
    };
  }

  @override
  int compareTo(Announcement other) {
      return this.id - other.id;
  }

  static Future<List<Announcement>> getNewElements() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload();
    List<Announcement> savedList = prefs.getStringList("announcements")?.map((e) => Announcement.fromJson(json.decode((e)))).toList()  ?? [];
    try {
      List<Announcement> newList = await FetchNews.fetchAnnouncements(true);
      if (newList.isNotEmpty) {
        List<Announcement> newElements = newList.where((e) => !savedList.any((a) => a.id == e.id)).toList();
        savedList.addAll(newElements);
        await prefs.setStringList("announcements", savedList.map((e) => json.encode(e.toJson())).toList());
      }
      return newList;
    } catch(_) {
      return [];
    }
  }


}
