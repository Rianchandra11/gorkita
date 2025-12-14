import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uts_backend/helper/date_formatter.dart';
import 'package:uts_backend/helper/datetime_extension.dart';
import 'package:uts_backend/helper/number_formatter.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:uts_backend/model/booking_model.dart';
import 'package:uts_backend/pages/home.dart';
import 'package:uts_backend/repository/venue_repository.dart';

class ChooseBookingScheduleScreen extends StatefulWidget {
  final int venueId;
  final String jamOperasional;
  final String harga;
  final int jumlahLapangan;

  const ChooseBookingScheduleScreen({
    super.key,
    required this.venueId,
    required this.jamOperasional,
    required this.harga,
    required this.jumlahLapangan,
  });

  @override
  State<ChooseBookingScheduleScreen> createState() =>
      _ChooseBookingScheduleScreenState();
}

class _ChooseBookingScheduleScreenState
    extends State<ChooseBookingScheduleScreen> {
  DateTime selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final List<DateTime> dateList = [];
  late int jamBuka;
  late int jamTutup;
  List selectedSchedule = [];
  late Stream<QuerySnapshot<BookingModel>> bookedScheduleStream;
  bool _isLoading = false;

  void getDateList() {
    DateTime now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    DateTimeRange dateTimeRange = DateTimeRange(
      start: now,
      end: now.add(Duration(days: 30)),
    );

    for (int i = 0; i <= dateTimeRange.duration.inDays; i++) {
      final date = dateTimeRange.start.add(Duration(days: i));
      dateList.add(date);
    }
  }

  DateTime getStartScheduleTime() {
    DateTime now = DateTime.now();
    DateTime nowDate = DateTime(now.year, now.month, now.day);

    DateTime rawDate = nowDate == selectedDate && DateTime.now().hour >= jamBuka
        ? DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            DateTime.now().hour + 1,
          )
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            jamBuka,
          );

    DateTime dateTimeNow = DateTime(
      rawDate.year,
      rawDate.month,
      rawDate.day,
      rawDate.hour,
    );

    return dateTimeNow;
  }

  void _initStream() {
    bookedScheduleStream = VenueRepository.getBookedSchedule(
      widget.venueId,
      getStartScheduleTime(),
      DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        jamTutup,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDateList();

    jamBuka = int.parse(widget.jamOperasional.split(" - ")[0].substring(0, 2));
    jamTutup = int.parse(widget.jamOperasional.split(" - ")[1].substring(0, 2));

    _initStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: StreamBuilder(
            stream: bookedScheduleStream,
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Color.fromRGBO(21, 116, 42, 1),
                  ),
                );
              }
              return _buildScheduleTable(asyncSnapshot.data!.docs);
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBookingBar(context),
    );
  }

  Widget _buildScheduleTable(List<QueryDocumentSnapshot<BookingModel>> data) {
    List<String> bookedList = [];
    List<String> selfBookedList = [];

    for (var e in data) {
      String namaLapangan = e.data().lapangan!;
      DateTimeRange dateTimeRange = DateTimeRange(
        start: e.data().jamMulai!,
        end: e.data().jamMulai!.add(Duration(hours: e.data().lamaBooking! - 1)),
      );

      for (int i = 0; i <= dateTimeRange.duration.inHours; i++) {
        if (e.data().penyewa!.userId == 22) {
          selfBookedList.add(
            "$namaLapangan - ${e.data().jamMulai!.add(Duration(hours: i)).hour}",
          );
        } else {
          bookedList.add(
            "$namaLapangan - ${e.data().jamMulai!.add(Duration(hours: i)).hour}",
          );
        }
      }
    }

    List listLapangan = List.generate(
      widget.jumlahLapangan,
      (index) => "Lapangan ${index + 1}",
    );
    List<DateTime> listWaktu = [];

    DateTime startScheduleTime = getStartScheduleTime();

    for (int time = 0; time <= jamTutup - startScheduleTime.hour; time++) {
      final timeData = startScheduleTime.add(Duration(hours: time));
      listWaktu.add(timeData);
    }

    return listWaktu.isEmpty
        ? Center(child: Text("Maaf, Tidak Ada Jadwal yang Tersedia"))
        : StickyHeadersTable(
            columnsLength: listLapangan.length,
            rowsLength: listWaktu.length,
            cellDimensions: CellDimensions.fixed(
              contentCellWidth: 140,
              contentCellHeight: 80,
              stickyLegendWidth: 58,
              stickyLegendHeight: 58,
            ),
            columnsTitleBuilder: (index) => Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black12),
                  right: BorderSide(color: Colors.black12),
                  bottom: BorderSide(color: Colors.black12, width: 2),
                ),
              ),
              child: Center(child: Text(listLapangan[index])),
            ),
            legendCell: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black12),
                  right: BorderSide(color: Colors.black12),
                  bottom: BorderSide(color: Colors.black12, width: 2),
                ),
              ),
              child: Icon(Icons.tune),
            ),
            rowsTitleBuilder: (index) => Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.black12, width: 2),
                  bottom: BorderSide(color: Colors.black12),
                ),
              ),
              child: Text(
                DateFormatter.format("HH:00", listWaktu[index]),
                textAlign: TextAlign.center,
              ),
            ),
            contentCellBuilder: (col, row) {
              bool isBooked = bookedList.contains(
                "${listLapangan[col]} - ${listWaktu[row].hour}",
              );
              bool isSelected = selectedSchedule.contains(
                "${listLapangan[col]} - ${listWaktu[row].hour}",
              );
              bool nearClosedTime = listWaktu[row].hour == jamTutup
                  ? true
                  : false;
              bool isSelfBooked = selfBookedList.contains(
                "${listLapangan[col]} - ${listWaktu[row].hour}",
              );

              return nearClosedTime == true
                  ? SizedBox()
                  : GestureDetector(
                      onTap: isBooked
                          ? null
                          : () {
                              setState(() {
                                if (!isSelected) {
                                  selectedSchedule.add(
                                    "${listLapangan[col]} - ${listWaktu[row].hour}",
                                  );
                                } else {
                                  selectedSchedule.remove(
                                    "${listLapangan[col]} - ${listWaktu[row].hour}",
                                  );
                                }
                              });
                            },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.black12, width: 2),
                            bottom: BorderSide(color: Colors.black12, width: 2),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? Colors.grey[300]
                                  : isSelected || isSelfBooked
                                  ? Color.fromRGBO(21, 116, 42, .2)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              spacing: 4,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  NumberFormatter.currency(
                                    int.parse(widget.harga),
                                    symbol: "",
                                  ),
                                  style: TextStyle(fontSize: 14),
                                ),
                                isBooked == true
                                    ? Text(
                                        "Booked",
                                        style: TextStyle(fontSize: 12),
                                      )
                                    : isSelfBooked
                                    ? Text(
                                        "Telah Kamu Booking",
                                        style: TextStyle(fontSize: 12),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
            },
          );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 140,
      leading: SizedBox.shrink(),
      backgroundColor: Colors.white,
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.chevron_left_rounded, size: 28),
                  ),
                  Center(
                    child: Text(
                      "Pilih Jadwal",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            SizedBox(
              height: 80,
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: double.infinity,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.calendar_month_rounded),
                        ),
                        VerticalDivider(
                          indent: 24,
                          endIndent: 24,
                          width: 8,
                          thickness: 2,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: dateList.map((e) {
                          Color dayNameColor = e == selectedDate
                              ? Colors.white
                              : Colors.black54;
                          Color dateColor = e == selectedDate
                              ? Colors.white
                              : e.isWeekend
                              ? Colors.red
                              : Colors.black;

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDate = e;
                                  _initStream();
                                });
                              },
                              child: Container(
                                width: 68,
                                height: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: e == selectedDate
                                      ? Color.fromRGBO(21, 116, 42, 1)
                                      : Colors.white,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormatter.format("EE", e),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: dayNameColor,
                                      ),
                                    ),
                                    Text(
                                      DateFormatter.format("dd MMM", e),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: dateColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingBar(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Biaya',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    NumberFormatter.currency(
                      int.parse(widget.harga) * selectedSchedule.length,
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      Text(
                        "${selectedSchedule.length}",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'jadwal dipilih',
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedSchedule.isEmpty
                      ? null
                      : () async {
                          setState(() => _isLoading = true);

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
                              widget.venueId,
                              22,
                              "Alvin",
                              lapangan,
                              jamMulai,
                            );
                          }

                          setState(() {
                            _isLoading = false;
                            selectedSchedule.clear();
                          });

                          await Future.delayed(Duration(seconds: 2));

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(id: 0),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedSchedule.isEmpty
                        ? Colors.grey[600]
                        : Color.fromRGBO(21, 116, 42, 1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'Booking Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
