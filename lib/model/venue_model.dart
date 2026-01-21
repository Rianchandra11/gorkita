import 'package:cloud_firestore/cloud_firestore.dart';

class VenueModel {
  final int? venueId;
  final String? nama;
  final String? alamat;
  final String? deskripsi;
  final String? kota;
  final int? harga;
  final int? totalRating;
  final double? rating;
  final String? jamOperasional;
  final int? jumlahLapangan;
  final List<String>? linkGambar;
  final List<FacilityModel>? fasilitas;

  VenueModel({
    this.venueId,
    this.nama,
    this.alamat,
    this.deskripsi,
    this.kota,
    this.harga,
    this.totalRating,
    this.rating,
    this.jamOperasional,
    this.jumlahLapangan,
    this.linkGambar,
    this.fasilitas,
  });

  factory VenueModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return VenueModel(
      venueId: data?['venue_id'],
      nama: data?['nama'],
      alamat: data?['alamat'],
      deskripsi: data?['deskripsi'],
      kota: data?['kota'],
      harga: data?['harga'],
      totalRating: data?['total_rating'],
      rating: (data?['rating'] is int)
          ? (data?['rating'] as int).toDouble()
          : data?['rating'],
      jamOperasional: data?['jam_operasional'],
      jumlahLapangan: data?['jumlah_lapangan'],
      linkGambar: data?['link_gambar'] is Iterable
          ? List<String>.from(data?['link_gambar'])
          : null,
      fasilitas: data?['fasilitas'] is Iterable
          ? (data?['fasilitas'] as List)
                .map((e) => FacilityModel.fromMap(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (venueId != null) "venue_id": venueId,
      if (nama != null) "nama": nama,
      if (alamat != null) "alamat": alamat,
      if (deskripsi != null) "deskripsi": deskripsi,
      if (kota != null) "kota": kota,
      if (harga != null) "harga": harga,
      if (totalRating != null) "total_rating": totalRating,
      if (rating != null) "rating": rating,
      if (jamOperasional != null) "jam_operasional": jamOperasional,
      if (jumlahLapangan != null) "jumlah_lapangan": jumlahLapangan,
      if (linkGambar != null) "link_gambar": linkGambar,
      if (fasilitas != null)
        "fasilitas": fasilitas!.map((e) => e.toMap()).toList(),
    };
  }
}

class FacilityModel {
  final int? facilityId;
  final String? nama;

  FacilityModel({this.facilityId, this.nama});

  factory FacilityModel.fromMap(Map<String, dynamic> map) {
    return FacilityModel(facilityId: map['facility_id'], nama: map['nama']);
  }

  Map<String, dynamic> toMap() {
    return {
      if (facilityId != null) "facility_id": facilityId,
      if (nama != null) "nama": nama,
    };
  }
}
