import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_backend/providers/unread_notification_provider.dart';
import 'package:uts_backend/model/notification_model.dart';
import 'package:uts_backend/repository/notification_repository.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool selectMode = false;
  List<String> selectedId = [];

  String getTimeAgo(DateTime time) {
    DateTime receive = time;
    DateTime now = DateTime.now();
    Duration difference = now.difference(receive);

    if (difference.inSeconds < 60) {
      return "Baru saja";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} menit lalu";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} jam lalu";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} hari lalu";
    } else {
      return "${receive.day}/${receive.month}/${receive.year}";
    }
  }

  void updateUnreadNotification(
    List<QueryDocumentSnapshot<NotificationModel>> snapshot,
    UnreadNotificationProvider provider,
  ) async {
    provider.stopScheduleNotification();
    NotificationRepository.updateUnreadNotification();
  }

  late Future<List<QueryDocumentSnapshot<NotificationModel>>> _notifFuture;

  @override
  void initState() {
    _notifFuture = NotificationRepository.getAll(22);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UnreadNotificationProvider provider = context
        .read<UnreadNotificationProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          selectMode ? "${selectedId.length}" : "Notifikasi",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: selectMode ? false : true,
        shape: const Border(
          bottom: BorderSide(width: 2, color: Colors.black12),
        ),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          icon: Icon(
            selectMode ? Icons.close : Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            if (selectMode) {
              setState(() {
                selectMode = false;
                selectedId = [];
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),

        actions: [
          selectMode
              ? IconButton(
                  onPressed: () async {
                    await NotificationRepository.deleteSelectedNotifications(
                      selectedId,
                    );
                    _notifFuture = NotificationRepository.getAll(22);
                    setState(() {
                      selectMode = false;
                      selectedId = [];
                    });
                  },
                  icon: Icon(Icons.delete),
                )
              : SizedBox.shrink(),
        ],
      ),
      body: FutureBuilder(
        future: _notifFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (asyncSnapshot.data!.isEmpty) {
            return Center(child: Text("Belum ada pesan"));
          } else {
            updateUnreadNotification(asyncSnapshot.data!, provider);
            return ListView.builder(
              itemCount: asyncSnapshot.data!.length,
              itemBuilder: (context, index) {
                final data = asyncSnapshot.data![index].data();
                final String pesan = data.body!;
                final DateTime tanggal = data.createdAt!;
                final String id = asyncSnapshot.data![index].id;
                final bool isSelected = selectedId.contains(id);

                return ListTile(
                  tileColor: isSelected ? Colors.grey[300] : Colors.white,
                  leading: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color.fromRGBO(21, 116, 42, 1),
                    foregroundColor: Colors.white,
                    child: Icon(Icons.headset_mic),
                  ),
                  title: Text(
                    pesan,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  subtitle: Text(
                    getTimeAgo(tanggal),
                    style: const TextStyle(
                      color: Color.fromRGBO(76, 76, 76, 1),
                      fontSize: 14,
                    ),
                  ),
                  onLongPress: () {
                    setState(() {
                      selectMode = true;
                      selectedId.add(id);
                    });
                  },
                  onTap: () {
                    if (selectMode) {
                      setState(() {
                        if (isSelected) {
                          selectedId.remove(id);
                          if (selectedId.isEmpty) {
                            selectMode = false;
                          }
                        } else {
                          selectedId.add(id);
                        }
                      });
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
