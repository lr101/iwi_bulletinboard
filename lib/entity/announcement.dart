
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/fetch_news.dart';

class Announcement implements Comparable<Announcement> {
  String content;
  List<String> coursesOfStudy;
  DateTime expirationDate;
  int id;
  String creator;
  DateTime publicationTimestamp;
  String title;

  Announcement({
    required this.content,
    required this.coursesOfStudy,
    required this.expirationDate,
    required this.id,
    required this.creator,
    required this.publicationTimestamp,
    required this.title,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      content: json['content'] as String,
      coursesOfStudy: List<String>.from(json['coursesOfStudy']),
      expirationDate: DateTime.parse(json['expirationDate']),
      id: json['id'],
      creator: json['creator'],
      publicationTimestamp: DateTime.parse(json['publicationTimestamp']),
      title: json['title'] as String,
    );
  }

  factory Announcement.fromJsonREST(Map<String, dynamic> json) {
    return Announcement(
      content: json['content'] is String ? utf8.decode((json['content'] as String).codeUnits, allowMalformed: true) : "",
      coursesOfStudy: List<String>.from(json['coursesOfStudy']),
      expirationDate: DateTime.parse(json['expirationDate']),
      id: json['id'],
      creator: json['creator'],
      publicationTimestamp: DateTime.parse(json['publicationTimestamp']),
      title: json['title'] is String ? utf8.decode((json['title'] as String).codeUnits, allowMalformed: true) : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'coursesOfStudy': coursesOfStudy,
      'expirationDate': expirationDate.toIso8601String(),
      'id': id,
      'creator': creator,
      'publicationTimestamp': publicationTimestamp.toIso8601String(),
      'title':  title,
    };
  }

  @override
  int compareTo(Announcement other) {
      return this.id - other.id;
  }

  static Future<List<Announcement>> getNewElements(String topic) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload();
    List<Announcement> savedList = prefs.getStringList("announcements")?.map((e) => Announcement.fromJson(json.decode((e)))).toList()  ?? [];
    try {
      List<Announcement> newList = await FetchNews.fetchAnnouncements(topic);
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
