import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class AppService {
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;
  AppService._internal();

  final AuthenticationService _authService = AuthenticationService();
  final DatabaseService _dbService = DatabaseService();

  // === LOGIN ===
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await _authService.firebaseLogin(email, password);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Login error: $e'};
    }
  }

  // === REGISTER ===
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final result = await _authService.firebaseRegister(userData);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Register error: $e'};
    }
  }

  // === GOOGLE LOGIN - Get user info optimized ===
  Future<Map<String, dynamic>> googleLogin() async {
    try {
      final result = await _authService.signInWithGoogle();
      if (result['success'] == true && result['user'] != null) {
        final user = result['user'] as User;
        return {
          'success': true,
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'User',
          'photoUrl': user.photoURL ?? '',
          'isNewUser':
              user.metadata.creationTime == user.metadata.lastSignInTime,
          'message': 'Google login success',
        };
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Google login error: $e'};
    }
  }

  // === LOGOUT ===
  Future<Map<String, dynamic>> logout() async {
    try {
      return await _authService.logout();
    } catch (e) {
      return {'success': false, 'message': 'Logout error: $e'};
    }
  }

  // === RESET PASSWORD ===
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String newPassword,
  ) async {
    try {
      return await _authService.firebaseResetPassword(email, newPassword);
    } catch (e) {
      return {'success': false, 'message': 'Reset error: $e'};
    }
  }

  // === GET PROFILE ===
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        return {'success': false, 'message': 'User tidak login'};
      }
      return {
        'success': true,
        'user_data': {
          'email': user.email,
          'displayName': user.displayName ?? 'User',
          'photoUrl': user.photoURL ?? '',
          'uid': user.uid,
        },
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // === CHECK LOGIN ===
  Future<bool> isLoggedIn() async {
    return _authService.getCurrentUser() != null;
  }

  // === GET UID ===
  Future<String?> getCurrentUid() async {
    return _authService.getCurrentUser()?.uid;
  }

  // === GET USER ID ===
  Future<int> getCurrentUserId() async {
    return 0;
  }

  User? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  // === HYBRID LOGIN ===
  Future<Map<String, dynamic>> hybridLogin(
    String email,
    String password,
  ) async {
    return await _authService.firebaseLogin(email, password);
  }

  // === GET USER BY ID ===
  // Ambil data user dari Firestore terlebih dahulu, fallback ke Firebase Auth
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final firebaseUser = _authService.getCurrentUser();
      if (firebaseUser == null) {
        print('getUserById: No current user');
        return null;
      }

      print('getUserById: Looking for user ${firebaseUser.email} / ${firebaseUser.uid}');

      Map<String, dynamic>? firestoreData;

      // 1. Coba ambil dari Firestore by Email (document ID = email)
      if (firebaseUser.email != null) {
        firestoreData = await _dbService.getUserByEmail(firebaseUser.email!);
        print('📧 getUserByEmail result: ${firestoreData != null ? "Found" : "Not found"}');
      }
      
      // 2. Jika tidak ada, coba by UID
      if (firestoreData == null) {
        firestoreData = await _dbService.getUserByUid(firebaseUser.uid);
        print('🔑 getUserByUid result: ${firestoreData != null ? "Found" : "Not found"}');
      }

      // 3. Jika ada data Firestore, return dengan merge Firebase Auth data
      if (firestoreData != null) {
        print(' Firestore data found:');
        print('   - name: ${firestoreData['name']}');
        print('   - photo_url: ${firestoreData['photo_url']}');
        
        return {
          'user_id': userId,
          'name': firestoreData['name'] ?? firestoreData['displayName'] ?? firebaseUser.displayName ?? 'User',
          'email': firestoreData['email'] ?? firebaseUser.email ?? '',
          'phone': firestoreData['phone'] ?? firestoreData['nohp'] ?? '',
          'level_skill': firestoreData['level_skill'] ?? 'Beginner',
          'photo_url': firestoreData['photo_url'] ?? firebaseUser.photoURL ?? '',
          'firebase_uid': firebaseUser.uid,
        };
      }

      // 4. Fallback: hanya dari Firebase Auth (untuk user yang belum ada di Firestore)
      print('No Firestore data, using Firebase Auth fallback');
      return {
        'user_id': userId,
        'name': firebaseUser.displayName ?? 'User',
        'email': firebaseUser.email ?? '',
        'phone': '',
        'level_skill': 'Beginner',
        'photo_url': firebaseUser.photoURL ?? '',
        'firebase_uid': firebaseUser.uid,
      };
    } catch (e) {
      print('Error getUserById: $e');
      return null;
    }
  }

  // === CHECK EMAIL REGISTERED ===
  Future<bool> checkEmailRegistered(String email) async {
    try {
      final user = _authService.getCurrentUser();
      return user != null && user.email == email;
    } catch (e) {
      return false;
    }
  }

  // === HYBRID REGISTER ===
  Future<Map<String, dynamic>> hybridRegister(
    Map<String, dynamic> userData,
  ) async {
    return await _authService.firebaseRegister(userData);
  }

  // === UPLOAD PROFILE IMAGE ===
  Future<Map<String, dynamic>> uploadProfileImage(
    String userId,
    String imageUrl,
  ) async {
    try {
      return {
        'success': true,
        'message': 'Image uploaded',
        'image_url': imageUrl,
      };
    } catch (e) {
      return {'success': false, 'message': 'Upload failed: $e'};
    }
  }

  // === SIGN IN WITH GOOGLE ===
  Future<Map<String, dynamic>> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  // === SEND PASSWORD RESET CODE ===
  Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    try {
      // Simulate sending reset code with quick timeout
      await Future.delayed(const Duration(milliseconds: 1500));
      return {
        'success': true,
        'message': 'Password reset code sent to $email',
        'email': email,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to send reset code: $e'};
    }
  }

  // === RESET PASSWORD WITH CODE ===
  Future<Map<String, dynamic>> resetPasswordWithCode(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      // Simulate code verification with quick timeout
      await Future.delayed(const Duration(milliseconds: 2000));
      return await _authService.firebaseResetPassword(email, newPassword);
    } catch (e) {
      return {'success': false, 'message': 'Reset failed: $e'};
    }
  }

  // === FINALIZE PASSWORD RESET WITH AUTH ===
  Future<Map<String, dynamic>> finalizePasswordResetWithAuth(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      return await _authService.firebaseResetPassword(email, newPassword);
    } catch (e) {
      return {'success': false, 'message': 'Finalize failed: $e'};
    }
  }

  // === GET NOTIFICATIONS ===
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      return [];
    } catch (e) {
      return [];
    }
  }

  // === CEK NOMOR TELEPON SUDAH DIGUNAKAN ===
  Future<bool> isPhoneNumberTaken(String phone, {int? excludeUserId}) async {
    try {
      return await _dbService.isPhoneNumberTaken(
        phone,
        excludeUserId: excludeUserId,
      );
    } catch (e) {
      print('Error checking phone: $e');
      return false;
    }
  }

  // === UPDATE PROFILE (name, phone, level_skill, photo_url) ===
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? name,
    String? phone,
    String? levelSkill,
    String? photoUrl,
  }) async {
    try {
      // Cek jika phone diubah, pastikan tidak duplikat
      if (phone != null && phone.isNotEmpty) {
        final isTaken = await isPhoneNumberTaken(phone, excludeUserId: userId);
        if (isTaken) {
          return {
            'success': false,
            'message': 'Nomor telepon ini sudah digunakan',
          };
        }
      }

      final result = await _dbService.updateUserProfile(
        userId: userId,
        name: name,
        phone: phone,
        levelSkill: levelSkill,
        photoUrl: photoUrl,
      );
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Update profile error: $e'};
    }
  }

  // === GOOGLE LOGOUT ===
  Future<Map<String, dynamic>> googleLogout() async {
    return await logout();
  }

  // === INITIALIZE APP ===
  Future<void> initializeApp() async {
    try {
      // Perform any app initialization
    } catch (e) {
      print('Error initializing app: $e');
    }
  }
}
