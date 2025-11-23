import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:uts_backend/helper/date_formatter.dart';

class SparringCard extends StatelessWidget {
  final String player1;
  final String? player2;
  final String namaTim;
  final DateTime tanggal;
  final String minimumAvailableTime;
  final String maximumAvailableTime;
  final String provinsi;
  final String kota;
  final String kategori;
  final bool isDark;

  const SparringCard({
    super.key,
    required this.kota,
    required this.maximumAvailableTime,
    required this.minimumAvailableTime,
    required this.namaTim,
    required this.player1,
    required this.player2,
    required this.provinsi,
    required this.tanggal,
    required this.kategori,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : Colors.black87;
    final Color textSecondary = isDark ? Colors.white70 : const Color.fromRGBO(76, 76, 76, 1);
    final Color vsBgColor = isDark ? Colors.grey[700]! : Colors.grey.shade200;
    final Color kategoriBg = isDark ? Colors.grey[800]! : Colors.grey.shade100;
    final Color borderColor = isDark ? Colors.white24 : Colors.black12;
    final Color shadowColor = isDark ? Colors.black45 : Colors.black12;
    final Color dottedColor = isDark ? Colors.white60 : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      width: 320,
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
      child: Column(
        children: [
          Row(
            children: [
              player2 == null
                  ? ProfilePicture(
                      random: true,
                      name: player1,
                      radius: 24,
                      fontsize: 18,
                      count: 2,
                    )
                  : SizedBox(
                      width: 80,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 32,
                            child: ProfilePicture(
                              random: true,
                              name: player1,
                              radius: 24,
                              fontsize: 18,
                              count: 2,
                            ),
                          ),
                          ProfilePicture(
                            random: true,
                            name: player2!,
                            radius: 24,
                            fontsize: 18,
                            count: 2,
                          ),
                        ],
                      ),
                    ),

              const SizedBox(width: 16),

              // "vs"
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: vsBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "vs",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              player2 == null
                  ? _buildDottedPlayer(dottedColor)
                  : SizedBox(
                      width: 80,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 32,
                            child: _buildDottedPlayer(dottedColor),
                          ),
                          _buildDottedPlayer(dottedColor),
                        ],
                      ),
                    ),
            ],
          ),

          const SizedBox(height: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                namaTim,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    "${DateFormatter.format("EEE, dd MMM yyyy", tanggal)} | $minimumAvailableTime - $maximumAvailableTime",
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "$provinsi, Kota $kota",
                      style: TextStyle(fontSize: 14, color: textSecondary),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: kategoriBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  kategori,
                  style: TextStyle(fontSize: 13, color: textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDottedPlayer(Color color) {
    return DottedBorder(
      options: CircularDottedBorderOptions(
        dashPattern: const [6, 3],
        color: color,
        strokeWidth: 1.5,
      ),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 20,
        child: Icon(Icons.question_mark, color: color, size: 20),
      ),
    );
  }
}