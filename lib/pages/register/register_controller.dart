import 'package:flutter/material.dart';
import 'package:uts_backend/database/database_service.dart';
import 'package:uts_backend/pages/login/login_page.dart';
import 'package:uts_backend/helper/notification_helper.dart'; 
import 'package:uts_backend/widgets/ad_interstitial.dart'; 

class RegisterController with ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final ApiService apiService = ApiService();

  final Color primary = const Color(0xFF4CAF50);
  final Color secondary = const Color(0xFF2196F3);
  final Color subtle = const Color(0xFF648765);
  final Color inputBg = const Color(0xFFF0F4F0);

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;

  void handleBackPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> handleRegister(BuildContext context) async {
    if (!validateRegistrationInput(context)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final emailCheck = await apiService.checkEmailRegistered(emailController.text.trim());
      
      if (emailCheck['isRegistered'] == true) {
        showMessage(context, 'Email sudah terdaftar', Colors.red);
        _isLoading = false;
        notifyListeners();
        return;
      }

      final result = await apiService.hybridRegister({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
        'level_skill': 'Beginner',
      });

      if (result['success'] == true) {
        await NotificationHelper.showWelcomeNotification();

        await Future.delayed(const Duration(seconds: 1));

        InterstitialHelper.showAd(context);

        showMessage(context, 'Registrasi berhasil! Silakan login.', Colors.green);
        navigateToLoginWithMessage(context, 'Registrasi berhasil! Silakan login.');
      } else {
        showMessage(context, result['message'] ?? 'Registrasi gagal', Colors.red);
      }
    } catch (e) {
      showMessage(context, 'Terjadi kesalahan: $e', Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool validateRegistrationInput(BuildContext context) {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showMessage(context, 'Semua field harus diisi', Colors.red);
      return false;
    }

    if (name.length < 3) {
      showMessage(context, 'Nama minimal 3 karakter', Colors.red);
      return false;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      showMessage(context, 'Format email tidak valid', Colors.red);
      return false;
    }

    if (phone.length < 10) {
      showMessage(context, 'Nomor telepon minimal 10 digit', Colors.red);
      return false;
    }

    if (password.length < 6) {
      showMessage(context, 'Password minimal 6 karakter', Colors.red);
      return false;
    }

    if (password != confirmPassword) {
      showMessage(context, 'Password tidak cocok', Colors.red);
      return false;
    }

    return true;
  }

  void navigateToLoginWithMessage(BuildContext context, String message) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage.withSuccessMessage(message)),
      (route) => false,
    );
  }

  void showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera hadir!'),
        backgroundColor: primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}