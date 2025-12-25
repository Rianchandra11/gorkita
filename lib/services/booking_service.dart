import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:uts_backend/helper/date_formatter.dart';
import 'package:uts_backend/model/venue_model.dart';
import 'package:uts_backend/model/notification_model.dart' as nm;
import 'package:uts_backend/repository/notification_repository.dart';
import 'package:uts_backend/repository/venue_repository.dart';

class BookingService {
  static Future<void> createConfirmationNotification(
    int venueId,
    int jumlahBooking,
    DateTime tanggal,
  ) async {
    try {
      VenueModel venue = await VenueRepository.getDetails(venueId);
      String namaVenue = venue.nama!;
      String notifBody = 'Berhasil booking $jumlahBooking jadwal di $namaVenue';

      await NotificationRepository.addNotification(
        nm.NotificationModel(
          title: "Booking berhasil!",
          body: notifBody,
          createdAt: DateTime.now(),
          isRead: true,
          userId: 22,
        ),
      );

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 2,
          channelKey: 'booking_confirmation_channel',
          actionType: ActionType.Default,
          title: '✅ Booking berhasil!',
          body: notifBody,
        ),
      );

      print("Sukses create notif");
    } catch (e) {
      print(e);
    }
  }

  static Future<void> insertBookings(
    List selectedSchedule,
    DateTime selectedDate,
    int venueId,
  ) async {
    try {
      for (final e in selectedSchedule) {
        final parts = e.split(" - ");
        final lapangan = parts[0];
        final hour = int.parse(parts[1]);

        final jamMulai = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          hour,
        );

        await VenueRepository.insertBooking(
          venueId,
          22,
          "Alvin",
          lapangan,
          jamMulai,
        );
      }

      await createConfirmationNotification(
        venueId,
        selectedSchedule.length,
        selectedDate,
      );
    } catch (e) {
      print(e);
    }
  }
}
