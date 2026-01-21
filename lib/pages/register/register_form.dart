import 'package:flutter/material.dart';
import 'package:uts_backend/widgets/phone_input_field.dart';
import 'register_controller.dart';

class RegisterForm extends StatelessWidget {
  final RegisterController controller;

  const RegisterForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Nama Lengkap
        _buatKampInput(
          kontroler: controller.nameController,
          petunjuk: "Nama Lengkap",
          ikon: Icons.person_outline,
          controller: controller,
        ),
        const SizedBox(height: 12),

        // Email
        _buatKampInput(
          kontroler: controller.emailController,
          petunjuk: "Email",
          ikon: Icons.email_outlined,
          controller: controller,
          tipeKeyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),

        // Nomor Telepon dengan Country Code
        PhoneInputField(
          controller: controller.phoneController,
          hintText: "Nomor Telepon",
          primaryColor: controller.primary,
          backgroundColor: const Color(0xFFF5F5F5),
        ),
        const SizedBox(height: 12),

        // Password
        _buatKampPassword(
          kontroler: controller.passwordController,
          petunjuk: "Password",
          sembunyikan: controller.obscurePassword,
          onToggle: controller.togglePasswordVisibility,
          controller: controller,
        ),
        const SizedBox(height: 12),

        // Konfirmasi Password
        _buatKampPassword(
          kontroler: controller.confirmPasswordController,
          petunjuk: "Konfirmasi Password",
          sembunyikan: controller.obscureConfirmPassword,
          onToggle: controller.toggleConfirmPasswordVisibility,
          controller: controller,
        ),
      ],
    );
  }

  /// Build Kamp Input
  Widget _buatKampInput({
    required TextEditingController kontroler,
    required String petunjuk,
    required IconData ikon,
    required RegisterController controller,
    TextInputType tipeKeyboard = TextInputType.text,
  }) {
    return TextField(
      controller: kontroler,
      keyboardType: tipeKeyboard,
      decoration: InputDecoration(
        prefixIcon: Icon(ikon, color: controller.subtle, size: 18),
        hintText: petunjuk,
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
    );
  }

  /// Build Kamp Password
  Widget _buatKampPassword({
    required TextEditingController kontroler,
    required String petunjuk,
    required bool sembunyikan,
    required VoidCallback onToggle,
    required RegisterController controller,
  }) {
    return TextField(
      controller: kontroler,
      obscureText: sembunyikan,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: controller.subtle,
          size: 18,
        ),
        hintText: petunjuk,
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
        suffixIcon: IconButton(
          icon: Icon(
            sembunyikan
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: controller.subtle,
            size: 18,
          ),
          onPressed: onToggle,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
