import 'dart:convert';

MabarModel mabarModelFromJson(String str) =>
    MabarModel.fromJson(json.decode(str));

String mabarModelToJson(MabarModel data) => json.encode(data.toJson());

class MabarModel {
  int mabarId;
  String judul;
  String levelMinimum;
  String levelMaksimum;
  DateTime tanggal;
  String jamMulai;
  String jamSelesai;
  int capacity;
  String namaVenue;
  String kota;
  String host;
  String register;

  MabarModel({
    required this.mabarId,
    required this.judul,
    required this.levelMinimum,
    required this.levelMaksimum,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.capacity,
    required this.namaVenue,
    required this.kota,
    required this.host,
    required this.register,
  });

  factory MabarModel.fromJson(Map<String, dynamic> json) => MabarModel(
    mabarId: json["mabar_id"],
    judul: json["judul"],
    levelMinimum: json["level_minimum"],
    levelMaksimum: json["level_maksimum"],
    tanggal: DateTime.parse(json["tanggal"]),
    jamMulai: json["jam_mulai"],
    jamSelesai: json["jam_selesai"],
    capacity: json["capacity"],
    namaVenue: json["nama_venue"],
    kota: json["kota"],
    host: json["host"],
    register: json["register"],
  );

  Map<String, dynamic> toJson() => {
    "mabar_id": mabarId,
    "judul": judul,
    "level_minimum": levelMinimum,
    "level_maksimum": levelMaksimum,
    "tanggal": tanggal.toIso8601String(),
    "jam_mulai": jamMulai,
    "jam_selesai": jamSelesai,
    "capacity": capacity,
    "nama_venue": namaVenue,
    "kota": kota,
    "host": host,
    "register": register,
  };
}
