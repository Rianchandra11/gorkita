import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uts_backend/model/booking_model.dart';
import 'package:uts_backend/model/venue_model.dart';

class VenueRepository {
  static Future<List<VenueModel>> get() async {
    List<VenueModel> data = [];
    FirebaseFirestore db = FirebaseFirestore.instance;
    final result = await db
        .collection("venues")
        .withConverter(
          fromFirestore: VenueModel.fromFirestore,
          toFirestore: (VenueModel venue, options) => venue.toFirestore(),
        )
        .get();
    for (var doc in result.docs) {
      data.add(doc.data());
    }
    return data;
  }

  static Future<VenueModel> getDetails(int id) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final result = await db
        .collection("venues")
        .withConverter(
          fromFirestore: VenueModel.fromFirestore,
          toFirestore: (VenueModel venue, options) => venue.toFirestore(),
        )
        .where("venue_id", isEqualTo: id)
        .get();
    return result.docs[0].data();
  }

  static Stream<QuerySnapshot<BookingModel>> getBookedSchedule(
    int id,
    DateTime start,
    DateTime end,
  ) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final result = db
        .collection("bookings")
        .withConverter(
          fromFirestore: BookingModel.fromFirestore,
          toFirestore: (BookingModel booking, options) => booking.toFirestore(),
        )
        .where("venue_id", isEqualTo: id)
        .where("jam_mulai", isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where("jam_mulai", isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots();

    return result;
  }

  static Future<Map<String, String>> insertBooking(
    int venueId,
    int userId,
    String nama,
    String lapangan,
    DateTime jamMulai, {
    int lamaBooking = 1,
  }) async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      await db.collection("bookings").add({
        "venue_id": venueId,
        "penyewa": {"user_id": userId, "nama": nama},
        "lapangan": lapangan,
        "jam_mulai": Timestamp.fromDate(jamMulai),
        "lama_booking": lamaBooking,
      });
      return {"code": "1", "message": "Data berhasil diinput"};
    } catch (e) {
      return {"code": "0", "message": e.toString()};
    }
  }
}
