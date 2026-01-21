import 'package:flutter/material.dart';
import 'package:uts_backend/services/account_manager.dart';
import 'package:uts_backend/pages/register/register_page.dart';
import 'package:uts_backend/pages/forget_password.dart';
import 'package:uts_backend/pages/home.dart';

class LoginPage extends StatefulWidget {
  final String? successMessage;

  const LoginPage({super.key, this.successMessage});

  factory LoginPage.withSuccessMessage(String message) {
    return LoginPage(successMessage: message);
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isNavigating = false;

  AnimationController? _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;

  // Optimized: Use AccountManager
  final AccountManager _accountManager = AccountManager();

  // 🎨 Modern Green Theme
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color bgColor = Color(0xFFF5F7FA);
  static const Color cardColor = Color(
    0xFFF7F8FA,
  ); // Soft white-grey, simulates opacity
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color inputBg = Color(0xFFF8FAFB);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController!, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController!, curve: Curves.easeOutCubic),
        );

    _animController!.forward();
    _showSuccessMessageIfAny();
  }

  @override
  void dispose() {
    _animController?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSuccessMessageIfAny() {
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackbar(widget.successMessage!, primaryLight);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle case when animations are not ready yet
    if (_fadeAnim == null || _slideAnim == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim!,
          child: SlideTransition(
            position: _slideAnim!,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const SizedBox(height: 16),
                  _buildLogoSection(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildLoginCard()),
                  const SizedBox(height: 14),
                  _buildSocialLogin(),
                  const SizedBox(height: 14),
                  _buildRegisterLink(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // 🎨 LOGO SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 3D Logo Container
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66BB6A), primaryDark],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: primary.withAlpha(35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              "assets/img/man.png",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Selamat Datang!",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Masuk untuk melanjutkan",
          style: TextStyle(
            fontSize: 11,
            color: textMuted.withAlpha(8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor, // Soft white-grey, simulates opacity
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCompactTextField(
              controller: _emailController,
              hint: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            _buildCompactTextField(
              controller: _passwordController,
              hint: "Password",
              icon: Icons.lock_outline_rounded,
              isPassword: true,
            ),
            const SizedBox(height: 6),
            _buildForgotPassword(),
            const SizedBox(height: 12),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            icon,
            color: Color(0xFFB0B4BA),
            size: 18,
          ), // Muted grey, no opacity
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: isPassword ? _obscurePassword : false,
              style: const TextStyle(
                fontSize: 13,
                color: textDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Color(0xFFB0B4BA), // Muted grey, no opacity
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (isPassword)
            GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Color(0xFFB0B4BA), // Muted grey, no opacity
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maaf fitur ini sedang dikembangkan !')),
          );
        },
        // onTap: _handleForgotPassword,
        child: const Text(
          "Lupa Password?",
          style: TextStyle(
            color: primary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF66BB6A), primaryDark],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: primary.withAlpha(35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Masuk",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // 🎨 SOCIAL LOGIN
  // ════════════════════════════════════════════════════════════

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.grey.shade300],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                "atau masuk dengan",
                style: TextStyle(
                  color: textMuted.withAlpha(7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade300, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildGoogleButton(),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _handleGoogleSignIn,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/google.png",
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.g_mobiledata_rounded,
                color: Color(0xFFDB4437),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Masuk dengan Google",
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // 🎨 REGISTER LINK
  // ════════════════════════════════════════════════════════════

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah punya akun? ",
          style: TextStyle(color: textMuted.withAlpha(204), fontSize: 12),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          ),
          child: const Text(
            "Daftar Sekarang",
            style: TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // 🔧 HELPER WIDGETS
  // ════════════════════════════════════════════════════════════

  // ════════════════════════════════════════════════════════════
  // 🔧 HANDLERS
  // ════════════════════════════════════════════════════════════

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HalamanAturUlangPassword(email: ''),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Email dan password harus diisi", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Optimized: Use AccountManager
      final result = await _accountManager.login(email, password);

      if (result['success'] == true) {
        final userId = result['user_id'] ?? 0;
        _showSnackbar("Login berhasil!", primaryLight);

        // Optimized: Faster navigation (reduce delay)
        await Future.delayed(const Duration(milliseconds: 400));
        _navigateToHome(userId);
      } else {
        _showSnackbar(result['message'] ?? 'Login gagal', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Terjadi kesalahan: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading || _isNavigating) return;

    setState(() => _isLoading = true);

    try {
      // Optimized: Use AccountManager
      final result = await _accountManager.googleLogin();

      if (result['success'] == true) {
        final userId = result['user_id'] ?? 0;
        final isNewUser = result['is_new_user'] ?? false;

        _showSnackbar(
          isNewUser ? "Registrasi Google berhasil!" : "Login Google berhasil!",
          primaryLight,
        );

        // Optimized: Faster navigation
        await Future.delayed(const Duration(milliseconds: 400));
        _navigateToHome(userId);
      } else {
        _showSnackbar(result['message'] ?? 'Google Sign-In gagal', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Google Sign-In error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome(int userId) {
    if (_isNavigating) return;
    _isNavigating = true;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(id: userId)),
      (route) => false,
    );
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
