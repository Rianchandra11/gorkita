import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationService {
  // === SINGLETON PATTERN ===
  static final AuthenticationService _instance =
      AuthenticationService._internal();
  factory AuthenticationService() => _instance;
  AuthenticationService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === PUBLIC METHODS - TINGGAL PANGGIL FUTURE ===

  // 1. LOGIN - PANGGIL SAJA
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await firebaseLogin(email, password);
  }

  // 2. REGISTER - PANGGIL SAJA
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await firebaseRegister(userData);
  }

  // 3. GOOGLE SIGN IN - PANGGIL SAJA
  Future<Map<String, dynamic>> googleSignIn() async {
    return await signInWithGoogle();
  }

  // 4. LOGOUT - PANGGIL SAJA
  Future<Map<String, dynamic>> logout() async {
    return await _logout();
  }

  // 5. RESET PASSWORD - PANGGIL SAJA
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String newPassword,
  ) async {
    return await firebaseResetPassword(email, newPassword);
  }

  // 6. CHECK CURRENT USER - PANGGIL SAJA
  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  // 7. GET USER BY EMAIL - PANGGIL METHOD YANG SUDAH ADA
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return await _getFirestoreUserByEmail(email);
  }

  // 8. GET USER BY UID - TAMBAHKAN METHOD BARU YANG SIMPLE
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

  // 9. UPDATE USER PROFILE - TAMBAHKAN METHOD SIMPLE
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // 10. SAVE PROFILE TO FIRESTORE (Email as Key)
  Future<void> saveProfileToFirestore(
    String email,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(email).set(data);
      print('✓ Profile saved to Firestore with email key: $email');
    } catch (e) {
      print('Error saving profile to Firestore: $e');
      rethrow;
    }
  }

  // 11. GET PROFILE FROM FIRESTORE (by Email)
  Future<Map<String, dynamic>?> getProfileFromFirestore(String email) async {
    try {
      final doc = await _firestore.collection('users').doc(email).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting profile from Firestore: $e');
      return null;
    }
  }

  // 12. UPDATE PROFILE IN FIRESTORE (by Email)
  Future<void> updateProfileInFirestore(
    String email,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('users').doc(email).update(updates);
      print('✓ Profile updated in Firestore: $email');
    } catch (e) {
      print('Error updating profile in Firestore: $e');
      rethrow;
    }
  }

  // === PRIVATE METHODS ===
  // (Tetap pertahankan semua private methods yang sudah ada)
  Future<Map<String, dynamic>> firebaseLogin(
    String email,
    String password,
  ) async {
    return {'success': false, 'message': 'Method not implemented'};
  }

  Future<Map<String, dynamic>> firebaseRegister(
    Map<String, dynamic> userData,
  ) async {
    return {'success': false, 'message': 'Method not implemented'};
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    return {'success': false, 'message': 'Method not implemented'};
  }

  Future<Map<String, dynamic>> firebaseResetPassword(
    String email,
    String newPassword,
  ) async {
    return {'success': false, 'message': 'Method not implemented'};
  }

  Future<Map<String, dynamic>> _logout() async {
    return {'success': false, 'message': 'Method not implemented'};
  }

  Future<Map<String, dynamic>?> _getFirestoreUserByEmail(String email) async {
    return null;
  }

  // ... semua method private lainnya tetap ...
}
