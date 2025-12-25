import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final int? venueId;
  String? namaVenue;
  final String? lapangan;
  final DateTime? jamMulai;
  final int? lamaBooking;
  final UserMiniModel? penyewa;
  final List<UserMiniModel>? partners;

  BookingModel({
    this.venueId,
    this.namaVenue,
    this.lapangan,
    this.jamMulai,
    this.lamaBooking,
    this.penyewa,
    this.partners,
  });

  factory BookingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return BookingModel(
      venueId: data?['venue_id'],
      lapangan: data?['lapangan'],
      jamMulai: (data?['jam_mulai'] as Timestamp?)?.toDate(),
      lamaBooking: data?['lama_booking'],
      penyewa: data?['penyewa'] != null
          ? UserMiniModel.fromMap(data!['penyewa'])
          : null,
      partners: data?['partners'] is Iterable
          ? (data!['partners'] as List)
                .map((e) => UserMiniModel.fromMap(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (venueId != null) "venue_id": venueId,
      if (lapangan != null) "lapangan": lapangan,
      if (jamMulai != null) "jam_mulai": Timestamp.fromDate(jamMulai!),
      if (lamaBooking != null) "lama_booking": lamaBooking,
      if (penyewa != null) "penyewa": penyewa!.toMap(),
      if (partners != null)
        "partners": partners!.map((e) => e.toMap()).toList(),
    };
  }
}

class UserMiniModel {
  final int? userId;
  final String? nama;

  UserMiniModel({this.userId, this.nama});

  factory UserMiniModel.fromMap(Map<String, dynamic> map) {
    return UserMiniModel(userId: map['user_id'], nama: map['nama']);
  }

  Map<String, dynamic> toMap() {
    return {
      if (userId != null) "user_id": userId,
      if (nama != null) "nama": nama,
    };
  }
}
