import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class SparringNewsCardSkeleton extends StatelessWidget {
  final String tanggal = "Rabu, 09 Oktober 2025";
  final String jam = "19:00";
  final String kota = "Bandung";
  final String player1A = "rian123 Tzy 123 lauba";
  final String? player1B = null;
  final String player2A = "rian123 Tzy 123 lauba";
  final String? player2B = null;
  final String skorSet1 = "21-18";
  final String? skorSet2 = "17-21";
  final String? skorSet3 = "21-16";
  final String kategori = "Tunggal Pria";

  const SparringNewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    List<int>? getSetList(String? skorSet) {
      if (skorSet == null) return null;
      final List<String> skorList = skorSet.split("-");
      return [int.parse(skorList[0]), int.parse(skorList[1])];
    }

    final List<String> fullDate = tanggal.split(",");
    final String hari = fullDate[0].substring(0, 3);
    final String date = fullDate[1].replaceFirst(" ", "");
    final List<int>? set1List = getSetList(skorSet1);
    final List<int>? set2List = getSetList(skorSet2);
    final List<int>? set3List = getSetList(skorSet3);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
        ],
        color: Colors.white,
      ),
      width: 360,
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: 12,
            children: [
              DottedBorder(
                options: CustomPathDottedBorderOptions(
                  padding: EdgeInsets.only(bottom: 6),
                  dashPattern: [8, 4],
                  color: Colors.grey[400]!,
                  customPath:
                      (size) =>
                          Path()
                            ..moveTo(0, size.height)
                            ..relativeLineTo(size.width, 0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$hari, $date, $jam',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(76, 76, 76, 1),
                      ),
                    ),
                    Text(
                      'Kota $kota',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(76, 76, 76, 1),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 106,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScoreBoard(
                      player1A,
                      player1B,
                      set1List,
                      set2List,
                      set3List,
                      1,
                    ),
                    _buildScoreBoard(
                      player2A,
                      player2B,
                      set1List,
                      set2List,
                      set3List,
                      2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  kategori.split(" ")[0],
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
              SizedBox(
                height: 16,
                child: VerticalDivider(color: Colors.black26, width: 2),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  kategori.split(" ")[1],
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row _buildScoreBoard(
    String player1,
    String? player2,
    List<int>? set1List,
    List<int>? set2List,
    List<int>? set3List,
    int tim,
  ) {
    final bool ganda = player2 != null ? true : false;
    tim = tim - 1;
    final List<dynamic> teamScore = [
      set1List?[tim],
      set2List?[tim],
      set3List?[tim],
    ];
    final List<dynamic> score = [set1List, set2List, set3List];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ganda
            ? Row(
              children: [
                SizedBox(
                  width: 38,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 14,
                        child: ProfilePicture(
                          name: player1,
                          radius: 12,
                          fontsize: 12,
                          count: 1,
                        ),
                      ),
                      ProfilePicture(
                        name: player2,
                        radius: 12,
                        fontsize: 12,
                        count: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 190,
                  height: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          player1,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          player2,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
            : Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(16),
                  child: Container(width: 32, height: 32, color: Colors.black),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 190,
                  child: Text(
                    player1,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
        Row(
          spacing: 18,
          children: List.generate(teamScore.length, (index) {
            if (teamScore[index] != null) {
              int setPoint = max(score[index][0], score[index][1]);
              return Text(
                "${teamScore[index]}",
                style: TextStyle(
                  fontWeight:
                      teamScore[index] == setPoint
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ),
      ],
    );
  }
}
