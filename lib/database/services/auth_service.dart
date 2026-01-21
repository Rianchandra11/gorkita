import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart'; // Import DatabaseService

class AuthenticationService {
  // === SINGLETON PATTERN ===
  static final AuthenticationService _instance =
      AuthenticationService._internal();
  factory AuthenticationService() => _instance;
  AuthenticationService._internal();

  // Untuk testing: bisa di-inject dengan mock (lazy initialization)
  FirebaseAuth? _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Gunakan DatabaseService singleton
  final DatabaseService _dbService = DatabaseService();

  /// Method untuk inject mock FirebaseAuth (untuk testing)
  void setFirebaseAuth(FirebaseAuth auth) {
    _firebaseAuth = auth;
  }

  /// Get FirebaseAuth instance dengan lazy initialization
  FirebaseAuth get firebaseAuth {
    _firebaseAuth ??= FirebaseAuth.instance;
    return _firebaseAuth!;
  }

  Future<Map<String, dynamic>> firebaseLogin(
    String email,
    String password,
  ) async {
    try {
      // --- BAGIAN DARI GAMBAR 1 ---
      final firebaseResult = await _loginToFirebase(email, password);

      if (firebaseResult['success'] == true) {
        final uid = firebaseResult['uid'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        if (uid != null) await prefs.setString('firebase_uid', uid);

        final userData = await _dbService.getUserByEmail(email);

        final userId = userData?['user_id'] as int? ?? 0;

        await _dbService.savePasswordToFirestore(uid, password);

        // Update last_login di Firestore
        if (uid != null) {
          await _dbService.updateLastLogin(uid);
        }

        // --- BAGIAN DARI GAMBAR 2 (Disambungkan di sini) ---
        // Logika tambahan untuk update password (fallback) sebelum return
        try {
          await _updateFirebaseAuthPasswordWithFallback(email, password, uid);
        } catch (e) {
          print('tidak bisa update firebase auth: $e');
        }

        return {
          'success': true,
          'message': 'Login berhasil',
          'firebase_uid': uid,
          'user_id': userId,
          'user_data': userData,
          'login_source': 'firebase_auth',
        };
      } else {
        // Firebase Auth gagal, coba fallback: cek password di Firestore
        print('Firebase Auth gagal, mencoba fallback Firestore...');
        final fallbackResult = await _firestorePasswordFallback(
          email,
          password,
        );

        if (fallbackResult['success'] == true) {
          final uid = fallbackResult['uid'];
          final userData = fallbackResult['user'];
          final userId = userData?['user_id'] as int? ?? 0;

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          if (uid != null) await prefs.setString('firebase_uid', uid);

          // Update last_login di Firestore
          if (uid != null) {
            await _dbService.updateLastLogin(uid);
          }

          return {
            'success': true,
            'message': 'Login berhasil (via Firestore fallback)',
            'firebase_uid': uid,
            'user_id': userId,
            'user_data': userData,
            'login_source': 'firestore_fallback',
          };
        }

        return {
          'success': false,
          'message': fallbackResult['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      // Menangani error pada block try utama
      print('Firebase Login Error: $e');
      return {'success': false, 'message': 'Login error: $e'};
    }
  }

  /// Register User Baru
  Future<Map<String, dynamic>> firebaseRegister(
    Map<String, dynamic> userData,
  ) async {
    try {
      // 1. Buat User di Firebase Auth
      final firebaseResult = await _registerToFirebase(
        userData['email'],
        userData['password'],
      );

      if (firebaseResult['success'] == true && firebaseResult['uid'] != null) {
        final uid = firebaseResult['uid']!;

        // 2. Generate ID MySQL style menggunakan DatabaseService
        final nextUserId = await _dbService.generateUserId();

        final newUserData = {
          'user_id': nextUserId,
          'name': userData['name'] ?? '',
          'email': userData['email'] ?? '',
          'email_verified': false,
          'phone': userData['phone'] ?? '',
          'level_skill': userData['level_skill'] ?? 'Beginner',
          'photo_url': '',
          'social_uid': [],
          'login_method': 'email',
          'firebase_uid': uid,
          'password': userData['password'] ?? '',
          'balance': 0,
          'last_login': DateTime.now(),
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };

        // 3. Simpan data lengkap ke Firestore menggunakan DatabaseService
        await _dbService.syncUserToFirestore(uid, nextUserId, newUserData);

        return {
          'success': true,
          'message': 'Registrasi berhasil',
          'firebase_uid': uid,
          'user_id': nextUserId,
          'user_data': newUserData,
          'login_source': 'firebase',
        };
      } else {
        return {
          'success': false,
          'message': firebaseResult['message'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      print('Firebase Registration Error: $e');
      return {'success': false, 'message': 'Registrasi error: $e'};
    }
  }

  /// Reset Password
  Future<Map<String, dynamic>> firebaseResetPassword(
    String email,
    String newPassword,
  ) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null || user.email != email) {
        return {
          'success': false,
          'message': 'User tidak ditemukan atau email tidak sesuai',
        };
      }

      // Update di Auth
      await user.updatePassword(newPassword);

      // Update di Firestore menggunakan DatabaseService
      await _dbService.updatePassword(user.uid, newPassword);

      return {'success': true, 'message': 'Password berhasil diubah'};
    } catch (e) {
      print('Firebase Reset Password Error: $e');
      return {'success': false, 'message': 'Reset password error: $e'};
    }
  }

  /// Login dengan Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('🔷 [AuthService] signInWithGoogle started');

      // 1. Sign out terlebih dahulu untuk force dialog selection
      print('🔷 [AuthService] Signing out previous session...');
      await _googleSignIn.signOut();

      // 2. Trigger Google Sign In dengan dialog selection
      print('🔷 [AuthService] Calling GoogleSignIn.signIn()...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('🔷 [AuthService] GoogleSignIn.signIn() returned: $googleUser');

      if (googleUser == null) {
        print('[AuthService] Google sign-in dibatalkan');
        return {'success': false, 'message': 'Google sign-in dibatalkan'};
      }

      print('🔷 [AuthService] Got googleUser: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuthData =
          await googleUser.authentication;
      print('🔷 [AuthService] Got authentication data');

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuthData.idToken,
        accessToken: googleAuthData.accessToken,
      );

      // 3. Sign In ke Firebase
      print('🔷 [AuthService] Signing in to Firebase...');
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      print('🔷 [AuthService] Firebase signIn complete: ${user?.email}');

      if (user == null) {
        return {'success': false, 'message': 'Gagal mendapatkan user Firebase'};
      }

      // 3. Cek apakah user sudah ada di Firestore menggunakan DatabaseService
      final existingUser = await _dbService.getUserByEmail(user.email!);

      // A. User Lama: Update data social
      if (existingUser != null) {
        final social = List<String>.from(existingUser['social_uid'] ?? []);

        if (!social.contains('google')) social.add('google');

        await _dbService.updateUserSocialData(user.uid, social, 'google');

        // Update last_login di Firestore
        await _dbService.updateLastLogin(user.uid);

        return {
          'success': true,
          'message': 'Login Google berhasil',
          'user_id': existingUser['user_id'] ?? 0,
          'user_data': existingUser,
          'is_new_user': false,
        };
      }

      // B. User Baru: Generate ID dan Buat Dokumen
      final nextUserId = await _dbService.generateUserId();

      final newUserMap = {
        'user_id': nextUserId,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'email_verified': user.emailVerified,
        'phone': user.phoneNumber ?? '',
        'level_skill': 'Beginner',
        'photo_url': user.photoURL ?? '',
        'social_uid': ['google'],
        'login_method': 'google',
        'firebase_uid': user.uid,
        'password': '',
        'balance': 0,
        'last_login': DateTime.now(),
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      await _dbService.saveUserData(user.uid, newUserMap);

      return {
        'success': true,
        'message': 'Registrasi Google berhasil',
        'user_id': nextUserId,
        'user_data': newUserMap,
        'is_new_user': true,
      };
    } catch (e) {
      print('Google Sign-In Error: $e');
      return {'success': false, 'message': 'Google Sign-In Error: $e'};
    }
  }

  /// Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      await firebaseAuth.signOut();
      await _googleSignIn.signOut();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      return {'success': true, 'message': 'Logout berhasil'};
    } catch (e) {
      print('Logout Error: $e');
      return {'success': false, 'message': 'Logout error: $e'};
    }
  }

  // === PRIVATE: AUTH HELPER METHODS ===

  Future<Map<String, dynamic>> _loginToFirebase(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.reload();

      return {
        'success': true,
        'uid': userCredential.user?.uid,
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Login gagal';
      if (e.code == 'user-not-found') msg = 'User tidak ditemukan';
      if (e.code == 'wrong-password') msg = 'Password salah';

      return {
        'success': false,
        'message': msg,
        'error_code': e.code,
        'error_type': e.code,
      };
    }
  }

  Future<Map<String, dynamic>> _registerToFirebase(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      return {
        'success': true,
        'uid': userCredential.user?.uid,
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Registrasi gagal';
      if (e.code == 'email-already-in-use') msg = 'Email sudah terdaftar';
      if (e.code == 'weak-password') msg = 'Password terlalu lemah';

      return {'success': false, 'message': msg, 'error_code': e.code};
    }
  }

  // === PRIVATE: FIRESTORE FALLBACK METHODS ===

  /// Fallback: Cek password manual di Firestore jika Auth gagal
  Future<Map<String, dynamic>> _firestorePasswordFallback(
    String email,
    String password,
  ) async {
    final userDoc = await _dbService.getUserByEmail(email);
    if (userDoc == null) {
      return {'success': false, 'message': 'User tidak ditemukan'};
    }

    final storedPassword = userDoc['password'] as String?;
    final firebaseUid = userDoc['firebase_uid'] as String?;

    if (storedPassword == password) {
      return {'success': true, 'uid': firebaseUid, 'user': userDoc};
    }
    return {'success': false, 'message': 'Password salah'};
  }

  /// Fallback: Update password Auth jika di Firestore benar tapi Auth salah
  Future<void> _updateFirebaseAuthPasswordWithFallback(
    String email,
    String password,
    String? uid,
  ) async {
    try {
      if (uid == null) return;
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final currentUser = firebaseAuth.currentUser;

      if (currentUser != null && currentUser.uid == uid) {
        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updatePassword(password);
      }
    } catch (e) {
      print('Error re-auth update: $e');
    }
  }

  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }
}
