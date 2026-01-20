import 'package:http/http.dart' as http;
import 'package:uts_backend/helper/base_url.dart';
import 'dart:convert';

import 'package:uts_backend/model/sql_model/jadwal_model.dart';

class JadwalRepository {
  static Future<JadwalModel> getJadwal() async {
    final String pathName = "/all/jadwal";
    try {
      var response = await http.get(Uri.parse("${BaseUrl.url}$pathName"));
      var result = jsonDecode(response.body)['data'][0];
      await Future.delayed(Duration(seconds: 1));
      return JadwalModel.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }
}
