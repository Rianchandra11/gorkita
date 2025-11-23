import 'package:flutter/material.dart';

class RegisterLink extends StatelessWidget {
  final Color subtle;
  final Color primary;
  final VoidCallback onRegister;

  const RegisterLink({
    super.key,
    required this.subtle,
    required this.primary,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Belum punya akun?", style: TextStyle(color: subtle)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRegister,
          child: Text(
            "Daftar",
            style: TextStyle(fontWeight: FontWeight.bold, color: primary),
          ),
        ),
      ],
    );
  }
}