import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class AccountManager {
  static final AccountManager _instance = AccountManager._internal();
  factory AccountManager() => _instance;
  AccountManager._internal();

  final AuthenticationService _authService = AuthenticationService();
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream untuk realtime user state
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Run login di background
      final result = await _authService.firebaseLogin(email, password);
      
      if (result['success'] == true) {
        // Save session parallel dengan return
        _saveSessionAsync(result['firebase_uid']);
      }
      
      return result;
    } catch (e) {
      debugPrint('Login error: $e');
      return {'success': false, 'message': 'Login error: $e'};
    }
  }

  Future<Map<String, dynamic>> googleLogin() async {
    try {
      final result = await _authService.signInWithGoogle();
      
      if (result['success'] == true) {
        _saveSessionAsync(result['firebase_uid'] ?? result['user_id']?.toString());
      }
      
      return result;
    } catch (e) {
      debugPrint('Google login error: $e');
      return {'success': false, 'message': 'Google login error: $e'};
    }
  }



  // register user
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final result = await _authService.firebaseRegister(userData);
      
      if (result['success'] == true) {
        _saveSessionAsync(result['firebase_uid']);
      }
      
      return result;
    } catch (e) {
      debugPrint('Register error: $e');
      return {'success': false, 'message': 'Register error: $e'};
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      debugPrint('getUserProfile: firebaseUser = ${firebaseUser?.email}');
      

      if (firebaseUser != null) {
        return await _fetchProfileWithFirebaseUser(firebaseUser, userId);
      }

      // Firebase Auth null, coba ambil UID dari SharedPreferences
      debugPrint('Firebase Auth null, trying SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final savedUid = prefs.getString('firebase_uid');
      debugPrint('Saved UID from prefs: $savedUid');

      if (savedUid != null && savedUid.isNotEmpty) {
        // Fetch langsung dari Firestore pakai UID
        final userData = await _dbService.getUserByUid(savedUid);
        debugPrint('Firestore by saved UID result: $userData');

        if (userData != null) {
          return _buildUserProfileFromData(userData, userId);
        }
      }

      debugPrint('getUserProfile: No valid session found');
      return null;
    } catch (e) {
      debugPrint('Get profile error: $e');
      return null;
    }
  }

  /// Fetch profile dengan Firebase User tersedia
  Future<Map<String, dynamic>?> _fetchProfileWithFirebaseUser(
    User firebaseUser,
    int userId,
  ) async {
    // Parallel fetch: Firestore by email dan by UID
    debugPrint('Fetching by email: ${firebaseUser.email} and UID: ${firebaseUser.uid}');
    final results = await Future.wait([
      _dbService.getUserByEmail(firebaseUser.email ?? ''),
      _dbService.getUserByUid(firebaseUser.uid),
    ], eagerError: false);

    final byEmail = results[0];
    final byUid = results[1];
    debugPrint('byEmail result: $byEmail');
    debugPrint('byUid result: $byUid');

    // Prioritas: by email -> by uid -> firebase auth
    final userData = byEmail ?? byUid;

    if (userData != null) {
      return _buildUserProfile(userData, firebaseUser, userId);
    }

    debugPrint('No Firestore data found, using Firebase Auth fallback');
    // Fallback ke Firebase Auth
    return {
      'user_id': userId,
      'name': firebaseUser.displayName ?? 'User',
      'email': firebaseUser.email ?? '',
      'phone': '',
      'level_skill': 'Beginner',
      'photo_url': firebaseUser.photoURL ?? '',
      'firebase_uid': firebaseUser.uid,
    };
  }

  /// Build profile dari data Firestore saja (tanpa Firebase User)
  Map<String, dynamic> _buildUserProfileFromData(
    Map<String, dynamic> userData,
    int userId,
  ) {
    return {
      'user_id': userId,
      'name': userData['name'] ?? userData['displayName'] ?? 'User',
      'email': userData['email'] ?? '',
      'phone': userData['phone'] ?? userData['nohp'] ?? '',
      'level_skill': userData['level_skill'] ?? 'Beginner',
      'photo_url': userData['photo_url'] ?? '',
      'firebase_uid': userData['firebase_uid'] ?? '',
      'balance': userData['balance'] ?? 0,
      'last_login': userData['last_login'],
    };
  }

  /// Build user profile - bisa di-compute jika data besar
  Map<String, dynamic> _buildUserProfile(
    Map<String, dynamic> userData,
    User firebaseUser,
    int userId,
  ) {
    return {
      'user_id': userId,
      'name': userData['name'] ?? userData['displayName'] ?? firebaseUser.displayName ?? 'User',
      'email': userData['email'] ?? firebaseUser.email ?? '',
      'phone': userData['phone'] ?? userData['nohp'] ?? '',
      'level_skill': userData['level_skill'] ?? 'Beginner',
      'photo_url': userData['photo_url'] ?? firebaseUser.photoURL ?? '',
      'firebase_uid': firebaseUser.uid,
      'balance': userData['balance'] ?? 0,
      'last_login': userData['last_login'],
    };
  }

  // UPDATE PROFILE - Optimized
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? name,
    String? phone,
    String? levelSkill,
    String? photoUrl,
  }) async {
    try {
      // Cek phone number duplicate jika diubah
      if (phone != null && phone.isNotEmpty) {
        final isTaken = await _dbService.isPhoneNumberTaken(
          phone,
          excludeUserId: userId,
        );
        if (isTaken) {
          return {'success': false, 'message': 'Nomor telepon sudah digunakan'};
        }
      }

      return await _dbService.updateUserProfile(
        userId: userId,
        name: name,
        phone: phone,
        levelSkill: levelSkill,
        photoUrl: photoUrl,
      );
    } catch (e) {
      debugPrint('Update profile error: $e');
      return {'success': false, 'message': 'Update error: $e'};
    }
  }



  // PASSWORD OPERATIONS
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    try {
      return await _authService.firebaseResetPassword(email, newPassword);
    } catch (e) {
      return {'success': false, 'message': 'Reset password error: $e'};
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return {'success': true, 'message': 'Email reset password terkirim'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengirim email: $e'};
    }
  }



  // LOGOUT
  Future<Map<String, dynamic>> logout() async {
    try {
      final result = await _authService.logout();
      
      // Clear session async
      _clearSessionAsync();
      
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Logout error: $e'};
    }
  }


  // UTILITY METHODS
  User? getCurrentUser() => _firebaseAuth.currentUser;

  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  String? get currentUid => _firebaseAuth.currentUser?.uid;

  String? get currentEmail => _firebaseAuth.currentUser?.email;

  /// Save session async (fire and forget)
  void _saveSessionAsync(String? uid) {
    if (uid == null) return;
    
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('firebase_uid', uid);
      prefs.setInt('last_login', DateTime.now().millisecondsSinceEpoch);
    });
  }

  /// Clear session async
  void _clearSessionAsync() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('firebase_uid');
      prefs.remove('currentUser');
      prefs.remove('id');
    });
  }

  /// Check if session valid
  Future<bool> hasValidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('firebase_uid');
    return uid != null && _firebaseAuth.currentUser != null;
  }
}



/// Parse user data di isolate (untuk response besar)
Map<String, dynamic> parseUserDataIsolate(Map<String, dynamic> rawData) {
  return {
    'user_id': rawData['user_id'] ?? 0,
    'name': rawData['name'] ?? rawData['displayName'] ?? 'User',
    'email': rawData['email'] ?? '',
    'phone': rawData['phone'] ?? rawData['nohp'] ?? '',
    'level_skill': rawData['level_skill'] ?? 'Beginner',
    'photo_url': rawData['photo_url'] ?? '',
    'firebase_uid': rawData['firebase_uid'] ?? '',
    'balance': rawData['balance'] ?? 0,
  };
}

/// Parse multiple users (untuk list user)
List<Map<String, dynamic>> parseUserListIsolate(List<dynamic> rawList) {
  return rawList.map((item) {
    if (item is Map<String, dynamic>) {
      return parseUserDataIsolate(item);
    }
    return <String, dynamic>{};
  }).toList();
}
