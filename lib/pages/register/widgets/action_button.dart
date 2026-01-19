import 'package:flutter/material.dart';
import '../register_controller.dart';

class ActionButton extends StatelessWidget {
  final RegisterController controller;

  const ActionButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return controller.isLoading
        ? const CircularProgressIndicator()
        : SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              onPressed: () => controller.handleRegister(context),
              child: const Text(
                "Daftar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          );
  }
}