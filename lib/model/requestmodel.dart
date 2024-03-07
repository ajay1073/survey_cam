import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  String userPhone;
  String userID;
  String deviceID;
  Timestamp requestTime;
  String query;
  bool status;

  RequestModel(
      {required this.userPhone,
      required this.userID,
      required this.deviceID,
      required this.requestTime,
      required this.query,
      required this.status});
  Map<String, dynamic> toMap() {
    return {
      'phone': userPhone,
      'user_id': userID,
      'new_device_id': deviceID,
      'request_time': requestTime,
      'query': query,
      'status': status
    };
  }

  factory RequestModel.fromfirestore(DocumentSnapshot user) {
    dynamic map = user.data();
    return RequestModel(
        userPhone: map['phone'],
        userID: map['user_id'],
        deviceID: map['new_device_id'],
        requestTime: map['request_time'],
        query: map['query'],
        status: map['status']);
  }

  String toJson() => json.encode(toMap());
  factory RequestModel.fromJson(String sourse) =>
      RequestModel.fromfirestore(json.decode(sourse));
}
