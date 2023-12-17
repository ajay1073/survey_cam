import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureAndSavePhoto() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _controller.takePicture();

      final String timestamp =
          DateFormat('dd MM yyyy HH:mm:ss').format(DateTime.now());
      final String path = (await getTemporaryDirectory()).path;
      final String fileName = 'IMG_$timestamp.jpg';
      final File savedImage = File('$path/$fileName');

      await File(photo.path).copy(savedImage.path);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Photo saved at: $path/$fileName'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error capturing photo: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_controller)),
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: _captureAndSavePhoto,
          ),
        ],
      ),
    );
  }
}
