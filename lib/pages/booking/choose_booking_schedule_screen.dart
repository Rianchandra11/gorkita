import 'package:flutter/material.dart';
import 'package:uts_backend/helper/date_formatter.dart';
import 'package:uts_backend/helper/datetime_extension.dart';
import 'package:uts_backend/helper/number_formatter.dart';
import 'package:uts_backend/model/venue_jadwal_booked_model.dart';
import 'package:uts_backend/repository/venue_repository.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class ChooseBookingScheduleScreen extends StatefulWidget {
  final int venueId;
  final String jamOperasional;
  final String harga;

  const ChooseBookingScheduleScreen({
    super.key,
    required this.venueId,
    required this.jamOperasional,
    required this.harga,
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDateList();

    jamBuka = int.parse(widget.jamOperasional.split(" - ")[0].substring(0, 2));
    jamTutup = int.parse(widget.jamOperasional.split(" - ")[1].substring(0, 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: FutureBuilder(
            future: VenueRepository.getVenueJadwalBooked(
              widget.venueId,
              getStartScheduleTime(),
              DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                jamTutup,
              ),
            ),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Color.fromRGBO(21, 116, 42, 1),
                  ),
                );
              }
              return _buildScheduleTable(asyncSnapshot.data!);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleTable(List<VenueJadwalBookedModel> data) {
    List<String> bookedList = [];

    data.forEach((e) {
      String namaLapangan = e.nama;
      e.jadwal.forEach((i) => bookedList.add("$namaLapangan - ${i.hour}"));
    });

    List listLapangan = List.generate(10, (index) => "Lapangan ${index + 1}");
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
              bool nearClosedTime = listWaktu[row].hour == jamTutup
                  ? true
                  : false;

              return nearClosedTime == true
                  ? SizedBox()
                  : Container(
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
                            color: isBooked == true
                                ? Colors.grey[300]
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
                                  : SizedBox.shrink(),
                            ],
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
}
