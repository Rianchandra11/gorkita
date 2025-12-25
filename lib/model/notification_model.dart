import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? title;
  final String? body;
  final DateTime? createdAt;
  final bool? isRead;
  final int? userId;

  NotificationModel({
    this.title,
    this.body,
    this.createdAt,
    this.isRead,
    this.userId,
  });

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return NotificationModel(
      title: data?['title'],
      body: data?['body'],
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate(),
      isRead: data?['isRead'],
      userId: data?['user_id'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (title != null) "title": title,
      if (body != null) "body": body,
      if (createdAt != null) "createdAt": Timestamp.fromDate(createdAt!),
      if (isRead != null) "isRead": isRead,
      if (userId != null) "user_id": userId,
    };
  }
}
