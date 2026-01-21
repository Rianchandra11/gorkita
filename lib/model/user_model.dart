import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel {
  final String uid;
  final int userId;
  final String name;
  final String email;
  final String phone;
  final String levelSkill;
  final String loginMethod;
  final double balance;
  final String password;
  final String? photoUrl;
  final List<String> socialUid;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.levelSkill,
    required this.loginMethod,
    required this.balance,
    required this.password,
    this.photoUrl,
    List<String>? socialUid,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : socialUid = socialUid ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserModel(
      uid: snapshot.id,
      userId: data?['user_id'] ?? 0,
      name: data?['name'] ?? '',
      email: data?['email'] ?? '',
      phone: data?['phone'] ?? '',
      levelSkill: data?['level_skill'] ?? 'Beginner',
      loginMethod: data?['login_method'] ?? 'email',
      balance: (data?['balance'] ?? 0).toDouble(),
      password: data?['password'] ?? '',
      photoUrl: data?['photo_url'],
      socialUid: List<String>.from(data?['social_uid'] ?? []),
      createdAt: data?['createdAt'] is Timestamp
          ? (data?['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data?['createdAt']?.toString() ?? DateTime.now().toString()),
      updatedAt: data?['updatedAt'] is Timestamp
          ? (data?['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(data?['updatedAt']?.toString() ?? DateTime.now().toString()),
    );
  }
  
  Map<String, dynamic> toFirestore() {
   return {
      'uid': uid,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'level_skill': levelSkill,
      'login_method': loginMethod,
      'balance': balance,
      'password': password,
      'photo_url': photoUrl,
      'social_uid': socialUid,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

}