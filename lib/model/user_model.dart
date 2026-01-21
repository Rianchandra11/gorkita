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

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      userId: map['user_id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      levelSkill: map['level_skill'] ?? 'Beginner',
      loginMethod: map['login_method'] ?? 'email',
      balance: (map['balance'] ?? 0).toDouble(),
      password: map['password'] ?? '',
      photoUrl: map['photo_url'],
      socialUid: List<String>.from(map['social_uid'] ?? []),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toString()),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt']?.toString() ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toMap() {
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
