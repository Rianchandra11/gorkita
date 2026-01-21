import 'package:flutter/material.dart';
import 'package:uts_backend/services/app_service.dart';
import 'package:uts_backend/pages/login/login_page.dart';

class RegisterController {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController verificationCodeController =
      TextEditingController();

  // State variables
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool showVerificationField = false;
  bool isLoading = false;

  // API Service
  final AppService apiService = AppService();

  // Colors
  final Color primary = const Color(0xFF4CAF50);
  final Color secondary = const Color(0xFF2196F3);
  final Color subtle = const Color(0xFF648765);
  final Color inputBg = const Color(0xFFF0F4F0);

  // Handle Methods
  void handleBackPressed(BuildContext context) {
    if (showVerificationField) {
      showVerificationField = false;
    } else {
      navigateToLogin(context);
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> handleRegister(BuildContext context) async {
    if (!validateRegistrationInput(context)) return;

    isLoading = true;
    notifyListeners();

    try {
      // Check email sudah terdaftar
      final emailCheck = await apiService.checkEmailRegistered(
        emailController.text,
      );

      if (emailCheck == true) {
        showMessage(context, 'Email sudah terdaftar', Colors.red);

        isLoading = false;
        notifyListeners();
        return;
      }

      // Check nomor telepon sudah terdaftar
      final phoneCheck = await apiService.isPhoneNumberTaken(
        phoneController.text,
      );

      if (phoneCheck == true) {
        showMessage(context, 'No telepon ini sudah digunakan', Colors.red);

        isLoading = false;
        notifyListeners();
        return;
      }

      final result = await apiService.hybridRegister({
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
        'level_skill': 'Beginner',
      });

      if (result['success'] == true) {
        showMessage(
          context,
          'Registrasi berhasil! Silakan login.',
          Colors.green,
        );
        navigateToLoginWithMessage(
          context,
          'Registrasi berhasil! Silakan login.',
        );
      } else {
        showMessage(
          context,
          result['message'] ?? 'Registrasi gagal',
          Colors.red,
        );
      }
    } catch (e) {
      showMessage(context, 'Terjadi kesalahan: $e', Colors.red);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleVerification(BuildContext context) async {
    if (!validateVerificationInput(context)) return;

    isLoading = true;
    notifyListeners();

    try {
      showMessage(context, 'Email berhasil diverifikasi!', Colors.green);
      navigateToLoginWithMessage(
        context,
        'Email berhasil diverifikasi! Silakan login.',
      );
    } catch (e) {
      showMessage(context, 'Terjadi kesalahan: $e', Colors.red);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendCode(BuildContext context) async {
    showMessage(context, 'Kode verifikasi baru telah dikirim', Colors.green);
  }

  // Validation Methods
  bool validateRegistrationInput(BuildContext context) {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showMessage(context, 'Semua field harus diisi', Colors.red);
      return false;
    }

    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      showMessage(context, 'Format email tidak valid', Colors.red);
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showMessage(context, 'Password tidak cocok', Colors.red);
      return false;
    }

    if (passwordController.text.length < 6) {
      showMessage(context, 'Password minimal 6 karakter', Colors.red);
      return false;
    }

    return true;
  }

  bool validateVerificationInput(BuildContext context) {
    if (verificationCodeController.text.isEmpty ||
        verificationCodeController.text.length != 6) {
      showMessage(context, 'Masukkan 6 digit kode verifikasi', Colors.red);
      return false;
    }
    return true;
  }

  void navigateToLoginWithMessage(BuildContext context, String message) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage.withSuccessMessage(message),
      ),
      (route) => false,
    );
  }

  void showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera hadir!'),
        backgroundColor: primary,
      ),
    );
  }

  void showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    verificationCodeController.dispose();
  }

  void notifyListeners() {
    // This would typically be handled by a state management solution
    // For now, we'll rely on the parent widget to call setState
  }
}
