import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? lapangan;
  final DateTime? jamMulai;
  final int? lamaBooking;
  final UserMiniModel? penyewa;
  final List<UserMiniModel>? partners;
  final bool? isReminded;
  final VenueMiniModel? venue;

  BookingModel({
    this.lapangan,
    this.jamMulai,
    this.lamaBooking,
    this.penyewa,
    this.partners,
    this.isReminded,
    this.venue,
  });

  factory BookingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return BookingModel(
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
      isReminded: data?['isReminded'],
      venue: data?['venue'] != null
          ? VenueMiniModel.fromMap(data?['venue'])
          : VenueMiniModel(venueId: data?['venue_id']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (lapangan != null) "lapangan": lapangan,
      if (jamMulai != null) "jam_mulai": Timestamp.fromDate(jamMulai!),
      if (lamaBooking != null) "lama_booking": lamaBooking,
      if (penyewa != null) "penyewa": penyewa!.toMap(),
      if (partners != null)
        "partners": partners!.map((e) => e.toMap()).toList(),
      if (isReminded != null) "isReminded": isReminded,
      if (venue != null) "venue": venue!.toMap(),
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

class VenueMiniModel {
  final int? venueId;
  String? nama;

  VenueMiniModel({this.venueId, this.nama});

  factory VenueMiniModel.fromMap(Map<String, dynamic> map) {
    return VenueMiniModel(venueId: map['venue_id'], nama: map['nama']);
  }

  Map<String, dynamic> toMap() {
    return {
      if (venueId != null) "venue_id": venueId,
      if (nama != null) "nama": nama,
    };
  }
}
