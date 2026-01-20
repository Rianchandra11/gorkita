import 'dart:convert';

SparringModel sparringModelFromJson(String str) =>
    SparringModel.fromJson(json.decode(str));

String sparringModelToJson(SparringModel data) => json.encode(data.toJson());

class SparringModel {
  int sparringId;
  String namaVenue;
  String namaTim;
  String kota;
  String kategori;
  String provinsi;
  String minimumAvailableTime;
  String maximumAvailableTime;
  DateTime tanggal;
  String searchPlayer;

  SparringModel({
    required this.sparringId,
    required this.namaVenue,
    required this.namaTim,
    required this.kota,
    required this.kategori,
    required this.provinsi,
    required this.minimumAvailableTime,
    required this.maximumAvailableTime,
    required this.tanggal,
    required this.searchPlayer,
  });

  factory SparringModel.fromJson(Map<String, dynamic> json) => SparringModel(
    sparringId: json["sparring_id"],
    namaVenue: json["nama_venue"],
    namaTim: json["nama_tim"],
    kota: json["kota"],
    kategori: json["kategori"],
    provinsi: json["provinsi"],
    minimumAvailableTime: json["minimum_available_time"],
    maximumAvailableTime: json["maximum_available_time"],
    tanggal: DateTime.parse(json["tanggal"]),
    searchPlayer: json["search_player"],
  );

  Map<String, dynamic> toJson() => {
    "sparring_id": sparringId,
    "nama_venue": namaVenue,
    "nama_tim": namaTim,
    "kota": kota,
    "kategori": kategori,
    "provinsi": provinsi,
    "minimum_available_time": minimumAvailableTime,
    "maximum_available_time": maximumAvailableTime,
    "tanggal": tanggal.toIso8601String(),
    "search_player": searchPlayer,
  };
}
