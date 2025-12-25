import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uts_backend/model/sparring_model.dart';

class SparringRepository {
  static Future<List<SparringModel>> getOpenMatches() async {
    List<SparringModel> data = [];
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      final result = await db
          .collection("sparrings")
          .withConverter(
            fromFirestore: SparringModel.fromFirestore,
            toFirestore: (SparringModel sparring, options) =>
                sparring.toFirestore(),
          )
          .where("status", isEqualTo: "open")
          .get();

      for (var doc in result.docs) {
        data.add(doc.data());
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<SparringModel>> getClosedMatches() async {
    List<SparringModel> data = [];
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      final result = await db
          .collection("sparrings")
          .withConverter(
            fromFirestore: SparringModel.fromFirestore,
            toFirestore: (SparringModel sparring, options) =>
                sparring.toFirestore(),
          )
          .where("status", isEqualTo: "close")
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
