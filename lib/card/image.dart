import 'package:flutter/material.dart';
import 'package:survey_cam/model/image.dart';

class ImageCaer extends StatelessWidget {
  final ImageModel model;
  final BuildContext context;
  const ImageCaer({Key? key, required this.model, required this.context});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      model.url,
      width: 200,
      height: 100,
    );
  }
}
