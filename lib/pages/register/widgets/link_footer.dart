import 'package:flutter/material.dart';
import '../register_controller.dart';

class LinkFooter extends StatelessWidget {
  final RegisterController controller;

  const LinkFooter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah punya akun?",
          style: TextStyle(color: controller.subtle),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => controller.navigateToLogin(context),
          child: Text(
            "Masuk",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: controller.primary
            ),
          ),
        ),
      ],
    );
  }
}