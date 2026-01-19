import 'package:flutter/material.dart';
import 'package:uts_backend/pages/register/register_controller.dart';
import 'package:uts_backend/pages/register/register_form.dart';
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
          onPressed: () => Navigator.pop(context),
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
                  RegisterForm(controller: _controller),
                  const SizedBox(height: 24),
                  ActionButton(controller: _controller),
                  const SizedBox(height: 16),
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
    return const Text(
      "Daftar Akun Baru",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}