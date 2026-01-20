import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:uts_backend/helper/date_formatter.dart';
import 'package:uts_backend/model/mabar_model.dart';
import 'package:uts_backend/repository/mabar_repository.dart';
import 'package:uts_backend/widgets/skeletons/mabar_card_skeleton.dart';

class MabarCard extends StatelessWidget {
  final bool isDark;
  const MabarCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: MabarRepository.get(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMabarHeader(true),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 194,
                child: ListView.builder(
                  itemBuilder: (context, index) => const MabarCardSkeleton(),
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ],
          );
        }

        final listData = asyncSnapshot.data ?? [];

        if (listData.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMabarHeader(false),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Center(
                  child: Text(
                    "Belum ada mabar di areamu 😅",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMabarHeader(false),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 194,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return _buildMabarCard(listData[index]);
                },
                itemCount: listData.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ],
        );
      },
    );
  }

  Padding _buildMabarHeader(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Main bareng di areamu",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          if (!isLoading)
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_circle_right_sharp,
                color: Color.fromRGBO(21, 116, 42, 1),
              ),
            ),
        ],
      ),
    );
  }

  Container _buildMabarCard(MabarModel data) {
    final String judul = data.judul!;
    final String levelMinimum = data.levelMinimum!;
    final String? levelMaksimum = data.levelMaksimum;
    final String nama = data.venue!.nama!;
    final String kota = data.venue!.kota!;
    final DateTime tanggal = data.tanggal!;
    final String jamMulai = data.jamMulai!.substring(0, 5);
    final String jamSelesai = data.jamSelesai!.substring(0, 5);
    final String host = data.participants![0].name!;
    final int capacity = data.capacity!;
    final List<String> listRegistered = data.participants!
        .skip(1)
        .map((e) => e.name!)
        .toList();

    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark
        ? Colors.white
        : const Color.fromRGBO(76, 76, 76, 1);
    final Color subText = isDark ? Colors.white70 : Colors.grey[600]!;
    final Color borderColor = isDark ? Colors.white24 : Colors.black12;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cardColor,
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: isDark
            ? []
            : [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
      ),
      width: 320,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "Level: $levelMinimum${levelMaksimum != null ? ' - $levelMaksimum' : ''}",
            style: TextStyle(color: subText),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_month, color: subText, size: 18),
              const SizedBox(width: 4),
              Text(
                "${DateFormatter.format("EEE, dd MMM yyyy", tanggal)}, $jamMulai - $jamSelesai",
                style: TextStyle(color: subText, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_pin, color: subText, size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "$nama, Kota $kota",
                  style: TextStyle(color: subText, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ProfilePicture(name: host, radius: 20, fontsize: 16, count: 2),
              ...List.generate(2, (int index) {
                if (listRegistered.length - 1 >= index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: ProfilePicture(
                      name: listRegistered[index],
                      radius: 20,
                      fontsize: 16,
                      count: 2,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: DottedBorder(
                      options: CircularDottedBorderOptions(
                        padding: const EdgeInsets.all(10),
                        strokeWidth: 2,
                        dashPattern: const [6, 4],
                        color: subText,
                      ),
                      child: const SizedBox(width: 20, height: 20),
                    ),
                  );
                }
              }),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: DottedBorder(
                  options: CircularDottedBorderOptions(
                    padding: const EdgeInsets.all(10),
                    strokeWidth: 2,
                    dashPattern: const [6, 4],
                    color: subText,
                  ),
                  child: Text(
                    "+${capacity - 3}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: subText,
                    ),
                  ),
                ),
              ),
              Text(" • ", style: TextStyle(color: subText)),
              Text(
                "${listRegistered.length}/$capacity",
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
