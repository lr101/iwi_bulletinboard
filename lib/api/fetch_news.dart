import 'dart:convert';

import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:iwi_bulletinboard/api/rest_api.dart';
import 'package:iwi_bulletinboard/entity/announcement.dart';
import 'package:shared_preferences/shared_preferences.dart';
class FetchNews {

  /// returns a list of members and the amount of points they have of a specific [group]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<List<Announcement>> fetchAnnouncements([bool withFrom = false]) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentSetting = prefs.getString('setting') ?? "INFB";
    Map<String, String> query = {};
    if (withFrom) {
      DateTime now = DateTime.now();
      query["from"] = DateFormat('yyyy-MM-dd').format(now);;
    }
    Response response = await RestAPI.createHttpsRequest("/iwii/REST/newsbulletinboard/$currentSetting" , {}, 0);
    if (response.statusCode == 200) {
      List<Announcement> members = [];
      List<dynamic> values = json.decode(response.body);
      for (dynamic d in values) {
        members.add(Announcement.fromJson(d));
      }
      return members;
    } else {
      throw Exception("Could not be loaded");
    }
  }

}