import 'package:flutter/material.dart';

class QuickMenuItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final VoidCallback onTap;
  const QuickMenuItem({
    super.key,
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: Color.fromRGBO(21, 116, 42, 1),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Color.fromRGBO(21, 116, 42, 1)),
            ),

            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
