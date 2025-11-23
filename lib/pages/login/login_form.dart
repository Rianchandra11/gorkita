import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final Color subtle;
  final Color inputBg;
  final Color primary;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.subtle,
    required this.inputBg,
    required this.primary,
    required this.onTogglePassword,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 45, 
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.email_outlined, color: primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Email",
                    hintStyle: TextStyle(color: subtle, fontSize: 12),
                    contentPadding: const EdgeInsets.only(bottom: 2),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, color: primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Password",
                    hintStyle: TextStyle(color: subtle, fontSize: 12),
                    contentPadding: const EdgeInsets.only(bottom: 2),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              GestureDetector(
                onTap: onTogglePassword,
                child: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: subtle,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


