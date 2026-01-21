import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === USER OPERATIONS ===

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        data['firebase_uid'] = query.docs.first.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['firebase_uid'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting user by UID: $e');
      return null;
    }
  }

  Future<void> saveUserData(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  Future<int> generateUserId() async {
    try {
      final doc = await _firestore.collection('counter').doc('users').get();
      int nextId = 1;
      if (doc.exists) {
        nextId = (doc['value'] ?? 0) + 1;
        await _firestore.collection('counter').doc('users').update({
          'value': nextId,
        });
      } else {
        await _firestore.collection('counter').doc('users').set({'value': 1});
      }
      return nextId;
    } catch (e) {
      print('Error generating user ID: $e');
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  // === PASSWORD OPERATIONS ===

  Future<void> savePasswordToFirestore(String uid, String password) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'password': password,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving password: $e');
    }
  }

  Future<void> updatePassword(String uid, String newPassword) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'password': newPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }

  // === SOCIAL DATA OPERATIONS ===

  Future<void> updateUserSocialData(
    String uid,
    List<String> socialUids,
    String loginMethod,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'social_uid': socialUids,
        'login_method': loginMethod,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating social data: $e');
    }
  }

  // === SYNC OPERATIONS ===

  Future<void> syncUserToFirestore(
    String uid,
    int userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final finalData = {
        ...userData,
        'firebase_uid': uid,
        'user_id': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('users').doc(uid).set(finalData);
    } catch (e) {
      print('Error syncing user to Firestore: $e');
      rethrow;
    }
  }

  // === USER PROFILE OPERATIONS (Email as Key) ===

  /// Save user profile with email as document key
  Future<void> saveUserProfile(String email, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(email).set(data);
      print('✓ User profile saved: $email');
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  /// Get user profile by email (document key)
  Future<Map<String, dynamic>?> getUserProfile(String email) async {
    try {
      final doc = await _firestore.collection('users').doc(email).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile by email (document key)
  Future<void> updateUserProfileByEmail(
    String email,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('users').doc(email).update(updates);
      print('✓ User profile updated: $email');
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update Profile User by userId - untuk: name, phone, level_skill, photo_url
  Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    String? name,
    String? phone,
    String? levelSkill,
    String? photoUrl,
  }) async {
    try {
      print('updateUserProfile - Looking for user_id: $userId');
      
      // Cari user berdasarkan user_id (coba sebagai int dan num)
      var query = await _firestore
          .collection('users')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      // Jika tidak ketemu, coba dengan firebase_uid dari current user
      if (query.docs.isEmpty) {
        print('User not found by user_id, trying by firebase_uid...');
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Coba cari by UID sebagai document ID
          final doc = await _firestore.collection('users').doc(currentUser.uid).get();
          if (doc.exists) {
            final docId = doc.id;
            final updateData = <String, dynamic>{
              'updatedAt': FieldValue.serverTimestamp(),
            };

            if (name != null && name.isNotEmpty) updateData['name'] = name;
            if (phone != null && phone.isNotEmpty) updateData['phone'] = phone;
            if (levelSkill != null && levelSkill.isNotEmpty) updateData['level_skill'] = levelSkill;
            if (photoUrl != null) updateData['photo_url'] = photoUrl;

            await _firestore.collection('users').doc(docId).update(updateData);
            print(' Profile updated by UID: $docId');
            print('   Updated fields: $updateData');
            return {'success': true, 'message': 'Profile berhasil diupdate'};
          }
          
          // Coba cari by email
          if (currentUser.email != null) {
            final emailQuery = await _firestore
                .collection('users')
                .where('email', isEqualTo: currentUser.email)
                .limit(1)
                .get();
            
            if (emailQuery.docs.isNotEmpty) {
              final docId = emailQuery.docs.first.id;
              final updateData = <String, dynamic>{
                'updatedAt': FieldValue.serverTimestamp(),
              };

              if (name != null && name.isNotEmpty) updateData['name'] = name;
              if (phone != null && phone.isNotEmpty) updateData['phone'] = phone;
              if (levelSkill != null && levelSkill.isNotEmpty) updateData['level_skill'] = levelSkill;
              if (photoUrl != null) updateData['photo_url'] = photoUrl;

              await _firestore.collection('users').doc(docId).update(updateData);
              print(' Profile updated by email: $docId');
              print('   Updated fields: $updateData');
              return {'success': true, 'message': 'Profile berhasil diupdate'};
            }
          }
        }
        
        print('User not found');
        return {'success': false, 'message': 'User tidak ditemukan'};
      }

      final docId = query.docs.first.id;
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Hanya update field yang disediakan
      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
      }
      if (phone != null && phone.isNotEmpty) {
        updateData['phone'] = phone;
      }
      if (levelSkill != null && levelSkill.isNotEmpty) {
        updateData['level_skill'] = levelSkill;
      }
      if (photoUrl != null) {
        updateData['photo_url'] = photoUrl;
      }

      await _firestore.collection('users').doc(docId).update(updateData);

      print(' Profile updated successfully for user $userId');
      print('   Document ID: $docId');
      print('   Updated fields: $updateData');
      return {'success': true, 'message': 'Profile berhasil diupdate'};
    } catch (e) {
      print('Error updating profile: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // === UTILITY METHODS ===

  /// Cek apakah nomor telepon sudah digunakan
  Future<bool> isPhoneNumberTaken(String phone, {int? excludeUserId}) async {
    try {
      if (phone.isEmpty) return false;
      
      final query = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return false;
      
      // Jika excludeUserId diberikan, skip user tersebut (untuk update profile)
      if (excludeUserId != null) {
        final existingUserId = query.docs.first.data()['user_id'];
        return existingUserId != excludeUserId;
      }
      
      return true;
    } catch (e) {
      print('Error checking phone: $e');
      return false;
    }
  }

  /// Update last_login setiap kali user login
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'last_login': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
      print(' last_login updated for user $uid');
    } catch (e) {
      print('Error updating last_login: $e');
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  String? getCurrentUid() {
    return _firebaseAuth.currentUser?.uid;
  }

  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
