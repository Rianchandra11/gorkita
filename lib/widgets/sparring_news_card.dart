import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:uts_backend/helper/date_formatter.dart';

class SparringNewsCard extends StatelessWidget {
  final DateTime tanggal;
  final String jam;
  final String kota;
  final String player1A;
  final String? player1B;
  final String player2A;
  final String? player2B;
  final String kategori;
  final bool isDark;
  final List<int> skorPenantang;
  final List<int> skorPenerima;

  const SparringNewsCard({
    super.key,
    required this.jam,
    required this.kategori,
    required this.kota,
    required this.player1A,
    required this.player2A,
    required this.player1B,
    required this.player2B,
    required this.tanggal,
    required this.isDark,
    required this.skorPenantang,
    required this.skorPenerima,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : Colors.black87;
    final Color textSecondary = isDark
        ? Colors.white70
        : const Color.fromRGBO(76, 76, 76, 1);
    final Color dividerColor = isDark ? Colors.grey[700]! : Colors.grey[400]!;
    final Color kategoriBg = isDark ? Colors.grey[800]! : Colors.grey.shade100;
    final Color borderColor = isDark ? Colors.white24 : Colors.black12;
    final Color shadowColor = isDark ? Colors.black45 : Colors.black12;
    final Color verticalDividerColor = isDark ? Colors.white30 : Colors.black26;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cardColor,
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: 340,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DottedBorder(
                options: CustomPathDottedBorderOptions(
                  padding: const EdgeInsets.only(bottom: 4),
                  dashPattern: const [8, 4],
                  color: dividerColor,
                  customPath: (size) => Path()
                    ..moveTo(0, size.height)
                    ..relativeLineTo(size.width, 0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${DateFormatter.format("EEE, dd MMM yyyy", tanggal)}, $jam',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    Text(
                      'Kota $kota',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 106,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScoreBoard(
                      player1A,
                      player1B,
                      skorPenantang,
                      skorPenerima,
                      textPrimary,
                    ),
                    _buildScoreBoard(
                      player2A,
                      player2B,
                      skorPenerima,
                      skorPenantang,
                      textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildKategoriChip(
                kategori.split(" ").isNotEmpty
                    ? kategori.split(" ")[0]
                    : kategori,
                kategoriBg,
                textPrimary,
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 16,
                child: VerticalDivider(
                  color: verticalDividerColor,
                  thickness: 1,
                  width: 2,
                ),
              ),
              const SizedBox(width: 6),
              _buildKategoriChip(
                kategori.split(" ").length > 1 ? kategori.split(" ")[1] : "",
                kategoriBg,
                textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriChip(String text, Color bgColor, Color textColor) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 13, color: textColor)),
    );
  }

  Widget _buildScoreBoard(
    String player1,
    String? player2,
    List<int> teamScore,
    List<int> opponentScore,
    Color textColor,
  ) {
    final bool ganda = player2 != null;

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
                    width: 180,
                    height: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            player1,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            player2,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  ProfilePicture(
                    name: player1,
                    radius: 12,
                    fontsize: 12,
                    count: 1,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 190,
                    child: Text(
                      player1,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),

        Row(
          spacing: 18,
          children: [
            for (int index = 0; index < teamScore.length; index++) ...[
              Text(
                "${teamScore[index]}",
                style: TextStyle(
                  fontWeight:
                      teamScore[index] ==
                          max(teamScore[index], opponentScore[index])
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
