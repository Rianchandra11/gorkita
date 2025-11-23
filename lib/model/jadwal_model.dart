import 'dart:convert';

JadwalModel jadwalModelFromJson(String str) =>
    JadwalModel.fromJson(json.decode(str));

String jadwalModelToJson(JadwalModel data) => json.encode(data.toJson());

class JadwalModel {
  int jadwalId;
  int venueId;
  DateTime tanggal;
  String jamMulai;
  String jamSelesai;
  String lapangan;
  String other;
  String jarak;
  String namaVenue;

  JadwalModel({
    required this.jadwalId,
    required this.venueId,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.lapangan,
    required this.other,
    required this.jarak,
    required this.namaVenue,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) => JadwalModel(
    jadwalId: json["jadwal_id"],
    venueId: json["venue_id"],
    tanggal: DateTime.parse(json["tanggal"]),
    jamMulai: json["jam_mulai"],
    jamSelesai: json["jam_selesai"],
    lapangan: json["lapangan"],
    other: json["other"],
    jarak: json["jarak"],
    namaVenue: json["nama_venue"],
  );

  Map<String, dynamic> toJson() => {
    "jadwal_id": jadwalId,
    "venue_id": venueId,
    "tanggal": tanggal.toIso8601String(),
    "jam_mulai": jamMulai,
    "jam_selesai": jamSelesai,
    "lapangan": lapangan,
    "other": other,
    "jarak": jarak,
    "nama_venue": namaVenue,
  };
}
