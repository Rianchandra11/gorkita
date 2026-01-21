import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uts_backend/model/sparring_model.dart';

class SparringRepository {
  static Stream<List<SparringModel>> getOpenMatches() {
  
    FirebaseFirestore db = FirebaseFirestore.instance;
    return db
          .collection("sparrings")
          .withConverter(
            fromFirestore: SparringModel.fromFirestore,
            toFirestore: (SparringModel sparring, options) =>
                sparring.toFirestore(),
          )
          .where("status", isEqualTo: "open")
          .snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

      
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
