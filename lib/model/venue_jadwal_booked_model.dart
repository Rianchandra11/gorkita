// To parse this JSON data, do
//
//     final venueJadwalBookedModel = venueJadwalBookedModelFromJson(jsonString);

import 'dart:convert';

VenueJadwalBookedModel venueJadwalBookedModelFromJson(String str) =>
    VenueJadwalBookedModel.fromJson(json.decode(str));

String venueJadwalBookedModelToJson(VenueJadwalBookedModel data) =>
    json.encode(data.toJson());

class VenueJadwalBookedModel {
  String nama;
  List<DateTime> jadwal;

  VenueJadwalBookedModel({required this.nama, required this.jadwal});

  factory VenueJadwalBookedModel.fromJson(Map<String, dynamic> json) =>
      VenueJadwalBookedModel(
        nama: json["nama"],
        jadwal: List<DateTime>.from(
          json["jadwal"].map((x) => DateTime.parse(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "nama": nama,
    "jadwal": List<dynamic>.from(jadwal.map((x) => x)),
  };
}
