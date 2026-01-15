import 'package:flutter/material.dart';
import '../register_controller.dart';

class ActionButton extends StatelessWidget {
  final RegisterController controller;

  const ActionButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return controller.isLoading
        ? const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          )
        : SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              onPressed: controller.showVerificationField
                  ? () => controller.handleVerification(context)
                  : () => controller.handleRegister(context),
              child: Text(
                controller.showVerificationField ? "Verifikasi" : "Daftar",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          );
  }
}
