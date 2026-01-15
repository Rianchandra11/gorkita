import 'package:flutter/material.dart';
import 'register_controller.dart';

class VerificationForm extends StatelessWidget {
  final RegisterController controller;

  const VerificationForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: controller.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              const Text(
                "Kode verifikasi telah dikirim ke:",
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                controller.emailController.text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Cek email Anda untuk kode verifikasi",
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Kode Verifikasi Input
        TextField(
          controller: controller.verificationCodeController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.verified_user_outlined,
              color: controller.subtle,
              size: 18,
            ),
            hintText: "Masukkan 6 digit kode",
            hintStyle: const TextStyle(fontSize: 13),
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: controller.primary, width: 1.5),
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Kode berlaku 10 menit",
          style: TextStyle(color: Colors.grey[600], fontSize: 11),
        ),
      ],
    );
  }
}
