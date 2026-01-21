import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uts_backend/services/account_manager.dart';
import '../register_controller.dart';

class SocialLogin extends StatefulWidget {
  final RegisterController controller;

  const SocialLogin({super.key, required this.controller});

  @override
  State<SocialLogin> createState() => _SocialLoginState();
}

class _SocialLoginState extends State<SocialLogin> {
  // Optimized: Use AccountManager
  final AccountManager _layananAplikasi = AccountManager();
  bool _sedangMemuat = false;

  Future<void> _tanganiPendaftaranGoogle() async {
    setState(() => _sedangMemuat = true);

    try {
      final hasil = await _layananAplikasi.googleLogin();

      if (hasil['success'] == true) {
        final nama = hasil['displayName'] ?? 'User';
        final email = hasil['email'] ?? '';

        if (kDebugMode) {
          debugPrint('Google register berhasil!');
          debugPrint('Nama: $nama');
          debugPrint('Email: $email');
        }

        // Set nama otomatis dari Google
        widget.controller.nameController.text = nama;
        widget.controller.emailController.text = email;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat datang, $nama!'),
              backgroundColor: Colors.green,
            ),
          );
          // Arahkan ke home
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(hasil['message'] ?? 'Pendaftaran Google gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error pendaftaran Google: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sedangMemuat = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey[300]!, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _sedangMemuat ? null : _tanganiPendaftaranGoogle,
        icon: _sedangMemuat
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.red),
                ),
              )
            : const Icon(Icons.g_mobiledata, size: 18, color: Colors.red),
        label: Text(
          _sedangMemuat ? "Menghubungkan..." : "Google",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
