// To parse this JSON data, do
//
//     final cariSparringModel = cariSparringModelFromJson(jsonString);

import 'dart:convert';

CariSparringModel cariSparringModelFromJson(String str) =>
    CariSparringModel.fromJson(json.decode(str));

String cariSparringModelToJson(CariSparringModel data) =>
    json.encode(data.toJson());

class CariSparringModel {
  String uidspar;
  String uiduser1;
  String? uiduser2;
  String namaSparring;
  String venue;
  String tanggal;
  String kategori;

  CariSparringModel({
    required this.uidspar,
    required this.uiduser1,
    this.uiduser2,
    required this.namaSparring,
    required this.venue,
    required this.tanggal,
    required this.kategori,
  });

  factory CariSparringModel.fromJson(Map<String, dynamic> json) =>
      CariSparringModel(
        uidspar: json["uidspar"],
        uiduser1: json["uiduser1"],
        uiduser2: json["uiduser2"],
        namaSparring: json["nama_sparring"],
        venue: json["venue"],
        tanggal: json["tanggal"],
        kategori: json["kategori"],
      );

  Map<String, dynamic> toJson() => {
    "uidspar":uidspar,
    "uiduser1": uiduser1,
    "uiduser2": uiduser2,
    "nama_sparring": namaSparring,
    "venue": venue,
    "tanggal": tanggal,
    "kategori": kategori,
  };
}
