import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_backend/database/database_repository.dart';

class AuthProvider with ChangeNotifier {
  final UserRepository _userRepo = UserRepository();

  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _pendingVerification;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get pendingVerificationEmail => _pendingVerification;
  bool get isLoggedIn => _currentUser != null;
  bool get hasPendingVerification => _pendingVerification != null;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _userRepo.registerUserWithVerification(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (result['success'] == true) {
        final loginResult = await login(email, password);
        return loginResult;
      } else {
        return result;
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _setLoading(true);
    try {
      final user = await _userRepo.loginUser(email, password);

      if (user != null) {
        _currentUser = user;
        await _persistCurrentUser();
        notifyListeners();

        return {
          'success': true,
          'message': 'Login berhasil!',
          'user': user,
          'user_id': user['id'],
        };
      } else {
        return {'success': false, 'message': 'Email atau password salah'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _setLoading(false);
    }
  }

  // === PASSWORD RESET ===
  Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    _setLoading(true);
    try {
      final result = await _userRepo.sendPasswordResetCode(email);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> resetPasswordWithCode(
    String email,
    String code,
    String newPassword,
  ) async {
    _setLoading(true);
    try {
      final result = await _userRepo.resetPasswordWithCode(
        email,
        code,
        newPassword,
      );
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(
    String email,
    String code,
  ) async {
    _setLoading(true);
    try {
      final result = await _userRepo.verifyResetCode(email, code);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    if (_currentUser == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    _setLoading(true);
    try {
      final result = await _userRepo.getUserProfile(_currentUser!['id']);
      if (result['success'] == true) {
        _currentUser = {..._currentUser!, ...result['user']};
        await _persistCurrentUser();
        notifyListeners();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateUserPassword(String newPassword) async {
    if (_currentUser == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    _setLoading(true);
    try {
      final result = await _userRepo.updateUserPassword(
        _currentUser!['id'],
        newPassword,
      );
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateProfileImage(String imageUrl) async {
    if (_currentUser == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    _setLoading(true);
    try {
      final result = await _userRepo.updateProfileImage(
        _currentUser!['id'],
        imageUrl,
      );
      if (result['success'] == true) {
        _currentUser!['photo_url'] = result['photo_url'] ?? imageUrl;
        await _persistCurrentUser();
        notifyListeners();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _setLoading(false);
    }
  }

  void updateUserBalance(double newBalance) {
    if (_currentUser != null) {
      _currentUser!['balance'] = newBalance;
      notifyListeners();
      _persistCurrentUser();
    }
  }

  void updateUserProfile(Map<String, dynamic> updates) {
    if (_currentUser != null) {
      _currentUser = {..._currentUser!, ...updates};
      notifyListeners();
      _persistCurrentUser();
    }
  }

  void clearPendingVerification() {
    _pendingVerification = null;
    notifyListeners();
  }

  void setPendingVerificationEmail(String email) {
    _pendingVerification = email;
    notifyListeners();
  }

  Future<void> _persistCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString('currentUser', jsonEncode(_currentUser));
      } else {
        await prefs.remove('currentUser');
        await prefs.remove('id');
      }
    } catch (e) {
      debugPrint('Error persisting user: $e');
    }
  }

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('currentUser');
      if (stored != null) {
        _currentUser = jsonDecode(stored) as Map<String, dynamic>;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error restoring persisted user: $e');
    }
  }

  // === LOGOUT
  Future<void> logout() async {
    _currentUser = null;
    _pendingVerification = null;
    _isLoading = false;
    notifyListeners();
    await _persistCurrentUser();

    await _userRepo.logout();
  }

  Future<Map<String, dynamic>> syncUserToFirebase() async {
    if (_currentUser == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    _setLoading(true);
    try {
      final result = await _userRepo.syncUserToFirebase(_currentUser!['id']);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> checkAuthStatus() async {
    _setLoading(true);
    try {
      final result = await _userRepo.checkAuthStatus();
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _setLoading(false);
    }
  }

  // === EMAIL CHECK ===
  Future<bool> isEmailRegistered(String email) async {
    try {
      return await _userRepo.isEmailRegistered(email);
    } catch (e) {
      debugPrint('Error checking email: $e');
      return false;
    }
  }

  // === HELPER METHODS ===
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getVenues() async => _userRepo.getVenues();
  Future<Map<String, dynamic>> getVenueDetail(int id) async =>
      _userRepo.getVenueDetail(id);
  Future<Map<String, dynamic>> getMabarList() async => _userRepo.getMabarList();
  Future<Map<String, dynamic>> getSparringList() async =>
      _userRepo.getSparringList();
  Future<Map<String, dynamic>> getSparringHistory() async =>
      _userRepo.getSparringHistory();
  Future<Map<String, dynamic>> getNotifications() async =>
      _userRepo.getNotifications();
  Future<Map<String, dynamic>> deleteNotification(int id) async =>
      _userRepo.deleteNotification(id);
  Future<Map<String, dynamic>> getAllJadwal() async => _userRepo.getAllJadwal();
  Future<Map<String, dynamic>> getSparringNews() async =>
      _userRepo.getSparringNews();
  Future<Map<String, dynamic>> addVenue(Map<String, dynamic> venueData) async =>
      _userRepo.addVenue(venueData);
  Future<void> testConnection() async => _userRepo.testConnection();
}
