import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uts_backend/model/notification_model.dart';

class NotificationRepository {
  static Future<List<QueryDocumentSnapshot<NotificationModel>>> getAll(
    int id,
  ) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final result = await db
        .collection("notifications")
        .withConverter(
          fromFirestore: NotificationModel.fromFirestore,
          toFirestore: (NotificationModel notification, options) =>
              notification.toFirestore(),
        )
        .where("user_id", isEqualTo: id)
        .get();
    return result.docs;
  }

  static Stream<int> getUnreadCount(int id) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final result = db
        .collection("notifications")
        .where("user_id", isEqualTo: id)
        .where("isRead", isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
    return result;
  }

  static Future<void> deleteSelectedNotifications(List<String> ids) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    for (final id in ids) {
      final docRef = db.collection('notifications').doc(id);
      batch.delete(docRef);
    }

    await batch.commit();
  }

  static Future<void> updateUnreadNotification() async {
    final db = FirebaseFirestore.instance;

    final querySnapshot = await db
        .collection("notifications")
        .where("isRead", isEqualTo: false)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final batch = db.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {"isRead": true});
      }

      await batch.commit();
    }
  }

  static Future<void> addNotification(
    NotificationModel notificationModel,
  ) async {
    try {
      final db = FirebaseFirestore.instance;

      await db
          .collection("notifications")
          .withConverter<NotificationModel>(
            fromFirestore: NotificationModel.fromFirestore,
            toFirestore: (notification, _) => notification.toFirestore(),
          )
          .add(notificationModel);
    } catch (e) {
      throw Exception("Gagal menambahkan notifikasi: $e");
    }
  }
}
