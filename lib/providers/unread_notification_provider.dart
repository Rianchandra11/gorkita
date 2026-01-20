import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/widgets.dart';

class UnreadNotificationProvider with ChangeNotifier {
  bool _isFirstOpen = true;

  bool get isFirstOpen => _isFirstOpen;

  void changeFirstOpenStatus() {
    _isFirstOpen = false;
  }

  void startScheduleNotification(int unreadCount) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'unread_reminder_channel',
        actionType: ActionType.Default,
        title: 'Anda memiliki $unreadCount pesan yang belum dibaca',
        body: 'Ketuk untuk melihat pesan',
      ),
      schedule: NotificationCalendar.fromDate(
        date: DateTime.now().add(Duration(seconds: 7)),
        allowWhileIdle: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: "MARK_ALL_AS_READ",
          label: "Tandai semua dibaca",
        ),
      ],
    );
  }

  void handlerOnAppStart(int unreadCount) {
    startScheduleNotification(unreadCount);
  }

  void stopScheduleNotification() async {
    await AwesomeNotifications().cancelSchedule(1);
  }
}
