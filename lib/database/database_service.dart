import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uts_backend/helper/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = BaseUrl.url;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> hybridLogin(
  String email,
  String password,
) async {
  try {
    print('=== HYBRID LOGIN STARTED ===');
    print('Email: $email');

    Map<String, dynamic>? mysqlResult;
    Map<String, dynamic>? firebaseResult;

    try {
      firebaseResult = await _loginToFirebase(email, password);
      print('Firebase login result: ${firebaseResult['success']}');
    } catch (e) {
      print('Firebase login error: $e');
    }

    try {
      mysqlResult = await loginUser(email, password);
      print('MySQL login result: ${mysqlResult['success']}');
    } catch (e) {
      print('MySQL login error: $e');
    }

    if ((firebaseResult?['success'] == true) ||
        (mysqlResult?['success'] == true)) {
      print('=== LOGIN SUCCESS IN AT LEAST ONE SYSTEM ===');

      await _autoSyncSystems(email, password, mysqlResult, firebaseResult);

      final userData = await _getUserDataAfterLogin(email, mysqlResult);
      final mysqlUserId = userData['user_id'];
      
      // ✅ SYNC TO FIRESTORE SETELAH LOGIN
      await syncUserToFirestore(mysqlUserId, userData);
      
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id', mysqlUserId);
      
      return {
        'success': true,
        'message': 'Login berhasil',
        'user_id': mysqlUserId,
        'firebase_uid': firebaseResult?['uid'],
        'user_data': userData,
        'login_source': firebaseResult?['success'] == true ? 'firebase' : 'mysql',
      };
    } else {
      return {
        'success': false,
        'message': mysqlResult?['message'] ?? firebaseResult?['message'] ?? 'Login gagal',
      };
    }
  } catch (e) {
    print('Hybrid Login Error: $e');
    return {'success': false, 'message': 'Login error: $e'};
  }
}

