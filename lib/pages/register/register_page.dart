import 'package:flutter/material.dart';
import 'package:uts_backend/pages/register/register_controller.dart';
import 'package:uts_backend/pages/register/register_form.dart';
import 'package:uts_backend/pages/register/verification_form.dart';
import 'package:uts_backend/pages/register/widgets/action_button.dart';
import 'package:uts_backend/pages/register/widgets/social_login.dart';

import 'widgets/link_footer.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterController _controller = RegisterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _controller.inputBg.withAlpha(200),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _controller.handleBackPressed(context),
        ),
        centerTitle: false,
        title: const Text(
          "Daftar Akun",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 16),
                  _buildTitle(),
                  const SizedBox(height: 32),
                  _buildForms(),
                  const SizedBox(height: 24),
                  ActionButton(controller: _controller),
                  if (_controller.showVerificationField) ...[
                    const SizedBox(height: 16),
                    _buildResendButton(),
                  ],
                  if (!_controller.showVerificationField) 
                    SocialLogin(controller: _controller),
                  const SizedBox(height: 40),
                  LinkFooter(controller: _controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      height: 200,
      child: Image.asset(
        "assets/img/man.png",
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.image_not_supported,
          size: 120,
          color: Colors.black26,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _controller.showVerificationField
                ? "Verifikasi Email"
                : "Daftar Akun Baru",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForms() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _controller.showVerificationField
          ? VerificationForm(controller: _controller)
          : RegisterForm(controller: _controller),
    );
  }

  Widget _buildResendButton() {
    return TextButton(
      onPressed: () => _controller.resendCode(context),
      child: const Text("Kirim ulang kode"),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}