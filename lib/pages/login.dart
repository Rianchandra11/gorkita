import 'package:flutter/material.dart';
import 'package:uts_backend/database/database_service.dart';

import 'package:uts_backend/pages/register/register_page.dart';
import 'package:uts_backend/pages/forgot_password.dart';
import 'package:uts_backend/pages/home.dart';

class LoginPage extends StatefulWidget {
  final String? successMessage;

  const LoginPage({super.key, this.successMessage});

  // Factory method untuk login page dengan success message
  factory LoginPage.withSuccessMessage(String message) {
    return LoginPage(successMessage: message);
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State
  bool _obscurePassword = true;
  bool _isLoading = false;

  // API Service
  final ApiService _apiService = ApiService();

  // Colors
  final primary = const Color(0xFF4CAF50);
  final secondary = const Color(0xFF2196F3);
  final subtle = const Color(0xFF648765);
  final inputBg = const Color(0xFFF0F4F0);

  @override
  void initState() {
    super.initState();
    _showSuccessMessageIfAny();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: inputBg.withAlpha(200),
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Login Account",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
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
                  // Logo
                  SizedBox(
                    height: 400,
                    child: Image.asset(
                      "assets/img/man.png",
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported,
                            size: 120,
                            color: Colors.black26,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Masuk",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Email Input
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: subtle),
                      hintText: "Email atau Username",
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: subtle),
                      hintText: "Password",
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: subtle,
                        ),
                        onPressed:
                            () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                      ),
                    ),
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      child: Text(
                        "Lupa Password?",
                        style: TextStyle(color: primary),
                      ),
                    ),
                  ),

                  // Login Button
                  const SizedBox(height: 16),
                  _buildLoginButton(),

                  // Divider
                  const SizedBox(height: 24),
                  _buildDivider(),

                  // Social Login
                  const SizedBox(height: 24),
                  _buildSocialLogin(),

                  // Register Link
                  const SizedBox(height: 40),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        onPressed: _handleLogin,
        child: const Text(
          "Masuk",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Atau masuk dengan",
            style: TextStyle(color: subtle, fontSize: 13),
          ),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: inputBg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _showComingSoon('Google Sign-In'),
            icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
            label: const Text(
              "Google",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _showComingSoon('Facebook Sign-In'),
            icon: const Icon(Icons.facebook, size: 22, color: Colors.white),
            label: const Text(
              "Facebook",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Belum punya akun?", style: TextStyle(color: subtle)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              ),
          child: Text(
            "Daftar",
            style: TextStyle(fontWeight: FontWeight.bold, color: primary),
          ),
        ),
      ],
    );
  }

  // Handle login method
  Future<void> _handleLogin() async {
  if (!_validateLoginInput()) return;

  setState(() => _isLoading = true);

  try {
    // ✅ GUNAKAN HYBRID LOGIN, BUKAN loginUser
    final result = await _apiService.hybridLogin(
      _emailController.text,
      _passwordController.text,
    );

    if (result['success'] == true) {
      print('✅ Login berhasil dari: ${result['login_source']}');
      
      // Get user data
      final userResult = await _apiService.getUserById(result['user_id']);
      
      if (userResult['success'] == true) {
        _navigateToHome('Login berhasil!', result['user_id']);
      } else {
        _showMessage('Login berhasil tetapi gagal mengambil data user', Colors.orange);
        _navigateToHome('Login berhasil!', result['user_id']);
      }
    } else {
      _showMessage(result['message'] ?? 'Login gagal', Colors.red);
    }
  } catch (e) {
    _showMessage('Terjadi kesalahan: $e', Colors.red);
  } finally {
    setState(() => _isLoading = false);
  }
}

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  void _showSuccessMessageIfAny() {
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessage(widget.successMessage!, Colors.green);
      });
    }
  }

  // Validation methods
  bool _validateLoginInput() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Email dan password harus diisi', Colors.red);
      return false;
    }
    return true;
  }

  // Navigation methods
// Di LoginPage - method _navigateToHome
void _navigateToHome(String message, int userId) async {
  _showMessage(message, Colors.green);
  await Future.delayed(const Duration(milliseconds: 1500));
  
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => HomeScreen(id: userId), // Kirim userId ke HomeScreen
    ),
  );
}
  // UI methods
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera hadir!'),
        backgroundColor: primary,
      ),
    );
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}