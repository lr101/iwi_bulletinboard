import 'dart:convert';

import 'package:http/http.dart';
import 'package:iwi_bulletinboard/api/rest_api.dart';
import 'package:iwi_bulletinboard/entity/announcement.dart';
import 'package:shared_preferences/shared_preferences.dart';
class FetchNews {

  /// returns a list of members and the amount of points they have of a specific [group]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<List<Announcement>> fetchAnnouncements(String topic) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Announcement> members = [];
    Response response = await RestAPI.createHttpsRequest("/iwii/REST/newsbulletinboard/$topic", {}, 0);
    if (response.statusCode == 200) {
      List<dynamic> values = json.decode(response.body);
      for (dynamic d in values) {
        Announcement announcement = Announcement.fromJson(d);
        members.add(announcement);
      }
    }
    return members;
  }

}