import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_backend/services/data_service.dart';
import 'auth_service.dart';

class HybridService {
  static final HybridService _instance = HybridService._internal();
  factory HybridService() => _instance;
  HybridService._internal();

  final AuthenticationService _authService = AuthenticationService();
  final UserDataService _userDataService = UserDataService();

  // === COMPLETE HYBRID LOGIN ===

  Future<Map<String, dynamic>> hybridLogin(
    String email,
    String password,
  ) async {
    try {
      print('=== HYBRID LOGIN STARTED ===');
      print('Email: $email');

      // 1. Try Firebase Auth login
      final authResult = await _authService.firebaseLogin(email, password);

      if (authResult['success'] == true) {
        final uid = authResult['firebase_uid'];
        
        // 2. Get user data from Firestore
        final userData = await _userDataService.getFirestoreUserByEmail(email);

        if (userData != null) {
          final userId = userData['user_id'] as int? ?? 0;
          
          // 3. Save password to Firestore for backup
          await _userDataService.savePasswordToFirestore(uid, password);

          return {
            'success': true,
            'message': 'Login berhasil',
            'firebase_uid': uid,
            'user_id': userId,
            'user_data': userData,
            'login_source': 'firebase',
          };
        } else {
          // User authenticated but no Firestore data
          return {
            'success': false,
            'message': 'User data tidak ditemukan di Firestore',
          };
        }
      } else {
        // Firebase Auth failed, try Firestore fallback
        return await _firestoreFallbackLogin(email, password);
      }
    } catch (e) {
      print('Hybrid Login Error: $e');
      return {'success': false, 'message': 'Login error: $e'};
    }
  }

  Future<Map<String, dynamic>> _firestoreFallbackLogin(
    String email,
    String password,
  ) async {
    try {
      print('=== FIRESTORE FALLBACK LOGIN ===');
      
      // 1. Check if user exists in Firestore
      final userData = await _userDataService.getFirestoreUserByEmail(email);
      
      if (userData != null) {
        // 2. Check password (simplified - in real app hash the password)
        final storedPassword = await _getStoredPassword(userData['id'] as String?);
        
        if (storedPassword == password) {
          final uid = userData['id'] as String?;
          final userId = userData['user_id'] as int? ?? 0;
          
          // 3. Try to update/create Firebase Auth account
          try {
            // Update password fallback is handled in auth service
            // await _authService.updateFirebaseAuthPasswordWithFallback(
            //   email, password, uid);
          } catch (e) {
            print('Tidak bisa update Firebase Auth: $e');
          }

          return {
            'success': true,
            'message': 'Login berhasil',
            'firebase_uid': uid,
            'user_id': userId,
            'user_data': userData,
            'login_source': 'firestore_fallback',
          };
        }
      }
      
      return {
        'success': false,
        'message': 'Email atau password salah',
      };
    } catch (e) {
      print('Firestore Fallback Login Error: $e');
      return {'success': false, 'message': 'Login fallback error: $e'};
    }
  }

  Future<String?> _getStoredPassword(String? uid) async {
    if (uid == null) return null;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      return doc.data()?['password'] as String?;
    } catch (e) {
      return null;
    }
  }

  // === COMPLETE HYBRID REGISTER ===

  Future<Map<String, dynamic>> hybridRegister(
    Map<String, dynamic> userData,
  ) async {
    try {
      print('=== HYBRID REGISTRATION STARTED ===');

      // 1. Generate new user_id
      final nextUserId = await _userDataService.generateUserId();

      // 2. Prepare user data for Firestore
      final newUserData = {
        'name': userData['name'], 
        'email': userData['email'], 
        'phone': userData['phone'] ?? '',
        'level_skill': userData['level_skill'] ?? 'Beginner',
        'login_method': 'email',
        'balance': 0,
      };

      // 3. Sync to Firestore first (creates document)
      final syncResult = await _userDataService.syncUserToFirestore(
        nextUserId, 
        newUserData,
      );

      if (!syncResult['success']) {
        return syncResult;
      }

      final firebaseUid = syncResult['firebase_uid'] as String?;

      // 4. Create Firebase Auth account
      final authResult = await _authService.firebaseRegister(userData);

      if (authResult['success'] == true) {
        final authUid = authResult['firebase_uid'] as String?;
        
        // 5. Save password to Firestore
        await _userDataService.savePasswordToFirestore(
          authUid ?? firebaseUid,
          userData['password'],
        );

        // 6. If Firebase UID is different from Firestore doc ID, update it
        if (authUid != null && firebaseUid != null && authUid != firebaseUid) {
          await _updateFirestoreUid(firebaseUid, authUid);
        }

        return {
          'success': true,
          'message': 'Registrasi berhasil',
          'firebase_uid': authUid ?? firebaseUid,
          'user_id': nextUserId,
          'user_data': newUserData,
          'login_source': 'firebase',
        };
      } else {
        return authResult;
      }
    } catch (e) {
      print('Hybrid Registration Error: $e');
      return {'success': false, 'message': 'Registrasi error: $e'};
    }
  }

  Future<void> _updateFirestoreUid(String oldUid, String newUid) async {
    try {
      // Get data from old document
      final oldDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(oldUid)
          .get();
      
      if (oldDoc.exists) {
        // Create new document with new UID
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUid)
            .set(oldDoc.data()!);
        
        // Delete old document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(oldUid)
            .delete();
        
        print('Updated Firestore document UID from $oldUid to $newUid');
      }
    } catch (e) {
      print('Update Firestore UID Error: $e');
    }
  }

  // === COMPLETE PASSWORD RESET ===

  Future<Map<String, dynamic>> hybridResetPassword(
    String email,
    String newPassword,
  ) async {
    try {
      print('=== HYBRID PASSWORD RESET ===');

      // 1. Reset password in Firebase Auth
      final authResult = await _authService.firebaseResetPassword(
        email, 
        newPassword,
      );

      if (authResult['success'] == true) {
        // 2. Get current user
        final user = _authService.getCurrentUser();
        final uid = user?.uid;
        
        if (uid != null) {
          // 3. Update password in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({
                'password': newPassword,
                'password_updated_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
        }

        return {'success': true, 'message': 'Password berhasil diubah'};
      } else {
        return authResult;
      }
    } catch (e) {
      print('Hybrid Reset Password Error: $e');
      return {'success': false, 'message': 'Reset password error: $e'};
    }
  }

  // === COMPOSITE USER PROFILE ===

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final uid = await _userDataService.getCurrentUserUid();
      
      if (uid == null) {
        return {'success': false, 'message': 'User tidak login'};
      }

      final userData = await _userDataService.getFirestoreUserByUid(uid);
      
      if (userData != null) {
        return {
          'success': true,
          'user_data': userData,
        };
      } else {
        return {
          'success': false,
          'message': 'User data tidak ditemukan',
        };
      }
    } catch (e) {
      print('Get User Profile Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      // Logout from auth
      final authResult = await _authService.logout();
      
      // Clear user data preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      
      return authResult;
    } catch (e) {
      print('Hybrid Logout Error: $e');
      return {'success': false, 'message': 'Logout error: $e'};
    }
  }
}