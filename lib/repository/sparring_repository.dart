import 'package:http/http.dart' as http;
import 'package:uts_backend/helper/base_url.dart';
import 'dart:convert';

import 'package:uts_backend/model/sparring_model.dart';
import 'package:uts_backend/model/sparring_news_model.dart';

class SparringRepository {
  static Future<List<SparringModel>> getAll() async {
    final String pathName = "/display/sparring";
    try {
      var response = await http.get(Uri.parse("${BaseUrl.url}$pathName"));
      List<dynamic> result = jsonDecode(response.body)['data'];
      await Future.delayed(Duration(seconds: 1));
      return result.map((e) => SparringModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<SparringNewsModel>> getSparringNews() async {
    final String pathName = "/sparring/history";
    try {
      var response = await http.get(Uri.parse("${BaseUrl.url}$pathName"));
      List<dynamic> result = jsonDecode(response.body)['data'];
      await Future.delayed(Duration(seconds: 1));
      return result.map((e) => SparringNewsModel.fromJson(e)).toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
