import 'dart:convert';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

class NotificationModel {
  int notifId;
  String pesan;
  String pengirim;
  DateTime tanggal;

  NotificationModel({
    required this.notifId,
    required this.pesan,
    required this.pengirim,
    required this.tanggal,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        notifId: json["notif_id"],
        pesan: json["pesan"],
        pengirim: json["pengirim"],
        tanggal: DateTime.parse(json["tanggal"]),
      );

  Map<String, dynamic> toJson() => {
    "notif_id": notifId,
    "pesan": pesan,
    "pengirim": pengirim,
    "tanggal": tanggal.toIso8601String(),
  };
}
