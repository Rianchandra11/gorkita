import 'package:flutter/material.dart';
import 'register_controller.dart';

class RegisterForm extends StatelessWidget {
  final RegisterController controller;

  const RegisterForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Nama Lengkap
        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person_outline, color: controller.subtle),
            hintText: "Nama Lengkap",
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
        ),
        const SizedBox(height: 16),

        // Email
        TextField(
          controller: controller.emailController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email_outlined, color: controller.subtle),
            hintText: "Email",
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
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // Nomor Telepon
        TextField(
          controller: controller.phoneController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.phone_outlined, color: controller.subtle),
            hintText: "Nomor Telepon",
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
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.passwordController,
          obscureText: controller.obscurePassword,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outlined, color: controller.subtle),
            hintText: "Password",
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
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: controller.subtle,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Konfirmasi Password
        TextField(
          controller: controller.confirmPasswordController,
          obscureText: controller.obscureConfirmPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outlined, color: controller.subtle),
            hintText: "Konfirmasi Password",
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
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: controller.subtle,
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }
}