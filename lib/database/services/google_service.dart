import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_backend/database/services/data_service.dart';

class GoogleService {
  static final GoogleService _instance = GoogleService._internal();
  factory GoogleService() => _instance;
  GoogleService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserDataService _userDataService = UserDataService();

  // === GOOGLE SIGN-IN METHODS ===

  Future<Map<String, dynamic>> googleLogin() async {
    try {
      print('=== GOOGLE LOGIN STARTED ===');

      // 1. Start Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Google sign-in dibatalkan',
        };
      }

      // 2. Get Google authentication credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return {
          'success': false,
          'message': 'Firebase authentication gagal',
        };
      }

      final uid = firebaseUser.uid;
      final email = firebaseUser.email ?? '';
      final name = firebaseUser.displayName ?? '';
      final photoUrl = firebaseUser.photoURL ?? '';

      // 5. Save to SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('firebase_uid', uid);
      await prefs.setString('login_method', 'google');

      // 6. Check if user exists in Firestore
      final existingUser = await _userDataService.getFirestoreUserByEmail(email);

      if (existingUser != null) {
        // User exists, update login info
        final userId = existingUser['user_id'] as int? ?? 0;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({
              'last_login': FieldValue.serverTimestamp(),
              'photo_url': photoUrl,
              'updated_at': FieldValue.serverTimestamp(),
            });

        return {
          'success': true,
          'message': 'Login Google berhasil',
          'firebase_uid': uid,
          'user_id': userId,
          'user_data': existingUser,
          'login_source': 'google',
        };
      } else {
        // New user, create Firestore document
        final nextUserId = await _userDataService.generateUserId();

        final newUserData = {
          'name': name,
          'email': email,
          'phone': '',
          'level_skill': 'Beginner',
          'login_method': 'google',
          'balance': 0,
          'photo_url': photoUrl,
          'created_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
              'name': newUserData['name'],
              'email': newUserData['email'],
              'phone': newUserData['phone'],
              'level_skill': newUserData['level_skill'],
              'login_method': newUserData['login_method'],
              'balance': newUserData['balance'],
              'photo_url': newUserData['photo_url'],
              'created_at': newUserData['created_at'],
              'last_login': newUserData['last_login'],
              'user_id': nextUserId,
            });

        return {
          'success': true,
          'message': 'Registrasi Google berhasil',
          'firebase_uid': uid,
          'user_id': nextUserId,
          'user_data': newUserData,
          'login_source': 'google',
        };
      }
    } on FirebaseAuthException catch (e) {
      print('Google Login Firebase Error: $e');
      return {
        'success': false,
        'message': 'Google login error: ${e.message}',
        'error_code': e.code,
      };
    } catch (e) {
      print('Google Login Error: $e');
      return {
        'success': false,
        'message': 'Google login error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> googleLogout() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('firebase_uid');
      await prefs.remove('login_method');

      return {
        'success': true,
        'message': 'Logout Google berhasil',
      };
    } catch (e) {
      print('Google Logout Error: $e');
      return {
        'success': false,
        'message': 'Logout error: $e',
      };
    }
  }

  // === UTILITY METHODS ===

  Future<bool> isSignedInWithGoogle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final loginMethod = prefs.getString('login_method');
    return loginMethod == 'google' && _googleSignIn.currentUser != null;
  }

  Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    return _googleSignIn.currentUser;
  }

  Future<User?> getCurrentFirebaseUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<String?> getCurrentUid() async {
    return _firebaseAuth.currentUser?.uid;
  }

  Future<String?> getCurrentEmail() async {
    return _firebaseAuth.currentUser?.email;
  }

  Future<String?> getCurrentDisplayName() async {
    return _firebaseAuth.currentUser?.displayName;
  }

  Future<String?> getCurrentPhotoUrl() async {
    return _firebaseAuth.currentUser?.photoURL;
  }

  // === LINK/UNLINK GOOGLE ACCOUNT ===

  Future<Map<String, dynamic>> linkGoogleAccount() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Google linking dibatalkan',
        };
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Tidak ada user yang sedang login',
        };
      }

      await currentUser.linkWithCredential(credential);

      return {
        'success': true,
        'message': 'Akun Google berhasil di-link',
      };
    } catch (e) {
      print('Link Google Account Error: $e');
      return {
        'success': false,
        'message': 'Link Google error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> unlinkGoogleAccount() async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Tidak ada user yang sedang login',
        };
      }

      // Get Google provider data
      UserInfo? googleProviderData;
      try {
        googleProviderData = currentUser.providerData
            .firstWhere((provider) => provider.providerId == GoogleAuthProvider.PROVIDER_ID);
      } catch (e) {
        googleProviderData = null;
      }

      if (googleProviderData == null) {
        return {
          'success': false,
          'message': 'Akun Google tidak ter-link',
        };
      }

      await currentUser.unlink(GoogleAuthProvider.PROVIDER_ID);
      await _googleSignIn.signOut();

      return {
        'success': true,
        'message': 'Akun Google berhasil di-unlink',
      };
    } catch (e) {
      print('Unlink Google Account Error: $e');
      return {
        'success': false,
        'message': 'Unlink Google error: $e',
      };
    }
  }
}
