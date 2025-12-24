import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_backend/providers/unread_notification_provider.dart';
import 'package:uts_backend/pages/notification_screen.dart';
import 'package:uts_backend/repository/notification_repository.dart';

class NotificationButton extends StatefulWidget {
  const NotificationButton({super.key});

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  late Stream<bool> _isAlertOnStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isAlertOnStream = NotificationRepository.getUnreadCount(22);
  }

  @override
  Widget build(BuildContext context) {
    UnreadNotificationProvider provider = context
        .read<UnreadNotificationProvider>();

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationScreen()),
          );
        },
        icon: Stack(
          children: [
            const Icon(Icons.notifications_none, size: 26, color: Colors.white),
            StreamBuilder(
              stream: _isAlertOnStream,
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.hasData) {
                  bool isAlertOn = asyncSnapshot.data!;

                  if (provider.isFirstOpen) {
                    provider.changeFirstOpenStatus();
                    if (isAlertOn) {
                      provider.handlerOnAppStart();
                    }
                  }

                  return isAlertOn
                      ? Positioned(
                          top: 1,
                          right: 1,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
