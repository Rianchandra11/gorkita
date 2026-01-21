import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uts_backend/model/booking_model.dart';


class UserRepository {
  static Future<List<BookingModel>?> getBookingSchedule(int id) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    final venueSnap = await db.collection("venues").get();
    final Map<int, String> venueMap = {};

    for (var doc in venueSnap.docs) {
      venueMap[doc['venue_id']] = doc['nama'];
    }

    final bookingSnap = await db
        .collection("bookings")
        .withConverter(
          fromFirestore: BookingModel.fromFirestore,
          toFirestore: (BookingModel booking, _) => booking.toFirestore(),
        )
        .where("penyewa.user_id", isEqualTo: id)
        .where(
          "jam_mulai",
          isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
        )
        .get();

    if (bookingSnap.docs.isEmpty) return null;

    final List<BookingModel> result = [];

    for (var doc in bookingSnap.docs) {
      final booking = doc.data();
      booking.venue?.nama ??= venueMap[booking.venue?.venueId];
      result.add(booking);
    }

    return result;
  }

  static Future<BookingModel?> alertSchedule(int userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final start = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
    );

    final end = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour + 1,
    );

    final result = await db
        .collection("bookings")
        .withConverter(
          fromFirestore: BookingModel.fromFirestore,
          toFirestore: (BookingModel booking, options) => booking.toFirestore(),
        )
        .where("penyewa.user_id", isEqualTo: userId)
        .where("jam_mulai", isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where("jam_mulai", isLessThanOrEqualTo: Timestamp.fromDate(end))
        .where("isReminded", isEqualTo: false)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      final id = result.docs[0].id;
      await db.collection("bookings").doc(id).update({"isReminded": true});
      return result.docs[0].data();
    } else {
      return null;
    }
  }
}