Future<Map<String, dynamic>> hybridRegister(
  Map<String, dynamic> userData,
) async {
  try {
    // ✅ CEK EMAIL DI MYSQL DULU SEBELUM APA-APA
    final emailCheck = await checkEmailRegistered(userData['email']);
    if (emailCheck['isRegistered'] == true) {
      return {
        'success': false,
        'message': 'Email sudah terdaftar',
      };
    }

    Map<String, dynamic>? mysqlResult;
    Map<String, dynamic>? firebaseResult;
    
    // ✅ 1. REGISTER KE MYSQL DULU
    try {
      mysqlResult = await registerUser(userData);
      print('MySQL registration result: ${mysqlResult['success']}');
    } catch (e) {
      print('MySQL registration error: $e');
    }
    
    // ✅ 2. HANYA BUAT FIREBASE JIKA MYSQL BERHASIL
    if (mysqlResult?['success'] == true) {
      try {
        firebaseResult = await _registerToFirebase(
          userData['email'],
          userData['password'],
        );
        print('Firebase registration result: ${firebaseResult['success']}');
      } catch (e) {
        print('Firebase registration error: $e');
        // Firebase gagal tapi MySQL berhasil - tetap sukses registrasi
      }
      
      final mysqlUserId = await _getUserIdByEmail(userData['email']);
      
      // ✅ SYNC NEW USER TO FIRESTORE (jika Firebase berhasil)
      if (firebaseResult?['success'] == true) {
        final newUserData = {
          'name': userData['name'],
          'email': userData['email'],
          'phone': userData['phone'] ?? '',
          'level_skill': userData['level_skill'] ?? 'Beginner',
          'login_method': 'email',
          'balance': 0,
        };
        await syncUserToFirestore(mysqlUserId, newUserData);
      }
      
      return {
        'success': true,
        'message': 'Registrasi berhasil',
        'user_id': mysqlUserId,
        'firebase_uid': firebaseResult?['uid'],
        'firebase_status': firebaseResult?['success'] == true ? 'created' : 'pending_sync',
      };
    } else {
      // ❌ MYSQL GAGAL - JANGAN BUAT FIREBASE
      return {
        'success': false,
        'message': mysqlResult?['message'] ?? 'Registrasi gagal di database',
      };
    }
  } catch (e) {
    print('Hybrid Registration Error: $e');
    return {'success': false, 'message': 'Registrasi error: $e'};
  }
} 
  Future<Map<String, dynamic>> _loginToFirebase(
  String email,
  String password,
) async {
  try {
    final UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    // ✅ Update last login time
    await userCredential.user?.reload();

    return {
      'success': true,
      'uid': userCredential.user?.uid,
      'user': userCredential.user,
    };
  } on FirebaseAuthException catch (e) {
    String message = 'Firebase login failed';
    
    // ✅ More specific error messages
    switch (e.code) {
      case 'user-not-found':
        message = 'Email tidak terdaftar';
        break;
      case 'wrong-password':
        message = 'Password salah';
        break;
      case 'user-disabled':
        message = 'Akun dinonaktifkan';
        break;
      default:
        message = e.message ?? 'Login gagal';
    }
    
    return {
      'success': false,
      'message': message,
      'error_code': e.code,
    };
  }
}

  Future<Map<String, dynamic>> _registerToFirebase(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      return {
        'success': true,
        'uid': userCredential.user?.uid,
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return {'success': true, 'message': 'User already exists in Firebase'};
      }

      return {
        'success': false,
        'message': e.message ?? 'Firebase registration failed',
        'error_code': e.code,
      };
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-reset-code'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );

      print('Send Reset Code Status: ${response.statusCode}');
      print('Send Reset Code Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'],
          'reset_code': data['debug_code'],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Send Reset Code Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPasswordWithCode(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password-with-code'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'code': code,
          'new_password': newPassword,
        }),
      );

      print('Reset Password Status: ${response.statusCode}');
      print('Reset Password Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Reset Password Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(
    String email,
    String code,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-reset-code'),
        headers: _headers,
        body: jsonEncode({'email': email, 'code': code}),
      );

      print('Verify Reset Code Status: ${response.statusCode}');
      print('Verify Reset Code Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Verify Reset Code Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<void> _autoSyncSystems(
  String email,
  String password,
  Map<String, dynamic>? mysqlResult,
  Map<String, dynamic>? firebaseResult,
) async {
  print('=== AUTO-SYNC SYSTEMS ===');

  if (mysqlResult?['success'] == true && 
      firebaseResult?['success'] == false &&
      firebaseResult?['error_code'] != 'user-not-found') {
    print('Skipping sync - Firebase error is not user-not-found');
    return;
  }

  if (mysqlResult?['success'] == true &&
      (firebaseResult?['success'] == false || 
       firebaseResult?['error_code'] == 'user-not-found')) {
    print('Creating Firebase account for existing MySQL user...');
    await _registerToFirebase(email, password);
  } else if (firebaseResult?['success'] == true &&
      mysqlResult?['success'] == false) {
    print('Creating MySQL account for existing Firebase user...');
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      await registerUser({
        'name': firebaseUser.displayName ?? 'User from Firebase',
        'email': email,
        'password': password,
        'phone': firebaseUser.phoneNumber ?? '',
        'level_skill': 'Beginner',
      });
    }
  }

  print('=== AUTO-SYNC COMPLETE ===');
}
// ✅ UPDATE USER DATA IN FIRESTORE
Future<void> updateUserInFirestore(Map<String, dynamic> updates) async {
  try {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            ...updates,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      print('✅ User updated in Firestore');
    }
  } catch (e) {
    print('❌ Update Firestore user error: $e');
  }
}

