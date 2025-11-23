import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  int id;
  String nama;
  String noHp;
  int islogin;
  String email;
  String password;

  User({
    required this.id,
    required this.nama,
    required this.noHp,
    this.islogin = 0,
    required this.email,
    required this.password
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    nama: json["nama"],
    noHp: json["no_hp"],
    islogin: json["isLogin"],
    email:  json["email"],
    password: json["password"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "no_hp": noHp,
    "islogin": islogin,
    "email" :email,
    "password":password
  };
}
