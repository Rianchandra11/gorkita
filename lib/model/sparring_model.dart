import 'package:cloud_firestore/cloud_firestore.dart';

class SparringModel {
  final int? sparringId;
  final int? venueId;
  final DateTime? tanggal;
  final String? jamMulai;
  final String? jamSelesai;
  final String? provinsi;
  final String? kota;
  final String? kategori;
  final String? namaTim;
  final String? status;
  final List<SparringParticipant>? participant;
  final ScoreModel? score;

  SparringModel({
    this.sparringId,
    this.venueId,
    this.tanggal,
    this.jamMulai,
    this.jamSelesai,
    this.provinsi,
    this.kota,
    this.kategori,
    this.namaTim,
    this.status,
    this.participant,
    this.score,
  });

  factory SparringModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return SparringModel(
      sparringId: data?['sparring_id'],
      venueId: data?['venue_id'],
      tanggal: DateTime.parse(data?['tanggal']),
      jamMulai: data?['jam_mulai'],
      jamSelesai: data?['jam_selesai'],
      provinsi: data?['provinsi'],
      kota: data?['kota'],
      kategori: data?['kategori'],
      namaTim: data?['nama_tim'],
      status: data?['status'],
      participant: data?['participant'] is Iterable
          ? (data?['participant'] as List)
                .map((e) => SparringParticipant.fromMap(e))
                .toList()
          : null,
      score: data?['score'] != null ? ScoreModel.fromMap(data?['score']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (sparringId != null) "sparring_id": sparringId,
      if (venueId != null) "venue_id": venueId,
      if (tanggal != null) "tanggal": tanggal,
      if (jamMulai != null) "jam_mulai": jamMulai,
      if (jamSelesai != null) "jam_selesai": jamSelesai,
      if (provinsi != null) "provinsi": provinsi,
      if (kota != null) "kota": kota,
      if (kategori != null) "kategori": kategori,
      if (namaTim != null) "nama_tim": namaTim,
      if (status != null) "status": status,
      if (participant != null)
        "participant": participant!.map((e) => e.toMap()).toList(),
      if (score != null) "score": score!.toMap(),
    };
  }
}

class SparringParticipant {
  final int? userId;
  final String? nama;
  final String? role;

  SparringParticipant({this.userId, this.nama, this.role});

  factory SparringParticipant.fromMap(Map<String, dynamic> map) {
    return SparringParticipant(
      userId: map['userId'],
      nama: map['nama'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (userId != null) "userId": userId,
      if (nama != null) "nama": nama,
      if (role != null) "role": role,
    };
  }
}

class ScoreModel {
  final List<int>? penantang;
  final List<int>? penerima;

  ScoreModel({this.penantang, this.penerima});

  factory ScoreModel.fromMap(Map<String, dynamic> map) {
    return ScoreModel(
      penantang: map['penantang'] is Iterable
          ? List<int>.from(map['penantang'])
          : null,
      penerima: map['penerima'] is Iterable
          ? List<int>.from(map['penerima'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (penantang != null) "penantang": penantang,
      if (penerima != null) "penerima": penerima,
    };
  }
}
