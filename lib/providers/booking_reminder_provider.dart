import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:uts_backend/helper/date_formatter.dart';
import 'package:uts_backend/repository/user_repository.dart';

class BookingReminderProvider with ChangeNotifier {
  bool _isFirstOpen = true;

  bool get isFirstOpen => _isFirstOpen;

  void changeFirstOpenStatus() {
    _isFirstOpen = false;
  }

  void createReminderNotification(String namaVenue, DateTime jamMulai) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,
        channelKey: 'booking_reminder_channel',
        actionType: ActionType.Default,
        title: '⏰ Booking Sebentar Lagi',
        notificationLayout: NotificationLayout.BigText,
        body:
            "Booking di $namaVenue pukul ${DateFormatter.format("HH:mm", jamMulai)} akan dimulai kurang dari 1 jam lagi. Jangan terlambat!",
      ),
      schedule: NotificationCalendar.fromDate(
        date: DateTime.now().add(Duration(seconds: 10)),
        allowWhileIdle: true,
      ),
      actionButtons: [
        NotificationActionButton(key: "FIND_SCHEDULE", label: "Lihat jadwal"),
      ],
    );
  }

  void handlerOnAppStart(int userId) async {
    if (_isFirstOpen) {
      changeFirstOpenStatus();
      final result = await UserRepository.alertSchedule(userId);
      if (result != null) {
        createReminderNotification(result.venue!.nama!, result.jamMulai!);
      }
    }
  }
}
