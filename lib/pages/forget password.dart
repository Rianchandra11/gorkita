import 'package:flutter/material.dart';
import 'package:uts_backend/database/services/account_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uts_backend/pages/login/login_page.dart';

class HalamanAturUlangPassword extends StatefulWidget {
  final String email;

  const HalamanAturUlangPassword({super.key, required this.email});

  @override
  State<HalamanAturUlangPassword> createState() =>
      _HalamanAturUlangPasswordState();
}

class _HalamanAturUlangPasswordState extends State<HalamanAturUlangPassword> {
  // === Controllers ===
  final TextEditingController _kontrolerKode = TextEditingController();
  final TextEditingController _kontrolerPassword = TextEditingController();
  final TextEditingController _kontrolerKonfirmasi = TextEditingController();
  final GlobalKey<FormState> _kunciForm = GlobalKey<FormState>();

  // === State ===
  bool _sedangMemuat = false;
  bool _sembunyikanPassword = true;
  bool _sembunyikanKonfirmasi = true;

  // === Services - Optimized ===
  final AccountManager _layananAplikasi = AccountManager();

  // === Colors ===
  static const Color _warnaPrimer = Color(0xFF009688);
  static const Color _warnaInputBg = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _kontrolerPassword.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buatAppBar(),
      body: SafeArea(child: _buatBodyUtama()),
    );
  }

  // ===== BUILDERS =====

  /// Build AppBar
  PreferredSizeWidget _buatAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Atur Ulang Password',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Build Body Utama
  Widget _buatBodyUtama() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _kunciForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buatIkonHeader(),
              const SizedBox(height: 16),
              _buatJudulUtama(),
              const SizedBox(height: 8),
              _buatInfoEmail(),
              const SizedBox(height: 30),
              _buatInputKode(),
              const SizedBox(height: 16),
              _buatInputPasswordBaru(),
              const SizedBox(height: 16),
              _buatInputKonfirmasiPassword(),
              const SizedBox(height: 10),
              _buatIndikatorKekuatan(),
              const SizedBox(height: 30),
              _buatTombolReset(),
              const SizedBox(height: 20),
              _buatKotakKodeDebug(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Icon Header
  Widget _buatIkonHeader() {
    return Icon(Icons.password, size: 70, color: _warnaPrimer.withAlpha(7));
  }

  /// Build Judul Utama
  Widget _buatJudulUtama() {
    return const Text(
      'Atur Ulang Password',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  /// Build Info Email
  Widget _buatInfoEmail() {
    return Text(
      'Kode reset dikirim ke: ${widget.email}',
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      textAlign: TextAlign.center,
    );
  }

  /// Build Input Kode
  Widget _buatInputKode() {
    return TextFormField(
      controller: _kontrolerKode,
      decoration: InputDecoration(
        labelText: 'Kode Reset (6 digit)',
        hintText: 'Masukkan 6 digit kode',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.verified_user_outlined),
        filled: true,
        fillColor: _warnaInputBg,
      ),
      keyboardType: TextInputType.number,
      maxLength: 6,
      validator: _validasiKode,
    );
  }

  /// Build Input Password Baru
  Widget _buatInputPasswordBaru() {
    return TextFormField(
      controller: _kontrolerPassword,
      obscureText: _sembunyikanPassword,
      decoration: InputDecoration(
        labelText: 'Password Baru',
        hintText: 'Minimal 6 karakter',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _sembunyikanPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _sembunyikanPassword = !_sembunyikanPassword;
            });
          },
        ),
        filled: true,
        fillColor: _warnaInputBg,
      ),
      validator: _validasiPassword,
    );
  }

  /// Build Input Konfirmasi Password
  Widget _buatInputKonfirmasiPassword() {
    return TextFormField(
      controller: _kontrolerKonfirmasi,
      obscureText: _sembunyikanKonfirmasi,
      decoration: InputDecoration(
        labelText: 'Konfirmasi Password',
        hintText: 'Ulangi password baru',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.lock_reset_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _sembunyikanKonfirmasi ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _sembunyikanKonfirmasi = !_sembunyikanKonfirmasi;
            });
          },
        ),
        filled: true,
        fillColor: _warnaInputBg,
      ),
      validator: _validasiKonfirmasi,
    );
  }

  /// Build Indikator Kekuatan Password
  Widget _buatIndikatorKekuatan() {
    if (_kontrolerPassword.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return LinearProgressIndicator(
      value: _hitungKekuatanPassword(_kontrolerPassword.text),
      backgroundColor: Colors.grey[300],
      color: _ambilWarnaKekuatan(_kontrolerPassword.text),
    );
  }

  /// Build Tombol Reset
  Widget _buatTombolReset() {
    if (_sedangMemuat) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_warnaPrimer),
        ),
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _warnaPrimer,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      onPressed: _tanganiAturUlangPassword,
      child: const Text(
        'Atur Ulang Password',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build Kotak Kode Debug
  Widget _buatKotakKodeDebug() {
    return const SizedBox.shrink();
  }

  // ===== HANDLERS =====

  /// Tangani Atur Ulang Password
  Future<void> _tanganiAturUlangPassword() async {
    if (!_kunciForm.currentState!.validate()) {
      return;
    }

    setState(() => _sedangMemuat = true);

    try {
      final hasil = await _layananAplikasi.resetPassword(
        widget.email,
        _kontrolerPassword.text,
      );

      if (hasil['success'] == true) {
        _tampilkanPesan(
          'Password berhasil diubah!',
          Colors.green,
          durasi: const Duration(seconds: 2),
        );

        // Password sudah direset

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } else {
        _tampilkanPesan(
          '${hasil['message'] ?? 'Atur ulang password gagal. Silakan coba lagi.'}',
          Colors.red,
          durasi: const Duration(seconds: 3),
        );

        if (mounted) {
          setState(() => _sedangMemuat = false);
        }
      }
    } on FirebaseAuthException catch (e) {
      _tampilkanPesan(
        'Error: ${e.message}',
        Colors.red,
        durasi: const Duration(seconds: 3),
      );
      if (mounted) {
        setState(() => _sedangMemuat = false);
      }
    } catch (e) {
      _tampilkanPesan(
        'Terjadi kesalahan: ${e.toString()}',
        Colors.red,
        durasi: const Duration(seconds: 3),
      );
      if (mounted) {
        setState(() => _sedangMemuat = false);
      }
    }
  }

  /// Callback saat Password Berubah
  void _onPasswordChanged() {
    if (mounted) setState(() {});
  }

  // ===== HELPERS =====

  /// Validasi Kode
  String? _validasiKode(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Kode reset harus diisi';
    }
    if (nilai.length != 6) {
      return 'Kode harus 6 digit';
    }
    if (int.tryParse(nilai) == null) {
      return 'Kode harus berupa angka';
    }
    return null;
  }

  /// Validasi Password
  String? _validasiPassword(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Password harus diisi';
    }
    if (nilai.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Validasi Konfirmasi
  String? _validasiKonfirmasi(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    if (nilai != _kontrolerPassword.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  /// Hitung Kekuatan Password
  double _hitungKekuatanPassword(String password) {
    double kekuatan = 0.0;
    if (password.length >= 6) kekuatan += 0.3;
    if (password.length >= 8) kekuatan += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(password)) kekuatan += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) kekuatan += 0.2;
    return kekuatan.clamp(0.0, 1.0);
  }

  /// Ambil Warna Kekuatan
  Color _ambilWarnaKekuatan(String password) {
    final kekuatan = _hitungKekuatanPassword(password);
    if (kekuatan < 0.4) return Colors.red;
    if (kekuatan < 0.7) return Colors.orange;
    return Colors.green;
  }

  /// Tampilkan Pesan
  void _tampilkanPesan(
    String pesan,
    Color warna, {
    Duration durasi = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pesan,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: warna,
        duration: durasi,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    try {
      _kontrolerPassword.removeListener(_onPasswordChanged);
    } catch (_) {}
    _kontrolerKode.dispose();
    _kontrolerPassword.dispose();
    _kontrolerKonfirmasi.dispose();
    super.dispose();
  }
}
