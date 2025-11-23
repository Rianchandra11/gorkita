// To parse this JSON data, do
//
//     final cariSparringModel = cariSparringModelFromJson(jsonString);

import 'dart:convert';

CariSparringModel cariSparringModelFromJson(String str) => CariSparringModel.fromJson(json.decode(str));

String cariSparringModelToJson(CariSparringModel data) => json.encode(data.toJson());

class CariSparringModel {
    int idUser;
    int? idUser2;
    String namaSparring;
    String venue;
    String tanggal;
    String kategori;

    CariSparringModel({
        required this.idUser,
        this.idUser2,
        required this.namaSparring,
        required this.venue,
        required this.tanggal,
        required this.kategori,
    });

    factory CariSparringModel.fromJson(Map<String, dynamic> json) => CariSparringModel(
        idUser: json["id_user"],
        idUser2: json["id_user2"],
        namaSparring: json["nama_sparring"],
        venue: json["venue"],
        tanggal: json["tanggal"],
        kategori: json["kategori"],
    );

    Map<String, dynamic> toJson() => {
        "id_user": idUser,
        "id_user2": idUser2,
        "nama_sparring": namaSparring,
        "venue": venue,
        "tanggal": tanggal,
        "kategori": kategori,
    };
}
