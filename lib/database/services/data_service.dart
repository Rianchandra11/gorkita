import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === USER ID GENERATION ===
  
  Future<int> generateUserId() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('user_id', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        print('Tidak ada user di Firestore, memulai user_id dari 1');
        return 1;
      }
      
      final maxUserId = snapshot.docs.first.data()['user_id'] as int? ?? 0;
      final nextId = maxUserId + 1;
      
      print('Maksimal user_id $maxUserId -> selanjutnya user_id: $nextId');
      return nextId;
    } catch (e) {
      print('Error membuat user_id baru: $e');
      return 1;
    }
  }

  // === USER CRUD OPERATIONS ===

  Future<Map<String, dynamic>?> getFirestoreUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        
        return {
          'id': doc.id,
          'user_id': data['user_id'] ?? 0,
          'email': data['email'] ?? '',
          'name': data['name'] ?? '',
          'phone': data['phone'] ?? '',
          'level_skill': data['level_skill'] ?? 'Beginner',
          'photo_url': data['photo_url'] ?? '',
          'balance': data['balance'] ?? 0.0,
          'login_method': data['login_method'] ?? 'email',
          'created_at': data['created_at'],
          'updated_at': data['updated_at'],
        };
      }
      return null;
    } catch (e) {
      print('Get Firestore User by Email Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFirestoreUserByUid(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        
        return {
          'id': doc.id,
          'user_id': data['user_id'] ?? 0,
          'email': data['email'] ?? '',
          'name': data['name'] ?? '',
          'phone': data['phone'] ?? '',
          'level_skill': data['level_skill'] ?? 'Beginner',
          'photo_url': data['photo_url'] ?? '',
          'balance': data['balance'] ?? 0.0,
          'login_method': data['login_method'] ?? 'email',
          'created_at': data['created_at'],
          'updated_at': data['updated_at'],
        };
      }
      return null;
    } catch (e) {
      print('Get Firestore User by UID Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> syncUserToFirestore(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      // Find existing user by email to get Firebase UID
      final existingUser = await getFirestoreUserByEmail(userData['email']);
      
      String? firebaseUid;
      
      if (existingUser != null) {
        // User exists, get the document ID (which should be Firebase UID)
        firebaseUid = existingUser['id'] as String?;
      } else {
        // New user - we need to get UID from auth service later
        print('New user, will be linked when Firebase auth is created');
      }

      final userDocRef = firebaseUid != null 
          ? _firestore.collection('users').doc(firebaseUid)
          : _firestore.collection('users').doc();

      final completeData = {
        'user_id': userId,
        ...userData,
        'updated_at': FieldValue.serverTimestamp(),
      };

      // If it's a new document, add created_at
      if (existingUser == null) {
        completeData['created_at'] = FieldValue.serverTimestamp();
      }

      await userDocRef.set(completeData, SetOptions(merge: true));

      // Save user_id to shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);

      return {
        'success': true,
        'message': 'User data synced to Firestore',
        'user_id': userId,
        'firebase_uid': userDocRef.id,
        'user_data': completeData,
      };
    } catch (e) {
      print('Sync User to Firestore Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<void> savePasswordToFirestore(
    String? uid,
    String password,
  ) async {
    try {
      if (uid == null) {
        print('UID is null, cannot save password to Firestore');
        return;
      }

      await _firestore.collection('users').doc(uid).update({
        'password': password,
        'password_updated_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      print('Password saved to Firestore for UID: $uid');
    } catch (e) {
      print('Save Password to Firestore Error: $e');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      final updateData = {
        ...updates,
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).update(updateData);

      return {
        'success': true,
        'message': 'Profil berhasil diperbarui',
      };
    } catch (e) {
      print('Update User Profile Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateUserBalance(
    String uid,
    double amount,
    String transactionType, // 'add', 'subtract', 'set'
    String? description,
  ) async {
    try {
      // Get current balance
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return {'success': false, 'message': 'User tidak ditemukan'};
      }

      final currentBalance = userDoc.data()?['balance'] ?? 0.0;
      double newBalance;

      switch (transactionType) {
        case 'add':
          newBalance = currentBalance + amount;
          break;
        case 'subtract':
          if (currentBalance < amount) {
            return {'success': false, 'message': 'Saldo tidak cukup'};
          }
          newBalance = currentBalance - amount;
          break;
        case 'set':
          newBalance = amount;
          break;
        default:
          return {'success': false, 'message': 'Tipe transaksi tidak valid'};
      }

      // Update balance
      await _firestore.collection('users').doc(uid).update({
        'balance': newBalance,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Record transaction
      if (description != null) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .add({
          'amount': amount,
          'type': transactionType,
          'description': description,
          'old_balance': currentBalance,
          'new_balance': newBalance,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      return {
        'success': true,
        'message': 'Saldo berhasil diperbarui',
        'old_balance': currentBalance,
        'new_balance': newBalance,
      };
    } catch (e) {
      print('Update User Balance Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // === UTILITY METHODS ===

  Future<int> getCurrentUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  Future<String?> getCurrentUserUid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('firebase_uid');
  }

  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }
}