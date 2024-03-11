import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userPhone;
  String userName;
  String userID;
  List<String> deviceID;
  bool isAdmin;
  bool isActive;
  Timestamp lastUsed;
  Timestamp signUp;

  UserModel({
    required this.userName,
    required this.userPhone,
    required this.userID,
    required this.deviceID,
    required this.isAdmin,
    required this.isActive,
    required this.lastUsed,
    required this.signUp,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': userName,
      'phone': userPhone,
      'user_id': userID,
      'device_id': deviceID,
      'is_admin': isAdmin,
      'is_active': isActive,
      'last_used': lastUsed,
      'sign_up': signUp
    };
  }

  factory UserModel.fromfirestore(DocumentSnapshot user) {
    dynamic map = user.data();
    print("Dataaaaa");
    print(map.toString());
    List allDeviceId = map['device_id'];
    List<String> temp = allDeviceId.map(
      (e) {
        return e.toString();
      },
    ).toList();
    return UserModel(
        userName: map['name'],
        userPhone: map['phone'],
        userID: map['user_id'],
        deviceID: temp,
        isAdmin: map['is_admin'],
        isActive: map['is_active'],
        lastUsed: map['last_used'],
        signUp: map['sign_up']);
  }

  String toJson() => json.encode(toMap());
  factory UserModel.fromJson(String sourse) =>
      UserModel.fromfirestore(json.decode(sourse));
}
