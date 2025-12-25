import 'package:cloud_firestore/cloud_firestore.dart';

class MabarModel {
  final int? mabarId;
  final VenueMiniModel? venue;
  final String? judul;
  final String? levelMinimum;
  final String? levelMaksimum;
  final DateTime? tanggal;
  final String? jamMulai;
  final String? jamSelesai;
  final int? capacity;
  final List<MabarParticipant>? participants;

  MabarModel({
    this.mabarId,
    this.venue,
    this.judul,
    this.levelMinimum,
    this.levelMaksimum,
    this.tanggal,
    this.jamMulai,
    this.jamSelesai,
    this.capacity,
    this.participants,
  });

  factory MabarModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MabarModel(
      mabarId: data?['mabar_id'],
      venue: data?['venue'] != null
          ? VenueMiniModel.fromMap(data?['venue'])
          : null,
      judul: data?['judul'],
      levelMinimum: data?['level_minimum'],
      levelMaksimum: data?['level_maksimum'],
      tanggal: DateTime.parse(data?['tanggal']),
      jamMulai: data?['jam_mulai'],
      jamSelesai: data?['jam_selesai'],
      capacity: data?['capacity'],
      participants: data?['participants'] is Iterable
          ? (data?['participants'] as List)
                .map((e) => MabarParticipant.fromMap(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (mabarId != null) "mabar_id": mabarId,
      if (venue != null) "venue": venue!.toMap(),
      if (judul != null) "judul": judul,
      if (levelMinimum != null) "level_minimum": levelMinimum,
      if (levelMaksimum != null) "level_maksimum": levelMaksimum,
      if (tanggal != null) "tanggal": tanggal,
      if (jamMulai != null) "jam_mulai": jamMulai,
      if (jamSelesai != null) "jam_selesai": jamSelesai,
      if (capacity != null) "capacity": capacity,
      if (participants != null)
        "participants": participants!.map((e) => e.toMap()).toList(),
    };
  }
}

class VenueMiniModel {
  final int? venueId;
  final String? nama;
  final String? kota;

  VenueMiniModel({this.venueId, this.nama, this.kota});

  factory VenueMiniModel.fromMap(Map<String, dynamic> map) {
    return VenueMiniModel(
      venueId: map['venue_id'],
      nama: map['nama'],
      kota: map['kota'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (venueId != null) "venue_id": venueId,
      if (nama != null) "nama": nama,
      if (kota != null) "kota": kota,
    };
  }
}

class MabarParticipant {
  final int? userId;
  final String? name;
  final String? status;

  MabarParticipant({this.userId, this.name, this.status});

  factory MabarParticipant.fromMap(Map<String, dynamic> map) {
    return MabarParticipant(
      userId: map['user_id'],
      name: map['name'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (userId != null) "user_id": userId,
      if (name != null) "name": name,
      if (status != null) "status": status,
    };
  }
}
