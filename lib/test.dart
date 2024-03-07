import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery_saver/gallery_saver.dart';
// import 'package:image/image.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      await _controller.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Example'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();
            final imageFile = File(image.path);

            // Save the image to the local storage
            await saveImage(imageFile);

            // Display the captured image
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayImagePage(imageFile: imageFile),
              ),
            );
          } catch (e) {
            print('Error capturing picture: $e');
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }

  Future<void> saveImage(File imageFile) async {
    try {
      // Load the image using the image package
      img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

      // Add a timestamp to the bottom corner of the image
      drawTimestamp(image);

      // Save the modified image
      File modifiedImage = File(
          '${imageFile.parent.path}/modified_${DateTime.now().millisecondsSinceEpoch}.jpg');
      modifiedImage.writeAsBytesSync(img.encodeJpg(image!));

      // Save the modified image to the gallery
      await GallerySaver.saveImage(modifiedImage.path);

      print('Image with timestamp saved to gallery');
    } catch (e) {
      print('Error saving image to gallery: $e');
    }
  }

  void drawTimestamp(img.Image? image) async {
    if (image == null) return;

    // Get the current timestamp
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Create an ui.Image from the image package Image
    ui.Image uiImage = await createUiImage(image);

    // Create a recorder to draw on the ui.Image
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);

    // Draw the original image
    canvas.drawImage(uiImage, Offset(20.0, 20.0), Paint());

    // Define text style
    final textStyle = ui.TextStyle(
      color: ui.Color.fromARGB(255, 255, 255, 255),
      fontSize: 20.0,
    );

    // Draw timestamp text on the canvas
    final textParagraph = ui.ParagraphBuilder(ui.ParagraphStyle())
      ..pushStyle(textStyle)
      ..addText(timestamp);
    final paragraph = textParagraph.build()
      ..layout(ui.ParagraphConstraints(width: 200.0));
    canvas.drawParagraph(
        paragraph, Offset(image.width - 180.0, image.height - 30.0));

    // End recording and save the changes to the image
    ui.Picture picture = recorder.endRecording();
    ui.Image timestampImage = await picture.toImage(image.width, image.height);
    ByteData? byteData =
        await timestampImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8List = byteData!.buffer.asUint8List();
    img.Image timestampImageBytes = img.decodeImage(uint8List)!;

    // Copy the timestamp image to the original image
    // img.copyInto(image, timestampImageBytes, blend: true);

    // Clean up resources
    // recorder.close();
  }

  Future<ui.Image> createUiImage(img.Image image) async {
    ByteData data =
        ByteData.sublistView(Uint8List.fromList(img.encodePng(image)!));
    ui.Codec codec =
        await ui.instantiateImageCodec(Uint8List.view(data.buffer));
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image!;
  }

  // ...
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DisplayImagePage extends StatelessWidget {
  final File imageFile;

  const DisplayImagePage({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Captured Image'),
      ),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
