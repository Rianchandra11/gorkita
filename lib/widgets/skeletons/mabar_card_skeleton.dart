import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MabarCardSkeleton extends StatelessWidget {
  const MabarCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
          ],
          color: Colors.white,
        ),
        width: 320,
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mabar Badminton HahaHihi cihuy",
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "Level : Newbie - Itermediate",
              style: TextStyle(color: Color.fromRGBO(76, 76, 76, 1)),
            ),
            SizedBox(height: 12),
            Row(
              spacing: 6,

              children: [
                Icon(
                  Icons.calendar_month,
                  color: Color.fromRGBO(76, 76, 76, 1),
                ),
                Text(
                  "Sel, 07 Okt 2025, 20:00 - 22:00",
                  style: TextStyle(color: Color.fromRGBO(76, 76, 76, 1)),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              spacing: 6,
              children: [
                Icon(Icons.location_pin, color: Color.fromRGBO(76, 76, 76, 1)),
                Text(
                  "Maincourt, Kota Jakarta Pusat",
                  style: TextStyle(color: Color.fromRGBO(76, 76, 76, 1)),
                ),
              ],
            ),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(4),
              child: Container(width: 230, height: 40, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