// ✅ GET USER FROM FIRESTORE
Future<Map<String, dynamic>?> getUserFromFirestore() async {
  try {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
    }
    return null;
  } catch (e) {
    print('❌ Get Firestore user error: $e');
    return null;
  }
}

  Future<Map<String, dynamic>> _getUserDataAfterLogin(
    String email,
    Map<String, dynamic>? mysqlResult,
  ) async {
    if (mysqlResult?['success'] == true) {
      return {
        'user_id': mysqlResult?['user_id'] ?? 0,
        'email': email,
        'name': mysqlResult?['user_data']?['name'] ?? '',
        'phone': mysqlResult?['user_data']?['phone'] ?? '',
        'level_skill': mysqlResult?['user_data']?['level_skill'] ?? 'Beginner',
        'photo_url': mysqlResult?['user_data']?['photo_url'] ?? '',
      };
    }

    try {
      final userData = await _findUserByEmail(email);
      return {
        'user_id': userData['user_id'] ?? 0,
        'email': email,
        'name': userData['name'] ?? '',
        'phone': userData['phone'] ?? '',
        'level_skill': userData['level_skill'] ?? 'Beginner',
        'photo_url': userData['photo_url'] ?? '',
      };
    } catch (e) {
      return {
        'user_id': 0,
        'email': email,
        'name': '',
        'phone': '',
        'level_skill': 'Beginner',
        'photo_url': '',
      };
    }
  }

  Future<int> _getUserIdByEmail(String email) async {
    try {
      final checkResult = await checkEmailRegistered(email);
      if (checkResult['isRegistered'] == true) {
        final userData = await _findUserByEmail(email);
        return userData['user_id'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> _findUserByEmail(String email) async {
  try {
    // ✅ Buat endpoint khusus untuk get user by email tanpa password
    final response = await http.post(
      Uri.parse('$baseUrl/get-user-by-email'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return {
          'user_id': data['user_id'],
          'name': data['name'] ?? '',
          'phone': data['phone'] ?? '',
          'level_skill': data['level_skill'] ?? 'Beginner',
          'photo_url': data['photo_url'] ?? '',
        };
      }
    }
    return {'user_id': 0};
  } catch (e) {
    return {'user_id': 0};
  }
}
Future<void> hybridLogout() async {
  try {
    // Clear Firebase
    await _firebaseAuth.signOut();
    
    // Clear SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('user_data');
    
    print('=== HYBRID LOGOUT COMPLETE ===');
  } catch (e) {
    print('Logout error: $e');
  }
}
  Future<void> testConnection() async {
    try {
      print('Base URL: $baseUrl');
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/test'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 10));

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
    } catch (e) {
      print('=== CONNECTION ERROR ===');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
    }
  }
  // ✅ SYNC USER DATA TO FIRESTORE (DENGAN FIELD YANG SESUAI GAMBAR)
Future<void> syncUserToFirestore(int mysqlUserId, Map<String, dynamic> userData) async {
  try {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'user_id': mysqlUserId, // ✅ SESUAI GAMBAR
            'balance': userData['balance'] ?? 0, // ✅ SESUAI GAMBAR
            'createdAt': FieldValue.serverTimestamp(),
            'email': userData['email'],
            'email_verified': userData['email_verified'] ?? true, // ✅ SESUAI GAMBAR
            'firebase_uid': user.uid, // ✅ SESUAI GAMBAR
            'last_login': FieldValue.serverTimestamp(),
            'level_skill': userData['level_skill'] ?? 'beginner', // ✅ SESUAI GAMBAR
            'login_method': userData['login_method'] ?? 'email', // ✅ SESUAI GAMBAR
            'name': userData['name'],
            'photo_url': userData['photo_url'] ?? '',
            'social_uid': userData['social_uid'] ?? ['email'], // ✅ SESUAI GAMBAR
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      print('✅ User data synced to Firestore with user_id: $mysqlUserId');
    }
  } catch (e) {
    print('❌ Firestore sync error: $e');
  }
}
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate/login/user'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('MySQL Login Status: ${response.statusCode}');
      print('MySQL Login Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['allow'],
          'message': data['status'],
          'user_id': data['id_user'],
          'user_data': data['user_data'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('MySQL Login Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

Future<Map<String, dynamic>> checkEmailRegistered(String email) async {
  try {
    final response = await http.post( // ✅ GANTI KE POST
      Uri.parse('$baseUrl/check/user/daftar'),
      headers: _headers,
      body: jsonEncode({'email': email}), // ✅ TAMBAH BODY
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': data['status'],
        'isRegistered': !data['allow'], // ✅ SESUAI RESPONSE BARU
      };
    } else {
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
        'isRegistered': false,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Connection error: $e',
      'isRegistered': false,
    };
  }
}
Future<Map<String, dynamic>> registerUser(
  Map<String, dynamic> userData,
) async {
  try {
    print('=== MYSQL REGISTER DEBUG ===');
    print('📤 Sending data to: $baseUrl/add/user');
    print('📝 Data: ${jsonEncode(userData)}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/add/user'),
      headers: _headers,
      body: jsonEncode({
        'name': userData['name'],
        'email': userData['email'],
        'password': userData['password'],
        'phone': userData['phone'],
        'level_skill': userData['level_skill'] ?? 'Beginner',
      }),
    ).timeout(Duration(seconds: 10));

    print('📨 Response Status: ${response.statusCode}');
    print('📨 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ MySQL Registration SUCCESS - User ID: ${data['user_id']}');
      return {
        'success': true, 
        'message': data['message'],
        'user_id': data['user_id']
      };
    } else {
      final errorData = jsonDecode(response.body);
      print('❌ MySQL Registration FAILED: ${errorData['message']}');
      return {
        'success': false,
        'message': errorData['message'] ?? 'Server error: ${response.statusCode}',
      };
    }
  } catch (e) {
    print('❌ MySQL Register Exception: $e');
    return {
      'success': false, 
      'message': 'Connection error: $e'
    };
  }
}

 Future<Map<String, dynamic>> getUserById(int id) async {
  try {
    final url = '$baseUrl/user/$id';
    print('📡 GET User URL: $url');

    final response = await http.get(Uri.parse(url), headers: _headers);

    print('📨 Response Status: ${response.statusCode}');
    print('📨 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ UPDATE: Response sekarang langsung object, bukan array
      if (data['data'] != null) {
        final user = data['data']; // ✅ LANGSUNG DATA OBJECT
        return {
          'success': true,
          'user': {
            'id': user['user_id'],
            'name': user['name'],
            'email': user['email'],
            'phone': user['phone'],
            'level_skill': user['level_skill'],
            'photo_url': user['photo_url'],
            'email_verified': user['email_verified'] ?? 0, // ✅ TAMBAH INI
            'login_method': user['login_method'] ?? 'email', // ✅ TAMBAH INI
          },
        };
      } else {
        return {
          'success': false,
          'message': 'User data not found in response',
        };
      }
    } else {
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    }
  } catch (e) {
    print('❌ getUserById Error: $e');
    return {'success': false, 'message': 'Connection error: $e'};
  }
}

Future<Map<String, dynamic>> sendVerificationCode(String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/send-verification-code'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'],
        'debug_code': data['debug_code'], // Untuk development
      };
    } else {
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Connection error: $e'};
  }
}

