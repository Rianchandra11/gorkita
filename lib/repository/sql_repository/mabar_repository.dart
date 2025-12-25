import 'package:http/http.dart' as http;
import 'package:uts_backend/helper/base_url.dart';
import 'dart:convert';

import 'package:uts_backend/model/sql_model/mabar_model.dart';

class MabarRepository {
  static Future<List<MabarModel>> getAll() async {
    final String pathName = "/display/mabar";
    try {
      var response = await http.get(Uri.parse("${BaseUrl.url}$pathName"));
      List<dynamic> result = jsonDecode(response.body)['data'];
      await Future.delayed(Duration(seconds: 1));
      return result.map((e) => MabarModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
