import 'package:flutter/foundation.dart';
import 'package:uts_backend/database/database_service.dart';

class UserRepository {
  final ApiService _apiService = ApiService();

  // === HYBRID LOGIN ===
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final result = await _apiService.hybridLogin(email, password);
      
      if (result['success'] == true) {
        final userData = result['user_data'] ?? {};
        
        return {
          'id': result['user_id'],
          'name': userData['name'] ?? '',
          'email': email,
          'phone': userData['phone'] ?? '',
          'password': password,
          'level_skill': userData['level_skill'] ?? 'Beginner',
          'photo_url': userData['photo_url'] ?? '',
          'isEmailVerified': 1,
          'balance': 0.0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'firebase_uid': result['firebase_uid'],
          'login_source': result['login_source'],
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error login user: $e');
      return null;
    }
  }

  // === HYBRID REGISTER ===
  Future<Map<String, dynamic>> registerUserWithVerification({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final registerResult = await _apiService.hybridRegister({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'level_skill': 'Beginner',
      });

      return registerResult;
    } catch (e) {
      debugPrint('Error register user with verification: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
  
  Future<bool> isEmailRegistered(String email) async {
    try {
      final result = await _apiService.checkEmailRegistered(email);
      return result['isRegistered'] == true;
    } catch (e) {
      debugPrint('Error check email registered: $e');
      return false;
    }
  }

  // === PASSWORD RESET METHODS ===
  Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    try {
      final result = await _apiService.sendPasswordResetCode(email);
      return result;
    } catch (e) {
      debugPrint('Error send password reset code: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> resetPasswordWithCode(
      String email, String code, String newPassword) async {
    try {
      final result = await _apiService.resetPasswordWithCode(email, code, newPassword);
      return result;
    } catch (e) {
      debugPrint('Error reset password with code: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    try {
      final result = await _apiService.verifyResetCode(email, code);
      return result;
    } catch (e) {
      debugPrint('Error verify reset code: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final result = await _apiService.getUserById(userId);
      if (result['success'] == true) {
        return {
          'success': true,
          'user': result['user'],
        };
      } else {
        return {
          'success': false,
          'message': result['message'],
        };
      }
    } catch (e) {
      debugPrint('Error get user profile: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateUserPassword(int userId, String newPassword) async {
    try {
      final result = await _apiService.updatePassword(userId, newPassword);
      return result;
    } catch (e) {
      debugPrint('Error update user password: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfileImage(int userId, String imageUrl) async {
    try {
      final result = await _apiService.uploadProfileImage(userId, imageUrl);
      return result;
    } catch (e) {
      debugPrint('Error update profile image: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> syncUserToFirebase(int mysqlUserId) async {
    try {
      final userResult = await _apiService.getUserById(mysqlUserId);
      if (userResult['success'] == true) {
        final user = userResult['user'];
        
        final firebaseResult = await _apiService.hybridRegister({
          'name': user['name'],
          'email': user['email'],
          'password': 'temporary_password_123',
          'phone': user['phone'] ?? '',
          'level_skill': user['level_skill'] ?? 'Beginner',
        });

        return firebaseResult;
      } else {
        return {
          'success': false,
          'message': 'User not found in MySQL',
        };
      }
    } catch (e) {
      debugPrint('Error sync user to Firebase: $e');
      return {
        'success': false,
        'message': 'Sync error: $e',
      };
    }
  }

  // === CHECK AUTH STATUS ===
  Future<Map<String, dynamic>> checkAuthStatus() async {
    try {
      return {
        'success': true,
        'isLoggedIn': false,
        'message': 'Auth status checked',
      };
    } catch (e) {
      debugPrint('Error check auth status: $e');
      return {
        'success': false,
        'message': 'Error checking auth status: $e',
      };
    }
  }

  // === LOGOUT 
  Future<void> logout() async {
    try {
      debugPrint('User logged out');
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // === ADDITIONAL METHODS ===
  Future<Map<String, dynamic>> getVenues() async {
    try {
      return await _apiService.getVenues();
    } catch (e) {
      debugPrint('Error get venues: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getVenueDetail(int id) async {
    try {
      return await _apiService.getVenueDetail(id);
    } catch (e) {
      debugPrint('Error get venue detail: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getMabarList() async {
    try {
      return await _apiService.getMabarList();
    } catch (e) {
      debugPrint('Error get mabar list: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getSparringList() async {
    try {
      return await _apiService.getSparringList();
    } catch (e) {
      debugPrint('Error get sparring list: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getSparringHistory() async {
    try {
      return await _apiService.getSparringHistory();
    } catch (e) {
      debugPrint('Error get sparring history: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      return await _apiService.getNotifications();
    } catch (e) {
      debugPrint('Error get notifications: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteNotification(int id) async {
    try {
      return await _apiService.deleteNotification(id);
    } catch (e) {
      debugPrint('Error delete notification: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getAllJadwal() async {
    try {
      return await _apiService.getAllJadwal();
    } catch (e) {
      debugPrint('Error get all jadwal: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getSparringNews() async {
    try {
      return await _apiService.getSparringNews();
    } catch (e) {
      debugPrint('Error get sparring news: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> addVenue(Map<String, dynamic> venueData) async {
    try {
      return await _apiService.addVenue(venueData);
    } catch (e) {
      debugPrint('Error add venue: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // === TEST 
  Future<void> testConnection() async {
    try {
      await _apiService.testConnection();
    } catch (e) {
      debugPrint('Error test connection: $e');
    }
  }
}