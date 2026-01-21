import 'package:flutter/material.dart';
import 'package:uts_backend/services/account_manager.dart';
import 'package:uts_backend/pages/login/login_page.dart';
import 'package:uts_backend/widgets/phone_input_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  AnimationController? _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;

  // Optimized: Use AccountManager
  final AccountManager _accountManager = AccountManager();

  // 🎨 Modern Green Theme (sama dengan login)
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color bgColor = Color(0xFFF5F7FA);
  static const Color cardColor = Color(0xFFF7F8FA); // Soft white-grey, simulates opacity
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
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController!, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController!, curve: Curves.easeOutCubic),
    );

    _animController!.forward();
  }

  @override
  void dispose() {
    _animController?.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                  const SizedBox(height: 8),
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildLogoSection(),
                  const SizedBox(height: 10),
                  Expanded(child: _buildRegisterCard()),
                  const SizedBox(height: 8),
                  _buildSocialLogin(),
                  const SizedBox(height: 8),
                  _buildLoginLink(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // 🎨 HEADER
  // ════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Row(
      children: [
        _build3DButton(
          child: const Icon(Icons.arrow_back_ios_rounded, size: 16),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          ),
          size: 36,
        ),
        const SizedBox(width: 12),
        const Text(
          "Daftar",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // 🎨 LOGO SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66BB6A), primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primary.withAlpha(35),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              "assets/img/man.png",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person_add_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Buat Akun Baru",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Daftar untuk memulai",
          style: TextStyle(
            fontSize: 11,
            color: textMuted.withAlpha(8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


  Widget _buildRegisterCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              controller: _nameController,
              hint: "Nama Lengkap",
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 6),
            _buildCompactTextField(
              controller: _emailController,
              hint: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 6),
            PhoneInputField(
              controller: _phoneController,
              hintText: "Nomor Telepon",
              primaryColor: primary,
              backgroundColor: inputBg,
              height: 44,
              fontSize: 12,
            ),
            const SizedBox(height: 6),
            _buildCompactTextField(
              controller: _passwordController,
              hint: "Password",
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              obscure: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 6),
            _buildCompactTextField(
              controller: _confirmPasswordController,
              hint: "Konfirmasi Password",
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              obscure: _obscureConfirmPassword,
              onToggle: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            const SizedBox(height: 10),
            _buildRegisterButton(),
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
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, color: Color(0xFFB0B4BA), size: 16), // Muted grey, no opacity
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: isPassword ? obscure : false,
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
          if (isPassword && onToggle != null)
            GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  obscure
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

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleRegister,
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
              color: primary.withAlpha(89),
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
                  "Daftar Sekarang",
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
                "atau daftar dengan",
                style: TextStyle(
                  color: textMuted.withAlpha(179),
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
        const SizedBox(height: 10),
        _buildGoogleButton(),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _handleGoogleSignIn,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
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
              width: 18,
              height: 18,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.g_mobiledata_rounded,
                color: Color(0xFFDB4437),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Daftar dengan Google",
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // 🎨 LOGIN LINK
  // ════════════════════════════════════════════════════════════

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah punya akun? ",
          style: TextStyle(
            color: textMuted.withAlpha(204),
            fontSize: 12,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          ),
          child: const Text(
            "Masuk Sekarang",
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

  Widget _build3DButton({
    required Widget child,
    required VoidCallback onTap,
    double size = 42,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withAlpha(230),
              blurRadius: 0,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: Center(
          child: IconTheme(
            data: const IconThemeData(color: primary),
            child: child,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // 🔧 HANDLERS
  // ════════════════════════════════════════════════════════════

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validasi
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackbar("Semua field harus diisi", Colors.red);
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar("Password tidak cocok", Colors.red);
      return;
    }

    if (password.length < 6) {
      _showSnackbar("Password minimal 6 karakter", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Optimized: Register langsung dengan AccountManager
      final result = await _accountManager.register({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'level_skill': 'Beginner',
      });

      if (result['success'] == true) {
        _showSnackbar("Registrasi berhasil! Silakan login.", primaryLight);
        
        // Optimized: Faster navigation
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LoginPage.withSuccessMessage(
                  "Registrasi berhasil! Silakan login."),
            ),
          );
        }
      } else {
        _showSnackbar(result['message'] ?? 'Registrasi gagal', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Terjadi kesalahan: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Optimized: Use AccountManager
      final result = await _accountManager.googleLogin();

      if (result['success'] == true) {
        final isNewUser = result['is_new_user'] ?? false;
        _showSnackbar(
          isNewUser ? "Registrasi Google berhasil!" : "Login Google berhasil!",
          primaryLight,
        );
        
        // Optimized: Faster navigation
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LoginPage.withSuccessMessage(
                isNewUser
                    ? "Registrasi Google berhasil! Silakan login."
                    : "Login Google berhasil!",
              ),
            ),
          );
        }
      } else {
        _showSnackbar(result['message'] ?? 'Google Sign-In gagal', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Google Sign-In error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
