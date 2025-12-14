import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uts_backend/model/mabar_model.dart';
import 'package:uts_backend/model/venue_model.dart';

class MabarRepository {
  static Future<List<MabarModel>> get() async {
    List<MabarModel> data = [];
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      final result = await db
          .collection("casual_matches")
          .withConverter(
            fromFirestore: MabarModel.fromFirestore,
            toFirestore: (MabarModel mabar, options) => mabar.toFirestore(),
          )
          .get();

      for (var doc in result.docs) {
        data.add(doc.data());
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }
}
