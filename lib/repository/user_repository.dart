import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uts_backend/model/booking_model.dart';
import 'package:uts_backend/model/venue_model.dart';
import 'package:uts_backend/repository/venue_repository.dart';

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
        .get();

    if (bookingSnap.docs.isEmpty) return null;

    final List<BookingModel> result = [];

    /// Inject namaVenue
    for (var doc in bookingSnap.docs) {
      final booking = doc.data();
      booking.namaVenue = venueMap[booking.venueId];
      result.add(booking);
    }

    return result;
  }
}
