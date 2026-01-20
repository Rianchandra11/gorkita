import 'package:http/http.dart' as http;
import 'package:uts_backend/helper/base_url.dart';
import 'dart:convert';
import 'package:uts_backend/model/sql_model/notification_model.dart';

class NotificationRepository {
  static Future<List<NotificationModel>> getAll() async {
    final String pathName = "/notif";
    try {
      var response = await http.get(Uri.parse("${BaseUrl.url}$pathName"));
      List<dynamic> result = jsonDecode(response.body)['data'];
      await Future.delayed(Duration(seconds: 1));
      return result.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteById(int id) async {
    final String pathName = "/notif/delete/$id";
    try {
      var response = await http.delete(Uri.parse("${BaseUrl.url}$pathName"));
      print(response.body);
    } catch (e) {
      rethrow;
    }
  }
}
