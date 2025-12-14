import 'dart:convert';

VenueDetailModel venueDetailModelFromJson(String str) =>
    VenueDetailModel.fromJson(json.decode(str));

String venueDetailModelToJson(VenueDetailModel data) =>
    json.encode(data.toJson());

class VenueDetailModel {
  int venueId;
  String namaVenue;
  String alamat;
  String deskripsi;
  String kota;
  String hargaPerjam;
  int totalRating;
  String jamOperasional;
  double rating;
  int status;
  List<FasilitasModel> fasilitas;
  List<String> linkGambar;

  VenueDetailModel({
    required this.venueId,
    required this.namaVenue,
    required this.alamat,
    required this.deskripsi,
    required this.kota,
    required this.hargaPerjam,
    required this.totalRating,
    required this.jamOperasional,
    required this.rating,
    required this.status,
    required this.fasilitas,
    required this.linkGambar,
  });

  factory VenueDetailModel.fromJson(Map<String, dynamic> json) =>
      VenueDetailModel(
        venueId: json["venue_id"],
        namaVenue: json["nama_venue"],
        alamat: json["alamat"],
        deskripsi: json["deskripsi"],
        kota: json["kota"],
        hargaPerjam: json["harga_perjam"],
        totalRating: json["total_rating"],
        jamOperasional: json["jam_operasional"],
        rating: json["rating"]?.toDouble(),
        status: json["status"],
        fasilitas: List<FasilitasModel>.from(
          json["fasilitas"].map((x) => FasilitasModel.fromJson(x)),
        ),
        linkGambar: List<String>.from(json["link_gambar"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "venue_id": venueId,
    "nama_venue": namaVenue,
    "alamat": alamat,
    "deskripsi": deskripsi,
    "kota": kota,
    "harga_perjam": hargaPerjam,
    "total_rating": totalRating,
    "jam_operasional": jamOperasional,
    "rating": rating,
    "status": status,
    "fasilitas": List<dynamic>.from(fasilitas.map((x) => x.toJson())),
    "link_gambar": List<dynamic>.from(linkGambar.map((x) => x)),
  };
}

class FasilitasModel {
  String id;
  String nama;

  FasilitasModel({required this.id, required this.nama});

  factory FasilitasModel.fromJson(Map<String, dynamic> json) =>
      FasilitasModel(id: json["id"], nama: json["nama"]);

  Map<String, dynamic> toJson() => {"id": id, "nama": nama};
}
