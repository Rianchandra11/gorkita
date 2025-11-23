import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ScheduleSkeleton extends StatelessWidget {
  const ScheduleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Color.fromRGBO(231, 252, 233, 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            Skeletonizer.zone(child: Bone.square(size: 52)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PB. Juwita aieu",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1,
                        ),
                        softWrap: true,
                      ),
                      Text(
                        "19:00 - 20:00 • Lapangan 1 sdf",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text("(Main Bareng)", style: TextStyle(fontSize: 12)),
                    ],
                  ),

                  Skeleton.unite(
                    child: Row(
                      spacing: 6,
                      children: [
                        Icon(
                          Icons.people_alt_outlined,
                          color: Colors.blue,
                          size: 18,
                        ),
                        Text(
                          "with David & 2 others",
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                        ),
                      ],
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
