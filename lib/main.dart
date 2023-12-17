import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CaptureAndStampImage(),
    );
  }
}

TextEditingController _txtVehicleNumber = TextEditingController();

class CaptureAndStampImage extends StatefulWidget {
  @override
  _CaptureAndStampImageState createState() => _CaptureAndStampImageState();
}

class _CaptureAndStampImageState extends State<CaptureAndStampImage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<File> _resizeImage(File originalImageFile) async {
    final img.Image originalImage1 =
        img.decodeImage(originalImageFile.readAsBytesSync())!;

    int originalWidth = originalImage1.width;
    int originalHeight = originalImage1.height;
    int targetWidth = 0;
    int targetHeight = 0;

    if (originalWidth > originalHeight) {
      if (originalWidth > 800) {
        targetWidth = 800;
        targetHeight = 600;
      } else {
        targetWidth = 600;
        targetHeight = 800;
      }
    } else {
      if (originalHeight > 800) {
        targetWidth = 600;
        targetHeight = 800;
      } else {
        targetWidth = 800;
        targetHeight = 600;
      }
    }

    //  final int targetWidth = 800; // Adjust this to your desired width
    //  final int targetHeight = 600; // Adjust this to your desired height

    final img.Image originalImage =
        img.decodeImage(originalImageFile.readAsBytesSync())!;

    // Resize the image
    final img.Image resizedImage =
        img.copyResize(originalImage, width: targetWidth, height: targetHeight);

    final String resizedImagePath =
        originalImageFile.path.replaceAll('.jpg', '_resized.jpg');
    final File resizedImageFile = File(resizedImagePath);

    // Save the resized image
    await resizedImageFile.writeAsBytes(img.encodeJpg(resizedImage));

    return resizedImageFile;
  }

  Future<void> _saveImageWithTimeStamp() async {
    if (_image == null) return;
    String txtVehicleNumber = _txtVehicleNumber.text;
    //  final Directory? appDirectory =
    await getExternalStorageDirectory(); // Change this to your desired directory
    //  final String appPath = appDirectory!.path;
    String imagePath = '/storage/emulated/0/DCIM/$txtVehicleNumber';
    Directory imageDir = Directory(imagePath);
    final DateTime now = DateTime.now();
    final String formattedDateTime =
        DateFormat('dd MM yyyy HH:mm:ss').format(now);
    final String fileNameTail = DateFormat('yyyyMMdd_HHmmss').format(now);

    if (!(await imageDir.exists())) {
      await imageDir.create(recursive: true);

      final String imagePath = '$imageDir/IMG_$fileNameTail.jpg';

      final File originalImageFile = File(_image!.path);

      // Resize the image
      final File resizedImageFile = await _resizeImage(originalImageFile);

      // Load the resized image using the image package
      final img.Image image =
          img.decodeImage(resizedImageFile.readAsBytesSync())!;

      // Add the date-time stamp
      img.drawString(image, img.arial_24, image.width - 70, image.height - 60,
          formattedDateTime,
          color: img.getColor(255, 255, 255));

      img.drawString(
          image, img.arial_24, 12, image.height - 60, _txtVehicleNumber.text,
          color: img.getColor(255, 255, 255));

      // Save the stamped image
      File(imagePath).writeAsBytesSync(img.encodeJpg(image));

      setState(() {
        _image = XFile(imagePath);
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Surveyor's Camera"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image != null)
                Image.file(
                  File(_image!.path),
                  width: 300,
                  height: 300,
                ),
              ElevatedButton(
                onPressed: _captureImage,
                child: Text('Capture Image'),
              ),
              ElevatedButton(
                onPressed: _saveImageWithTimeStamp,
                child: Text('Save Image with Timestamp'),
              ),
              TextField(
                controller: _txtVehicleNumber,
                decoration: InputDecoration(labelText: "Vehicle Number"),
              )
            ],
          ),
        ),
      );
    }
  }
}
