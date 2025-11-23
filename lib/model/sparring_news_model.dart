import 'dart:convert';

SparringNewsModel sparringNewsModelFromJson(String str) =>
    SparringNewsModel.fromJson(json.decode(str));

String sparringNewsModelToJson(SparringNewsModel data) =>
    json.encode(data.toJson());

class SparringNewsModel {
  int sparringId;
  DateTime tanggal;
  String maximumAvailableTime;
  String kota;
  String provinsi;
  String playerA;
  String playerB;
  String kategori;
  String skorSet1;
  dynamic skorSet2;
  dynamic skorSet3;

  SparringNewsModel({
    required this.sparringId,
    required this.tanggal,
    required this.maximumAvailableTime,
    required this.kota,
    required this.provinsi,
    required this.playerA,
    required this.playerB,
    required this.kategori,
    required this.skorSet1,
    required this.skorSet2,
    required this.skorSet3,
  });

  factory SparringNewsModel.fromJson(Map<String, dynamic> json) =>
      SparringNewsModel(
        sparringId: json["sparring_id"],
        tanggal: DateTime.parse(json["tanggal"]),
        maximumAvailableTime: json["maximum_available_time"],
        kota: json["kota"],
        provinsi: json["provinsi"],
        playerA: json["player_a"],
        playerB: json["player_b"],
        kategori: json["kategori"],
        skorSet1: json["skor_set1"],
        skorSet2: json["skor_set2"],
        skorSet3: json["skor_set3"],
      );

  Map<String, dynamic> toJson() => {
    "sparring_id": sparringId,
    "tanggal": tanggal.toIso8601String(),
    "maximum_available_time": maximumAvailableTime,
    "kota": kota,
    "provinsi": provinsi,
    "player_a": playerA,
    "player_b": playerB,
    "kategori": kategori,
    "skor_set1": skorSet1,
    "skor_set2": skorSet2,
    "skor_set3": skorSet3,
  };
}
