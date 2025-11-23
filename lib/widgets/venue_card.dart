import 'package:flutter/material.dart';
import 'package:uts_backend/helper/number_formatter.dart';
import 'package:uts_backend/pages/venue_detail_screen.dart';

class VenueCard extends StatelessWidget {
  final int id;
  final String url;
  final String nama;
  final String kota;
  final double rating;
  final int jumlahrating;
  final int harga;
  final bool isDark; 

  const VenueCard({
    super.key,
    required this.id,
    required this.url,
    required this.nama,
    required this.kota,
    required this.harga,
    required this.jumlahrating,
    required this.rating,
    required this.isDark, // WAJIB!
  });

  @override
  Widget build(BuildContext context) {
    // Warna dinamis berdasarkan isDark
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : Colors.black87;
    final Color textSecondary = isDark ? Colors.white70 : const Color.fromRGBO(76, 76, 76, 1);
    final Color shadowColor = isDark ? Colors.black45 : Colors.black12;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => VenueDetailScreen(id: id)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cardColor,
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.black12,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GAMBAR
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    url,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  ),
                ),

                // ISI CARD
                SizedBox(
                  height: 150,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // INFO ATAS
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kota $kota",
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nama,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                                const SizedBox(width: 2),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  ' ($jumlahrating)',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // HARGA
                        Text(
                          '${NumberFormatter.currency(harga)} / sesi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary, // IKUT TEMA!
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}