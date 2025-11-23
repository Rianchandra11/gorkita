import 'package:flutter/material.dart';
import 'package:uts_backend/database/database_service.dart';
import 'package:uts_backend/pages/login/login_form.dart';
import 'package:uts_backend/pages/login/widgets/login_buttons.dart';
import 'package:uts_backend/pages/register/register_page.dart';
import 'package:uts_backend/pages/forgot_password.dart';
import 'package:uts_backend/pages/home.dart';
import 'widgets/social_login.dart';
import 'widgets/divider_with_text.dart';
import 'widgets/register_link.dart';

class LoginPage extends StatefulWidget {
  final String? successMessage;

  const LoginPage({super.key, this.successMessage});

  factory LoginPage.withSuccessMessage(String message) {
    return LoginPage(successMessage: message);
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isNavigating = true;

  final ApiService _apiService = ApiService();

  final primary = const Color(0xFF4CAF50);
  final secondary = const Color(0xFF2196F3);
  final subtle = const Color(0xFF648765);
  final inputBg = const Color(0xFFF8F9FA);
  final backgroundColor = const Color(0xFFFEFEFE);

  @override
  void initState() {
    super.initState();
    _showSuccessMessageIfAny();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
          color: Colors.red.withOpacity(0.1), 
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: _buildCompactAppBar(),
              ),
              SizedBox(
                height: 120,
                child: _buildCompactLogo(),
              ),
              Expanded(
                child: _buildStrictNoScrollContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back, color: primary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Login Account",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLogo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Image.asset(
        "assets/img/man.png",
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_outline,
            size: 28,
            color: subtle,
          ),
        ),
      ),
    );
  }

  Widget _buildStrictNoScrollContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(), 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), 
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 20),
                    LoginForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      subtle: subtle,
                      inputBg: inputBg,
                      primary: primary,
                      onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                      onForgotPassword: _handleForgotPassword,
                    ),
                    const SizedBox(height: 16),
                    LoginButton(
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 12),
                    _buildForgotPassword(),
                    const SizedBox(height: 16),
                    DividerWithText(
                      text: "Atau masuk dengan", 
                      subtle: subtle,
                    ),
                    const SizedBox(height: 12),
                    SocialLogin(
                      subtle: subtle,
                      inputBg: inputBg,
                      secondary: secondary,
                      onGooglePressed: () => _showComingSoon('Google Sign-In'),
                      onFacebookPressed: () => _showComingSoon('Facebook Sign-In'),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20, top: 10),
              child: RegisterLink(
                subtle: subtle,
                primary: primary,
                onRegister: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Text(
          "Selamat Datang",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Silakan masuk ke akun Anda", 
          style: TextStyle(
            fontSize: 12, 
            color: subtle,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _handleForgotPassword,
        child: Text(
          "Lupa Password?",
          style: TextStyle(
            color: primary,
            fontSize: 11, 
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    
    if (!_validateLoginInput()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.hybridLogin(
        _emailController.text,
        _passwordController.text,
      );

      if (result['success'] == true) {
        print('✅ Login berhasil dari: ${result['login_source']}');
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  bool _validateLoginInput() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Email dan password harus diisi', Colors.red);
      return false;
    }
    return true;
  }

  void _navigateToHome(String message, int userId) async {
    if (_isNavigating) return;
    _isNavigating = true;
    
    _showMessage(message, Colors.green);
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(id: userId),
        ),
      );
    }
    
    _isNavigating = false;
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera hadir!'),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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