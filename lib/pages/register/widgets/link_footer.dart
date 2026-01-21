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
          controller.showVerificationField ? "Kembali ke " : "Sudah punya akun? ",
          style: TextStyle(color: controller.subtle, fontSize: 12),
        ),
        GestureDetector(
          onTap: controller.showVerificationField
              ? () => controller.showVerificationField = false
              : () => controller.navigateToLogin(context),
          child: Text(
            controller.showVerificationField ? "form daftar" : "Masuk",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: controller.primary,
            ),
          ),
        ),
      ],
    );
  }
}