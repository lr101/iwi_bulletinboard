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
  static Future<List<Announcement>> fetchAnnouncements() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currentSetting = prefs.getStringList('setting') ?? ["INFB"];
    Set<int> uniqueIds = {};
    List<Announcement> members = [];
    for (String setting  in currentSetting) {
      Response response = await RestAPI.createHttpsRequest(
          "/iwii/REST/newsbulletinboard/$setting", {}, 0);
      if (response.statusCode == 200) {
        List<dynamic> values = json.decode(response.body);
        for (dynamic d in values) {
          Announcement announcement = Announcement.fromJson(d);
          if (!uniqueIds.contains(announcement.id)) {
            members.add(announcement);
          }
        }

      }
    }
    return members;
  }

}