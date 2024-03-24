import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  String url;

  ImageModel({
    required this.url,
  });
  Map<String, dynamic> toMap() {
    return {
      'image': url,
    };
  }

  factory ImageModel.fromfirestore(DocumentSnapshot user) {
    dynamic map = user.data();
    return ImageModel(url: map['image']);
  }

  String toJson() => json.encode(toMap());
  factory ImageModel.fromJson(String sourse) =>
      ImageModel.fromfirestore(json.decode(sourse));
}
