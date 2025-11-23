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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: controller.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                "Kode verifikasi telah dikirim ke:",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                controller.emailController.text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Cek email Anda untuk mendapatkan kode verifikasi",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Kode Verifikasi Input
        TextField(
          controller: controller.verificationCodeController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.verified_user, color: controller.subtle),
            hintText: "Masukkan 6 digit kode verifikasi",
            filled: true,
            fillColor: controller.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: controller.primary, width: 2),
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 8),
        Text(
          "Kode berlaku 10 menit",
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}