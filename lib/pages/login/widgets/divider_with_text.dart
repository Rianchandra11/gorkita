import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final Color subtle;

  const DividerWithText({
    super.key,
    required this.text,
    required this.subtle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            text,
            style: TextStyle(color: subtle, fontSize: 13),
          ),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }
}