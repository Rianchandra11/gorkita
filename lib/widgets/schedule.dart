import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uts_backend/model/jadwal_model.dart';
import 'package:uts_backend/repository/jadwal_repository.dart';
import 'package:uts_backend/helper/date_formatter.dart';
import 'package:uts_backend/widgets/skeletons/schedule_skeleton.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key, required this.isDark});
  final bool isDark;

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      children: [
        Card(
          color: isDark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          elevation: isDark ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder(
              future: JadwalRepository.getJadwal(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildScheduleHeader(true, isDark),
                      const SizedBox(height: 12),
                      const ScheduleSkeleton(),
                    ],
                  );
                }

                if (asyncSnapshot.hasError || asyncSnapshot.data == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildScheduleHeader(false, isDark),
                      const SizedBox(height: 12),
                      Text(
                        "Belum ada jadwal tersedia",
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScheduleHeader(false, isDark),
                    const SizedBox(height: 12),
                    _buildScheduleCard(asyncSnapshot.data!, isDark),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Row _buildScheduleHeader(bool isLoading, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Jadwal Mendatang",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        if (!isLoading)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Lihat Semua",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color.fromRGBO(167, 227, 172, 1)
                    : const Color.fromRGBO(21, 116, 42, 1),
              ),
            ),
          ),
      ],
    );
  }

  Container _buildScheduleCard(JadwalModel data, bool isDark) {
    String tanggal = DateFormatter.format("dd", data.tanggal);
    String hari = DateFormatter.format("EEEE", data.tanggal);
    String nama = data.namaVenue;
    String waktuMulai = data.jamMulai.substring(0, 5);
    String waktuSelesai = data.jamSelesai.substring(0, 5);
    String? lapangan = data.lapangan;
    List<String> player = data.other.split(" ");
    String jarak = data.jarak;

    final Color primaryColor = isDark
        ? const Color(0xFF9BE59E)
        : const Color.fromRGBO(21, 116, 42, 1);

    final Color bgCard = isDark
        ? const Color(0xFF2C2C2C)
        : const Color.fromRGBO(231, 252, 233, 1);

    final Color bgDate = isDark
        ? const Color(0xFF3A3A3A)
        : const Color.fromRGBO(167, 227, 172, .4);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgDate,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              children: [
                Text(
                  tanggal,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                Text(
                  hari.toUpperCase(),
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nama,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        softWrap: true,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.location_solid,
                          color: isDark
                              ? Colors.grey[400]
                              : const Color.fromRGBO(163, 163, 163, 1),
                          size: 18,
                        ),
                        Text(
                          jarak,
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey[400]
                                : const Color.fromRGBO(163, 163, 163, 1),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "$waktuMulai - $waktuSelesai • $lapangan",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "(Main Bareng)",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.people_alt_outlined,
                      color: Colors.blue,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "with ${player[0]} & ${player.length - 1} others",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
