import 'package:uts_backend/model/venue_jadwal_booked_model.dart';
import 'package:http/http.dart' as http;
import 'package:uts_backend/helper/base_url.dart';
import 'package:uts_backend/model/venue_detail_model.dart';
import 'dart:convert';

import 'package:uts_backend/model/venue_model.dart';

class VenueRepository {
  static Future<List<VenueModel>> getAll() async {
    final String pathName = "/display/venue";
    try {
      var response = await http.get(Uri.parse("${BaseUrl.url}$pathName"));
      List<dynamic> result = jsonDecode(response.body)['data'];
      await Future.delayed(Duration(seconds: 1));
      return result.map((e) => VenueModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<VenueDetailModel> getVenueDetail(int id) async {
    final String pathName = "/detail/venue/$id";
    try {
      var response = await http.get(Uri.parse("${BaseUrl.url}$pathName"));
      dynamic result = jsonDecode(response.body)['data'];
      await Future.delayed(Duration(seconds: 1));
      return VenueDetailModel.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<VenueJadwalBookedModel>> getVenueJadwalBooked(
    int id,
    DateTime start,
    DateTime end,
  ) async {
    final String pathName =
        "/display/venue/booking/$id?dateTimeStart=${start.toIso8601String()}&dateTimeEnd=${end.toIso8601String()}";
    try {
      var response = await http.get(Uri.parse("${BaseUrl.url}$pathName"));
      Map data = jsonDecode(response.body)['data'];
      if (data.isNotEmpty) {
        List<dynamic> result = jsonDecode(response.body)['data']['lapangan'];
        await Future.delayed(Duration(seconds: 1));
        return result.map((e) => VenueJadwalBookedModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }
}
