import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uts_backend/services/account_manager.dart';

/// AuthProvider - Optimized state management untuk authentication
/// Clean, fast, tanpa cache berlebihan
class AuthProvider with ChangeNotifier {
  final AccountManager _accountManager = AccountManager();

  // State
  bool _isLoading = false;
  bool _isInitialized = false;
  Map<String, dynamic>? _userData;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _accountManager.isLoggedIn;
  Map<String, dynamic>? get userData => _userData;
  String? get error => _error;
  User? get currentUser => _accountManager.getCurrentUser();
  String? get currentUid => _accountManager.currentUid;
  String? get currentEmail => _accountManager.currentEmail;

  /// Initialize provider - panggil sekali di main.dart
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isInitialized = true;
    
    // Listen to auth state changes
    _accountManager.authStateChanges.listen((user) {
      if (user == null) {
        _userData = null;
        notifyListeners();
      }
    });
  }
  // LOGIN

  Future<Map<String, dynamic>> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _accountManager.login(email, password);

      if (result['success'] == true) {
        _userData = result['user_data'];
      } else {
        _error = result['message'];
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return {'success': false, 'message': _error};
    } finally {
      _setLoading(false);
    }
  }

  /// Google Login
  Future<Map<String, dynamic>> googleLogin() async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _accountManager.googleLogin();

      if (result['success'] == true) {
        _userData = result['user_data'];
      } else {
        _error = result['message'];
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return {'success': false, 'message': _error};
    } finally {
      _setLoading(false);
    }
  }

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _accountManager.register({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'level_skill': 'Beginner',
      });

      if (result['success'] == true) {
        _userData = result['user_data'];
      } else {
        _error = result['message'];
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return {'success': false, 'message': _error};
    } finally {
      _setLoading(false);
    }
  }

  /// Get profile - optimized
  Future<Map<String, dynamic>?> getProfile(int userId) async {
    _setLoading(true);

    try {
      final profile = await _accountManager.getUserProfile(userId);
      
      if (profile != null) {
        _userData = profile;
        notifyListeners();
      }
      
      return profile;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update profile
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? name,
    String? phone,
    String? levelSkill,
    String? photoUrl,
  }) async {
    _setLoading(true);

    try {
      final result = await _accountManager.updateProfile(
        userId: userId,
        name: name,
        phone: phone,
        levelSkill: levelSkill,
        photoUrl: photoUrl,
      );

      if (result['success'] == true) {
        // Update local state
        if (_userData != null) {
          if (name != null) _userData!['name'] = name;
          if (phone != null) _userData!['phone'] = phone;
          if (levelSkill != null) _userData!['level_skill'] = levelSkill;
          if (photoUrl != null) _userData!['photo_url'] = photoUrl;
          notifyListeners();
        }
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  // PASSWORD
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    _setLoading(true);

    try {
      return await _accountManager.resetPassword(email, newPassword);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    _setLoading(true);

    try {
      return await _accountManager.sendPasswordResetEmail(email);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }


  // LOGOUT
  Future<Map<String, dynamic>> logout() async {
    _setLoading(true);

    try {
      final result = await _accountManager.logout();

      if (result['success'] == true) {
        _userData = null;
        _error = null;
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  // HELPERS
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check if has valid session
  Future<bool> checkSession() async {
    return await _accountManager.hasValidSession();
  }
}
