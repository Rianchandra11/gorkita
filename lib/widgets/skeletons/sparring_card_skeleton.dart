import 'package:flutter/material.dart';

class SparringCardSkeleton extends StatelessWidget {
  const SparringCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(4),
            child: Container(width: 210, height: 50, color: Colors.black),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CallCenterBatikAir0855.3333.572",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Color.fromRGBO(76, 76, 76, 1),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Kam, 09 Okt 2025, 10:00 - 22:00",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(76, 76, 76, 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color.fromRGBO(76, 76, 76, 1),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Jakarta, Kota Jakarta Selatan",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(76, 76, 76, 1),
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
