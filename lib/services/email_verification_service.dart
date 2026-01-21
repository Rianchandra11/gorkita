import 'package:cloud_firestore/cloud_firestore.dart';

class EmailVerificationService {
  static final EmailVerificationService _instance =
      EmailVerificationService._internal();
  factory EmailVerificationService() => _instance;
  EmailVerificationService._internal();

  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    try {
      final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
          .toString()
          .padLeft(6, '0');
      final now = DateTime.now().toUtc();
      final expiresAt = now.add(Duration(minutes: 30));

      final key = _normalizeEmailKey(email);
      await FirebaseFirestore.instance
          .collection('email_verifications')
          .doc(key)
          .set({
            'email': email,
            'code': code,
            'createdAt': FieldValue.serverTimestamp(),
            'expiresAt': Timestamp.fromDate(expiresAt),
            'used': false,
          });

      return {
        'success': true,
        'message': 'Kode verifikasi dibuat',
        'debug_code': code,
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyEmailCode(
    String email,
    String code,
  ) async {
    try {
      final key = _normalizeEmailKey(email);
      final doc = await FirebaseFirestore.instance
          .collection('email_verifications')
          .doc(key)
          .get();
      if (!doc.exists)
        return {'success': false, 'message': 'Kode tidak ditemukan'};

      final data = doc.data();
      if (data == null)
        return {'success': false, 'message': 'Data tidak valid'};

      if (data['used'] == true)
        return {'success': false, 'message': 'Kode sudah digunakan'};

      final expires = (data['expiresAt'] as Timestamp?)?.toDate();
      if (expires == null || DateTime.now().toUtc().isAfter(expires.toUtc())) {
        return {'success': false, 'message': 'Kode telah kedaluwarsa'};
      }

      if (data['code'] != code)
        return {'success': false, 'message': 'Kode salah'};

      await FirebaseFirestore.instance
          .collection('email_verifications')
          .doc(key)
          .update({'used': true});

      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (users.docs.isNotEmpty) {
        final udoc = users.docs.first;
        await udoc.reference.update({
          'email_verified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return {'success': true, 'message': 'Email berhasil diverifikasi'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  
  String _normalizeEmailKey(String email) {
    return email.replaceAll('.', ',');
  }
}
