import 'dart:convert';

VenueModel venueModelFromJson(String str) =>
    VenueModel.fromJson(json.decode(str));

String venueModelToJson(VenueModel data) => json.encode(data.toJson());

class VenueModel {
  int venueId;
  String namaVenue;
  String kota;
  double rating;
  int totalRating;
  String hargaPerjam;
  String url;

  VenueModel({
    required this.venueId,
    required this.namaVenue,
    required this.kota,
    required this.rating,
    required this.totalRating,
    required this.hargaPerjam,
    required this.url,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) => VenueModel(
    venueId: json["venue_id"],
    namaVenue: json["nama_venue"],
    kota: json["kota"],
    rating: json["rating"]?.toDouble(),
    totalRating: json["total_rating"],
    hargaPerjam: json["harga_perjam"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "venue_id": venueId,
    "nama_venue": namaVenue,
    "kota": kota,
    "rating": rating,
    "total_rating": totalRating,
    "harga_perjam": hargaPerjam,
    "url": url,
  };
}
