import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uts_backend/database/services/app_service.dart';
import 'package:uts_backend/pages/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String? resetCode;
  final AppService? apiService;

  const ResetPasswordPage({
    super.key, 
    required this.email,
    this.resetCode,
    this.apiService,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final primary = const Color(0xFF15742A);
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  
  // API Service
  late final AppService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? AppService();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  Icon(
                    Icons.password,
                    size: 70,
                    color: primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kode reset dikirim ke: ${widget.email}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Kode Reset Field
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: 'Kode Reset (6 digit)',
                      hintText: 'Masukkan 6 digit kode',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.verified_user_outlined),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kode reset harus diisi';
                      }
                      if (value.length != 6) {
                        return 'Kode harus 6 digit';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Kode harus berupa angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      hintText: 'Minimal 6 karakter',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password harus diisi';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      hintText: 'Ulangi password baru',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password harus diisi';
                      }
                      if (value != _passwordController.text) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Password strength indicator
                  if (_passwordController.text.isNotEmpty)
                    LinearProgressIndicator(
                      value: _calculatePasswordStrength(_passwordController.text),
                      backgroundColor: Colors.grey[300],
                      color: _getPasswordStrengthColor(_passwordController.text),
                    ),

                  const SizedBox(height: 30),

                  // Reset Button
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF15742A)),
                          ),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _resetPassword,
                          child: const Text(
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),

                  // Tampilkan kode reset untuk development
                  if (widget.resetCode != null && !const bool.fromEnvironment('dart.vm.product'))
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Kode Reset:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.resetCode!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Reset password langsung dengan kode - akan update Firestore
      final result = await _apiService.resetPasswordWithCode(
        widget.email,
        _codeController.text.trim(),
        _passwordController.text,
      );

      if (result['success'] == true) {
        // Tampilkan pesan sukses
        _showMessage(
          'Password berhasil diubah!', 
          Colors.green,
          duration: const Duration(seconds: 2),
        );
        
        // Finalize reset (mark for sync) 
        final finalizeResult = await _apiService.finalizePasswordResetWithAuth(
          widget.email,
          _codeController.text,
          _passwordController.text,
        );
        
        if (kDebugMode) debugPrint('Finalize result: $finalizeResult');
        
        // Tunggu sebentar sebelum navigasi
        await Future.delayed(const Duration(seconds: 2));
        
        // Navigasi ke login page dan hapus semua route sebelumnya
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } else {
        _showMessage(
          result['message'] ?? 'Reset password gagal. Silakan coba lagi.', 
          Colors.red,
          duration: const Duration(seconds: 3),
        );
        
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(
        'Error: ${e.message}', 
        Colors.red,
        duration: const Duration(seconds: 3),
      );
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMessage(
        'Terjadi kesalahan: ${e.toString()}', 
        Colors.red,
        duration: const Duration(seconds: 3),
      );
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _calculatePasswordStrength(String password) {
    double strength = 0.0;
    if (password.length >= 6) strength += 0.3;
    if (password.length >= 8) strength += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    return strength.clamp(0.0, 1.0);
  }

  Color _getPasswordStrengthColor(String password) {
    final strength = _calculatePasswordStrength(password);
    if (strength < 0.4) return Colors.red;
    if (strength < 0.7) return Colors.orange;
    return Colors.green;
  }

  void _showMessage(String message, Color color, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      _passwordController.removeListener(_onPasswordChanged);
    } catch (_) {}
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}