Future<Map<String, dynamic>> verifyEmailCode(String email, String code) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-email-code'),
      headers: _headers,
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'],
      };
    } else {
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Connection error: $e'};
  }
}


Future<Map<String, dynamic>> googleAuth(
  String name, 
  String email, 
  String googleUid, 
  String? photoUrl
) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'google_uid': googleUid,
        'photo_url': photoUrl ?? '',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final mysqlUserId = data['user_id'];
      
      // ✅ SYNC GOOGLE USER TO FIRESTORE
      if (data['success'] == true) {
        final userData = data['user_data'] ?? {};
        await syncUserToFirestore(mysqlUserId, {
          ...userData,
          'social_uid': ['google', 'email'], // ✅ SESUAI GAMBAR
          'login_method': 'google',
        });
      }
      
      return {
        'success': data['success'] ?? false,
        'message': data['message'],
        'user_id': mysqlUserId,
        'user_data': data['user_data'] ?? {},
        'is_new_user': data['is_new_user'] ?? false,
      };
    } else {
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Connection error: $e'};
  }
}


  Future<Map<String, dynamic>> updatePassword(
    int id,
    String newPassword,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/edit/password/$id'),
        headers: _headers,
        body: jsonEncode({'password': newPassword}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Password updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> uploadProfileImage(
    int userId,
    String imageUrl,
  ) async {
    try {
      print('=== UPDATE PROFILE IMAGE DEBUG ===');
      print('User ID: $userId');
      print('Image URL: $imageUrl');

      final response = await http.put(
        Uri.parse('$baseUrl/gambar/profil/$userId'),
        headers: _headers,
        body: jsonEncode({'url': imageUrl}),
      );

      print('📤 Update Status: ${response.statusCode}');
      print('📤 Update Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Berhasil update foto profil',
          'photo_url': data['data']?['photo_url'] ?? imageUrl,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              errorData['message'] ??
              'Gagal update gambar: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Update Profile Image Error: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
  Future<Map<String, dynamic>> updateFirebaseProfile(
  String name, 
  String? photoUrl
) async {
  try {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
      return {'success': true, 'message': 'Firebase profile updated'};
    }
    return {'success': false, 'message': 'No user logged in'};
  } catch (e) {
    return {'success': false, 'message': 'Firebase update error: $e'};
  }
}

  Future<Map<String, dynamic>> getVenues() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/display/venue'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getVenueDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/detail/venue/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMabarList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/display/mabar'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getSparringList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/display/sparring'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getSparringHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sparring/history'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notif'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteNotification(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notif/delete/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAllJadwal() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all/jadwal'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getSparringNews() async {
    try {
      final url = Uri.parse('$baseUrl/sparring-news');
      print('=== SPARRING NEWS API DEBUG ===');
      print('📡 Full URL: $url');
      print('Base URL: $baseUrl');
      print('========================');

      final response = await http.get(url);

      print('=== RESPONSE DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('========================');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to API: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('=== ERROR DEBUG ===');
      print('Error: $e');
      print('========================');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getSparring() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sparring'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to load sparring from API: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> addVenue(Map<String, dynamic> venueData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add/venue'),
        headers: _headers,
        body: jsonEncode(venueData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'data': data['hasil'],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
