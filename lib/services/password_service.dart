import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PasswordService {
  static final PasswordService _instance = PasswordService._internal();
  factory PasswordService() => _instance;
  PasswordService._internal();

  final FirebaseAuth _otentikasiFirebase = FirebaseAuth.instance;

  Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    try {
      final result = await generateLocalResetCode(email);
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('Send Reset Code Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // reset password with code - directly update password in Firebase and database

  Future<Map<String, dynamic>> resetPasswordWithCode(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final verify = await verifyLocalResetCode(email, code);
      if (verify['success'] != true) return verify;
      final userDoc = await _getFirestoreUserByEmail(email);
      if (userDoc == null) {
        if (kDebugMode) debugPrint('User tidak ditemukan dengan email: $email');
        return {'success': false, 'message': 'User tidak ditemukan'};
      }

      final userId = userDoc['user_id'] as int?;
      var firebaseUid = userDoc['firebase_uid'];

      if (kDebugMode) {
        debugPrint('Firebase UID raw: $firebaseUid (type: ${firebaseUid.runtimeType})');
      }

      // Normalize firebase_uid
      if (firebaseUid != null) {
        firebaseUid = firebaseUid.toString().trim();
        if (kDebugMode) debugPrint('Firebase UID normalized: $firebaseUid');
      }

      // Update password in Firestore - use firebase_uid directly if available
      if (firebaseUid != null && firebaseUid.isNotEmpty) {
        try {
          if (kDebugMode) {
            debugPrint('Updating password in Firebase Auth for Firebase UID: $firebaseUid');
          }

          // First, update Firebase Authentication password using admin-like approach
          // We'll use the current user context if available, otherwise just update Firestore
          final currentUser = _otentikasiFirebase.currentUser;

          if (currentUser != null && currentUser.uid == firebaseUid) {
            // User is logged in, we can update their password directly
            try {
              await currentUser.updatePassword(newPassword);
              if (kDebugMode) debugPrint('Password updated in Firebase Auth');
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Could not update Firebase Auth password (user may need to re-authenticate): $e');
              }
              // Continue to update Firestore even if Auth update fails
            }
          } else {
            // User is not logged in, password will be updated on next login
            if (kDebugMode) {
              debugPrint('User not currently logged in - password will be validated on next login');
            }
          }

          if (kDebugMode) {
            debugPrint('Updating password in Firestore for Firebase UID: $firebaseUid');
          }
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUid)
              .update({
                'password': newPassword,
                'password_updated_at': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
          if (kDebugMode) {
            debugPrint('Password updated in Firestore successfully for UID: $firebaseUid');
          }

          // Mark reset code as used and delete it
          await clearLocalResetCode(email);

          return {
            'success': true,
            'message':
                'Password berhasil direset! Silakan login dengan password baru Anda.',
          };
        } catch (e) {
          if (kDebugMode) debugPrint('Error updating password: $e');
          return {'success': false, 'message': 'Gagal update password: $e'};
        }
      } else if (userId != null) {
        // Fallback: if no firebase_uid, update by user_id
        try {
          if (kDebugMode) debugPrint('Updating password by user_id: $userId');
          final users = await FirebaseFirestore.instance
              .collection('users')
              .where('user_id', isEqualTo: userId)
              .limit(1)
              .get();

          if (kDebugMode) {
            debugPrint('Found ${users.docs.length} document(s) for user_id=$userId');
          }

          if (users.docs.isNotEmpty) {
            if (kDebugMode) debugPrint('Updating document: ${users.docs.first.id}');
            final docUid = users.docs.first.id;

            // Try to update Firebase Auth if this is the current user
            final currentUser = _otentikasiFirebase.currentUser;
            if (currentUser != null && currentUser.uid == docUid) {
              try {
                await currentUser.updatePassword(newPassword);
                if (kDebugMode) debugPrint('Password updated in Firebase Auth');
              } catch (e) {
                if (kDebugMode) debugPrint('Could not update Firebase Auth password: $e');
              }
            }

            await users.docs.first.reference.update({
              'password': newPassword,
              'password_updated_at': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            if (kDebugMode) debugPrint('Password updated in Firestore by user_id');

            // Mark reset code as used and delete it
            await clearLocalResetCode(email);

            return {
              'success': true,
              'message':
                  'Password berhasil direset! Silakan login dengan password baru Anda.',
            };
          } else {
            if (kDebugMode) debugPrint('No document found for user_id=$userId');
            return {
              'success': false,
              'message': 'User tidak ditemukan untuk update',
            };
          }
        } catch (e) {
          if (kDebugMode) debugPrint('Error updating password by user_id: $e');
          return {'success': false, 'message': 'Gagal update password: $e'};
        }
      } else {
        if (kDebugMode) debugPrint('Tidak ada firebase_uid atau user_id untuk update');
        return {
          'success': false,
          'message': 'Tidak ada firebase_uid atau user_id untuk update',
        };
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Reset Password Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // verify reset code
  Future<Map<String, dynamic>> verifyResetCode(
    String email,
    String code,
  ) async {
    try {
      return await verifyLocalResetCode(email, code);
    } catch (e) {
      print('Verify Reset Code Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Method to update Firebase Auth password directly (requires admin access)
  // Since we can't update Firebase Auth without admin SDK, we'll do this on next login
  Future<Map<String, dynamic>> finalizePasswordResetWithAuth(
    String email,
    String newPassword,
  ) async {
    try {
      // Get user from Firestore to verify reset was successful
      final userDoc = await _getFirestoreUserByEmail(email);
      if (userDoc == null) {
        return {'success': false, 'message': 'User tidak ditemukan'};
      }

      final storedPassword = userDoc['password'] as String?;
      if (storedPassword == null || storedPassword.isEmpty) {
        return {
          'success': false,
          'message': 'Password tidak tersimpan dengan benar',
        };
      }

      // Mark that user needs to update Firebase Auth password on next login
      // by storing a flag in Firestore
      final firebaseUid = userDoc['firebase_uid'] as String?;
      if (firebaseUid != null && firebaseUid.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUid)
              .update({
                'needs_password_sync': true,
                'password_sync_timestamp': FieldValue.serverTimestamp(),
              });
          print(' Marked user for password sync on next login');
        } catch (e) {
          print(' Could not mark for sync: $e');
        }
      }

      return {
        'success': true,
        'message':
            'Password reset berhasil. Silakan login dengan password baru untuk menyelesaikan sinkronisasi.',
      };
    } catch (e) {
      print('Error finalizing password reset: $e');
      return {
        'success': false,
        'message': 'Gagal menyelesaikan reset password: $e',
      };
    }
  }

  // generate local reset code
  Future<Map<String, dynamic>> generateLocalResetCode(
    String email, {
    int ttlMinutes = 15,
  }) async {
    try {
      final userDoc = await _getFirestoreUserByEmail(email);
      if (userDoc == null) {
        return {'success': false, 'message': 'Email tidak ditemukan'};
      }

      final loginMethod = userDoc['login_method'] as String?;
      if (loginMethod != 'email') {
        return {
          'success': false,
          'message': 'Reset password hanya untuk akun email/password',
        };
      }

      final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
          .toString()
          .padLeft(6, '0');
      final now = DateTime.now().toUtc();
      final expiresAt = now.add(Duration(minutes: ttlMinutes));

      final key = _normalizeEmailKey(email);

      await FirebaseFirestore.instance
          .collection('password_resets')
          .doc(key)
          .set({
            'email': email,
            'code': code,
            'createdAt': FieldValue.serverTimestamp(),
            'expiresAt': Timestamp.fromDate(expiresAt),
            'used': false,
          });

      return {'success': true, 'message': 'Kode reset dibuat', 'code': code};
    } catch (e) {
      print('Kesalahan membuat kode reset lokal: $e');
      return {'success': false, 'message': 'Gagal membuat kode reset: $e'};
    }
  }

  // verify local reset code
  Future<Map<String, dynamic>> verifyLocalResetCode(
    String email,
    String code,
  ) async {
    try {
      final key = _normalizeEmailKey(email);
      final doc = await FirebaseFirestore.instance
          .collection('password_resets')
          .doc(key)
          .get();
      if (!doc.exists)
        return {'success': false, 'message': 'Kode tidak ditemukan'};

      final data = doc.data();
      if (data == null)
        return {'success': false, 'message': 'Data kode tidak valid'};

      if (data['used'] == true)
        return {'success': false, 'message': 'Kode sudah digunakan'};

      final expires = (data['expiresAt'] as Timestamp?)?.toDate();
      if (expires == null || DateTime.now().toUtc().isAfter(expires.toUtc())) {
        return {'success': false, 'message': 'Kode telah kedaluwarsa'};
      }

      if (data['code'] != code)
        return {'success': false, 'message': 'Kode salah'};

      await FirebaseFirestore.instance
          .collection('password_resets')
          .doc(key)
          .update({'used': true});

      return {'success': true, 'message': 'Kode valid'};
    } catch (e) {
      print('Kesalahan memverifikasi kode reset lokal: $e');
      return {'success': false, 'message': 'Gagal verifikasi kode: $e'};
    }
  }

  Future<void> clearLocalResetCode(String email) async {
    try {
      final key = _normalizeEmailKey(email);
      await FirebaseFirestore.instance
          .collection('password_resets')
          .doc(key)
          .delete();
    } catch (e) {}
  }

  // update password
  Future<Map<String, dynamic>> updatePassword(
    int id,
    String newPassword,
  ) async {
    try {
      final user = _otentikasiFirebase.currentUser;

      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final data = snapshot.exists ? snapshot.data() : null;
        if (data != null &&
            (data['user_id'] == id || data['firebase_uid'] == user.uid)) {
          await user.updatePassword(newPassword);
          await syncPasswordToFirestore(id, newPassword);
          return {'success': true, 'message': 'Password berhasil diubah'};
        }
      }

      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('user_id', isEqualTo: id)
          .limit(1)
          .get();
      if (users.docs.isNotEmpty) {
        final u = users.docs.first.data();
        if (u['firebase_uid'] != null) {
          return {
            'success': false,
            'message':
                'Untuk mengganti password akun yang terkait Firebase, gunakan fitur reset password (email)',
          };
        }
      }

      return {
        'success': false,
        'message':
            'Pengguna tidak ditemukan atau tidak dapat diubah dari klien',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  // sync password to firestore
  Future<Map<String, dynamic>> updateCurrentUserPassword(
    String newPassword,
  ) async {
    try {
      final user = _otentikasiFirebase.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Tidak ada pengguna yang login'};
      }

      await user.updatePassword(newPassword);
      await syncPasswordToFirestore(0, newPassword);
      return {'success': true, 'message': 'Password berhasil diubah'};
    } catch (e) {
      print('Kesalahan mengubah password: $e');
      return {'success': false, 'message': 'Gagal mengubah password: $e'};
    }
  }

  // Update password with re-authentication for better security
  Future<Map<String, dynamic>> updatePasswordWithAuth({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    try {
      final user = _otentikasiFirebase.currentUser;

      if (user == null) {
       //user tidak login ke firebase
        print(
          ' User not logged in to Firebase, trying Firestore fallback...',
        );
        return await _updatePasswordWithFirestoreFallback(
          currentPassword: currentPassword,
          newPassword: newPassword,
          email: email,
        );
      }

      if (user.email != email) {
        return {
          'success': false,
          'message': 'Email tidak sesuai dengan user yang login',
        };
      }

      // reauthenticate user
      try {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        print(' User re-authenticated successfully');
      } on FirebaseAuthException catch (e) {
        print(' Re-authentication failed: ${e.code}');
        if (e.code == 'wrong-password') {
          return {
            'success': false,
            'message':
                ' Password saat ini tidak sesuai dengan yang tersimpan di sistem.',
          };
        } else if (e.code == 'invalid-credential') {
          return {
            'success': false,
            'message':
                ' Kredensial tidak valid. Silakan coba lagi dengan password yang benar.',
          };
        } else if (e.code == 'user-mismatch') {
          return {
            'success': false,
            'message':
                ' User tidak sesuai. Silakan logout dan login ulang dengan akun yang tepat.',
          };
        } else if (e.code == 'user-not-found') {
          return {
            'success': false,
            'message':
                ' User tidak ditemukan. Silakan logout dan login ulang.',
          };
        } else {
          return {
            'success': false,
            'message':
                ' Verifikasi password gagal: ${e.message ?? e.code}. Silakan coba lagi.',
          };
        }
      }

      // update password
      try {
        await user.updatePassword(newPassword);
        print(' Password updated in Firebase Auth');
      } on FirebaseAuthException catch (e) {
        print(' Firebase password update failed: ${e.code}');

        String errorMsg =
            ' Gagal mengubah password di Firebase. Silakan coba lagi.';
        if (e.code == 'weak-password') {
          errorMsg =
              ' Password terlalu lemah. Gunakan kombinasi karakter yang lebih kompleks (minimal 6 karakter dengan huruf dan angka).';
        } else if (e.code == 'requires-recent-login') {
          errorMsg =
              ' Silakan logout dan login ulang terlebih dahulu untuk mengubah password.';
        }

        return {'success': false, 'message': errorMsg};
      }

      // Update password di Firestore juga
      await syncPasswordToFirestore(0, newPassword);
      print(' Password synced to Firestore');

      return {'success': true, 'message': ' Password berhasil diubah'};
    } catch (e) {
      print('Error updating password with auth: $e');
      return {
        'success': false,
        'message': ' Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // metod bantuan untuk update password dengan fallback firestore
  Future<Map<String, dynamic>> _updatePasswordWithFirestoreFallback({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    try {
      final userDoc = await _getFirestoreUserByEmail(email);
      if (userDoc == null) {
        return {
          'success': false,
          'message':
              ' User tidak ditemukan di database. Silakan logout dan login ulang.',
        };
      }

      final storedPassword = userDoc['password'] as String?;
      if (storedPassword == null || storedPassword.isEmpty) {
        return {
          'success': false,
          'message':
              ' Password tidak tersimpan di sistem. Silakan hubungi administrator.',
        };
      }

      // Cek password saat ini
      if (storedPassword != currentPassword) {
        return {
          'success': false,
          'message':
              ' Password saat ini tidak sesuai dengan yang tersimpan. Silakan coba lagi dengan password yang benar.',
        };
      }

      print(' Password validated against Firestore');

      // Update password di Firestore
      final firebaseUid = userDoc['firebase_uid'] as String?;
      if (firebaseUid != null && firebaseUid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUid)
            .update({
              'password': newPassword,
              'password_updated_at': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
        print(' Password updated in Firestore');
      }

      // mencoba update password di firebase auth
      try {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );

        // Sign in with current password
        final result = await _otentikasiFirebase.signInWithEmailAndPassword(
          email: email,
          password: currentPassword,
        );

        final currentUser = result.user;
        if (currentUser != null) {
          try {
            await currentUser.reauthenticateWithCredential(credential);
            await currentUser.updatePassword(newPassword);
            print(' Password berhasil diubah');
          } catch (e) {
            print(' Could not update Firebase Auth password: $e');
          }
        }
      } catch (e) {
        print(' tidak bisa login Firebase: $e');
        
      }

      return {'success': true, 'message': ' Password berhasil diubah'};
    } catch (e) {
      print('Error in Firestore fallback: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

// set passwd untuk akun google
  Future<Map<String, dynamic>> setPasswordForGoogleAccount({
    required int userId,
    required String newPassword,
  }) async {
    try {
      final user = _otentikasiFirebase.currentUser;
      if (user == null || user.email == null) {
        return {
          'success': false,
          'message': 'Tidak ada pengguna Firebase yang login',
        };
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: newPassword,
      );

      try {
        await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
        } else if (e.code == 'credential-already-in-use') {
          return {
            'success': false,
            'message': 'Email sudah memiliki kredensial password',
          };
        } else {
          return {
            'success': false,
            'message': 'Kesalahan tautan Firebase: ${e.message}',
          };
        }
      }

      final mysqlResult = await updatePassword(userId, newPassword);

      await syncPasswordToFirestore(userId, newPassword);

      return {
        'success': mysqlResult['success'] == true,
        'message': mysqlResult['message'] ?? 'Password berhasil diatur',
      };
    } catch (e) {
      print(' Kesalahan menetapkan password untuk akun Google: $e');
      return {'success': false, 'message': 'Kesalahan: $e'};
    }
  }

  // sync passwd untuk firestore
  Future<void> syncPasswordToFirestore(int userId, String newPassword) async {
    try {
      final user = _otentikasiFirebase.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'password': newPassword,
              'password_updated_at': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
        print('Password berhasil disinkronkan ke Firestore');
      }
    } catch (e) {
      print(' Kesalahan menyinkronkan password ke Firestore: $e');
    }
  }

  // Helper method untuk normalisasi email key
  String _normalizeEmailKey(String email) {
    return email.replaceAll('.', ',');
  }

  Future<Map<String, dynamic>?> _getFirestoreUserByEmail(String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        data['firebase_uid'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting Firestore user by email: $e');
      return null;
    }
  }
}
