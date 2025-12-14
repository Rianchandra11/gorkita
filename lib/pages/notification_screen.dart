import 'package:flutter/material.dart';
import 'package:uts_backend/model/sql_model/notification_model.dart';
import 'package:uts_backend/repository/sql_repository/notification_repository.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool selectMode = false;
  List<int> selectedId = [];
  bool isChanged = false;

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

  late Future<List<NotificationModel>> _notifFuture;

  @override
  void initState() {
    _notifFuture = NotificationRepository.getAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          selectMode ? "${selectedId.length}" : "Notifikasi",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: selectMode ? false : true,
        shape: const Border(
          bottom: BorderSide(width: 2, color: Colors.black12),
        ),

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
              Navigator.pop(context, isChanged);
            }
          },
        ),

        actions: [
          selectMode
              ? IconButton(
                  onPressed: () async {
                    for (int i = 0; i < selectedId.length; i++) {
                      await NotificationRepository.deleteById(selectedId[i]);
                    }
                    _notifFuture = NotificationRepository.getAll();
                    setState(() {
                      selectMode = false;
                      selectedId = [];
                      isChanged = true;
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
          final data = asyncSnapshot.data!;

          return data.isEmpty
              ? Center(child: Text("Belum ada pesan"))
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final String pesan = data[index].pesan;
                      final DateTime tanggal = data[index].tanggal;
                      final int id = data[index].notifId;

                      return ListTile(
                        tileColor: selectMode ? Colors.grey[300] : Colors.white,
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
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
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
                              selectedId.remove(id);
                              if (selectedId.isEmpty) {
                                selectMode = false;
                              }
                            });
                          }
                        },
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
