import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userPhone;
  String userName;
  String userID;
  bool isAdmin;
  bool isActive;

  UserModel({
    required this.userName,
    required this.userPhone,
    required this.isAdmin,
    required this.userID,
    required this.isActive,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': userName,
      'phone': userPhone,
      'is_admin': isAdmin,
      'user_id': userID,
      'is_active': isActive,
    };
  }

  factory UserModel.fromfirestore(DocumentSnapshot user) {
    dynamic map = user.data();
    return UserModel(
        userName: map['name'],
        userPhone: map['phone'],
        isAdmin: map['is_admin'],
        userID: map['user_id'],
        isActive: map['is_active']);
  }

  String toJson() => json.encode(toMap());
  factory UserModel.fromJson(String sourse) =>
      UserModel.fromfirestore(json.decode(sourse));
}
