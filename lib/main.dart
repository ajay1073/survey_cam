// ignore_for_file: avoid_unnecessary_containers

import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:survey_cam/useradd.dart';
import 'package:survey_cam/userlist.dart';
import 'firebase_options.dart';
import 'package:path/path.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: CaptureAndStampImage());
    // yeh vala
    // home: CameraApp()
    // home: CameraScreen(),
    // home: UserListPage());
  }
}

TextEditingController _txtVehicleNumber = TextEditingController();

class CaptureAndStampImage extends StatefulWidget {
  @override
  _CaptureAndStampImageState createState() => _CaptureAndStampImageState();
}

class _CaptureAndStampImageState extends State<CaptureAndStampImage> {
  final GlobalKey key = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String currentFolder = "Survey Cam";
  Color currentColor = Colors.orange;
  Color pickerColor = Colors.green;
  bool? isChecked = true;
  bool? isfolder = true;
  List<XFile>? _selectedImages;

  // Future<XFile>? _reimage;

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      // _reimage = _resizeImage(image);
      _image = image;
    });
  }

  Future<File> _resizeImage(
      Uint8List imageData, String originalImagePath) async {
    final img.Image originalImage = img.decodeImage(imageData)!;

    // int originalWidth = originalImage1.width;
    // int originalHeight = originalImage1.height;
    int targetWidth = 0;
    int targetHeight = 0;

    if (originalImage.width > originalImage.height) {
      if (originalImage.width > 800) {
        targetWidth = 800;
        targetHeight = 600;
      } else {
        targetWidth = 600;
        targetHeight = 800;
      }
    } else {
      if (originalImage.height > 800) {
        targetWidth = 600;
        targetHeight = 800;
      } else {
        targetWidth = 800;
        targetHeight = 600;
      }
    }

    //  final int targetWidth = 800; // Adjust this to your desired width
    //  final int targetHeight = 600; // Adjust this to your desired height

    // final img.Image originalImage =
    //     img.decodeImage(originalImageFile.readAsBytesSync())!;

    // Resize the image
    print("ok");
    final img.Image resizedImage =
        img.copyResize(originalImage, width: targetWidth, height: targetHeight);
    print("ok2");
    // Generate the path for the resized image
    // Generate the path for the resized image
    final String resizedImagePath = path.withoutExtension(
            originalImagePath) // Remove the original extension
        // .replaceAll(RegExp(r'[^a-zA-Z0-9]'),
        //     '_') // Replace non-alphanumeric characters
        // .replaceAll(
        //     '_', '__') // Replace underscores with double underscores
        +
        '_resized.jpg'; // Concatenate with '_resized.jpg' as the new extension
    print("ok3");
    final File resizedImageFile = File(resizedImagePath);
    print("ok4");
    // Convert the resized image to bytes without saving it
    List<int> resizedImageBytes = img.encodeJpg(resizedImage);
    print("ok5");
    // Save the resized image to a temporary file (if needed)
    await resizedImageFile.writeAsBytes(resizedImageBytes);
    print("ok6");
    return resizedImageFile;
  }

  Future<void> _saveImage() async {
    // Check if permission is granted
    if (await Permission.storage.request().isGranted) {
      // Your image-saving logic here
      print("permission granted");
    } else {
      // Handle the case where permission is denied
      print('Permission denied');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _saveImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        icon: Icons.share,
        backgroundColor: Colors.black,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        children: [
          SpeedDialChild(
            child: Icon(Icons.image_search),
            label: "Pick Images",
            onTap: () {
              _pickImages();
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.share),
            label: "Share Images",
            onTap: () {
              if (_selectedImages != null) {
                _shareImages();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No Images Selected')));
              }
            },
          )
        ],
      ),
      backgroundColor: Colors.blueGrey,
      body: Stack(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 45,
              ),
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white)),
                child: RepaintBoundary(
                  key: key,
                  child: Container(
                    // height: 150,
                    // width: 200,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        if (_image != null)
                          Image.file(
                            File(_image!.path),
                            fit: BoxFit.cover,
                            // width: 300,
                            // height: 300,
                          ),
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Text(
                            // _txtVehicleNumber.text +
                            //     '               ' +
                            formatTimestampToDateString(
                                DateTime.now().millisecondsSinceEpoch),
                            style: TextStyle(
                                fontSize: 12,
                                color: currentColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        isfolder == true
                            ? Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 20,
                                    left: 20,
                                  ),
                                  // child: Outline(

                                  child: Text(
                                    _txtVehicleNumber.text,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: currentColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )
                            : Container(),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),

              // TextField(
              //   controller: _txtVehicleNumber,
              //   decoration: const InputDecoration(labelText: "Vehicle Number"),
              // )
            ],
          ),
        ),
        Positioned(
          bottom: 218,
          child: colorPalette(context),
        ),
        Positioned(bottom: 0, child: bottomToolBar())
      ]),
    );
  }

  colorPalette(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.white),
          )),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Row(
          children: [
            const Row(
              children: [
                Text(
                  "Colors :",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Pick a Color!"),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: pickerColor,
                          onColorChanged: (value) {
                            setState(() {
                              pickerColor = value;
                            });
                          },
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                currentColor = pickerColor;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text("Done")),
                      ],
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white)),
                child: Padding(
                    padding: const EdgeInsets.all(2.7),
                    child: currentColor == Colors.white
                        ? const Icon(
                            Icons.colorize,
                            color: Colors.black,
                          )
                        : const Icon(
                            Icons.colorize,
                            color: Colors.white,
                          )),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  currentColor = Colors.white;
                });
              },
              child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.white
                      ? const Icon(Icons.check, color: Colors.black)
                      : Container()),
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  currentColor = Colors.black;
                });
              },
              child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.black
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  currentColor = Colors.red;
                });
              },
              child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.red
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  currentColor = Colors.orange;
                });
              },
              child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.orange
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  currentColor = Colors.yellow;
                });
              },
              child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.yellow
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  currentColor = Colors.green;
                });
              },
              child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.green
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  currentColor = Colors.blue;
                });
              },
              child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.blue
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomToolBar() {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.white),
          )),
      width: MediaQuery.of(context).size.width,
      height: 217,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 15, bottom: 10),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _txtVehicleNumber,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      suffixIcon: Checkbox(
                        side: const BorderSide(color: Colors.white),
                        value: isfolder,
                        onChanged: (value) {
                          setState(() {
                            isfolder = value!;
                          });
                        },
                      ),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      labelText: "Folder Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                width: 145,
                child: CheckboxListTile(
                  title: const Text(
                    "Resize :",
                    style: TextStyle(color: Colors.white),
                  ),
                  side: const BorderSide(color: Colors.white),
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ElevatedButton(
                  onPressed: () {
                    _captureImage().then((value) async {
                      if (_image == null) {
                        print("Image is null");
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No Image was taken')));
                      } else {
                        await Future.delayed(
                            const Duration(milliseconds: 1500));
                        if (isChecked == true) {
                          print("With Resize");
                          captureAndSave();
                        } else {
                          print("without resize");
                          captureAndSaveWithoutResize();
                        }
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, elevation: 5),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      'Capture and Save',
                      style: GoogleFonts.montserrat(fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),

          // Padding(
          //   padding: const EdgeInsets.only(left: 10, right: 10),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       Container(
          //         height: 60,
          //         width: 200,
          //         decoration:
          //             BoxDecoration(border: Border.all(color: Colors.white)),
          //         child: Row(
          //           children: [
          //             const Padding(
          //               padding: EdgeInsets.only(left: 5, right: 8),
          //               child: Text(
          //                 "Font:",
          //                 style: TextStyle(color: Colors.white, fontSize: 18),
          //               ),
          //             ),
          //             Padding(
          //               padding: const EdgeInsets.only(right: 5),
          //               child: DropdownButton<String>(
          //                 value: selectedFont,
          //                 items: fontFamilyList.map((e) {
          //                   return DropdownMenuItem<String>(
          //                       value: e,
          //                       child: Text(e,
          //                           style: GoogleFonts.getFont(e,
          //                               color: selectedFont == e
          //                                   ? Colors.white
          //                                   : Colors.black)));
          //                 }).toList(),
          //                 onChanged: (String? value) {
          //                   setState(() {
          //                     selectedFont = value!;
          //                   });
          //                 },
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: ElevatedButton(
                  onPressed: () {
                    if (isChecked == true) {
                      captureAndSave();
                    } else {
                      captureAndSaveWithoutResize();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, elevation: 5),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      'Save Image',
                      style: GoogleFonts.montserrat(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  Future<void> _shareImages() async {
    if (_selectedImages == null || _selectedImages!.isEmpty) {
      // Show an error or a message indicating that no images are selected
      return;
    }

    final List<String> imagePaths =
        _selectedImages!.map((image) => image.path!).toList();
    final String text = 'Check out these images!';

    // Share images and text using share_plus
    await Share.shareFiles(
      imagePaths,
      text: text,
      mimeTypes: [
        'image/*'
      ], // Specify mimeTypes to ensure compatibility across platforms
    );
  }

  Future<void> captureAndSave() async {
    print("yahn tk aa rha");
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List uint8List = byteData!.buffer.asUint8List();

      // Get the documents directory
      // Directory documentsDirectory = await getApplicationDocumentsDirectory();

      // Create a specific directory (e.g., "MyImages") within the documents directory
      // String directoryPath = '${documentsDirectory.path}/MyImages';
      String folderName = _txtVehicleNumber.text;
      String directoryPath = '/storage/emulated/0/Pictures';

      if (folderName.isNotEmpty) {
        directoryPath += '/$folderName';
      }
      Directory directory = Directory(directoryPath);
      if (!await directory.exists()) {
        print('Creating directory: $directoryPath');
        await directory.create(recursive: true);
      } else {
        print("exisy");
      }

      // Save the image to the specific directory as PNG
      String originalFilePath = '$directoryPath/image.png';
      // await File(originalFilePath).writeAsBytes(uint8List);

      print('Image saved to: $originalFilePath');

      // Resize the image
      // yahan se
      print("resize ke pahle");
      File resizedImageFile = await _resizeImage(uint8List, originalFilePath);
      print("resize");

      // Save the resized image to the specific directory as JPG
      // String resizedFilePath = '$directoryPath/image.jpg';
      // await File(resizedFilePath)
      //     .writeAsBytes(await resizedImageFile.readAsBytes());

      // print('Image saved to: $resizedFilePath');

      // Save the image to the gallery
      // await GallerySaver.saveImage(resizedImageFile,
      //     albumName: _txtVehicleNumber.text);

      // String fileName = 'IMG-YYYYMMDD-HHMMSS'+Timestamp.now().toDate().minute.toString() + '.jpg';
      String fileName = 'IMG-' +
          Timestamp.now().toDate().year.toString() +
          Timestamp.now().toDate().month.toString().padLeft(2, "0") +
          Timestamp.now().toDate().day.toString().padLeft(2, "0") +
          '-' +
          Timestamp.now().toDate().hour.toString().padLeft(2, "0") +
          Timestamp.now().toDate().minute.toString().padLeft(2, "0") +
          Timestamp.now().toDate().second.toString().padLeft(2, "0") +
          '.jpg';
      String galleryPath = '/storage/emulated/0/Pictures/';

      String galleryFilePath = '$galleryPath$fileName';
      await resizedImageFile.copy(galleryFilePath);

      // Save the image to the gallery

      await GallerySaver.saveImage(galleryFilePath,
          albumName: _txtVehicleNumber.text);

      // Cleanup: Delete the original file
      print(galleryFilePath);
      print(originalFilePath + "ss");
      if (_txtVehicleNumber.text.isEmpty) {
        await _deleteFile(
            galleryFilePath.substring(0, galleryFilePath.length - 4) +
                " (1).jpg");
      } else {
        await _deleteFile(galleryFilePath);
      }
      await _deleteFile(originalFilePath);
      await _deleteFile(resizedImageFile.path);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image saved to gallery')));
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  Future<void> captureAndSaveWithoutResize() async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List uint8List = byteData!.buffer.asUint8List();

      String folderName = _txtVehicleNumber.text;
      String directoryPath = '/storage/emulated/0/Pictures';

      if (folderName.isNotEmpty) {
        directoryPath += '/$folderName';
      }
      Directory directory = Directory(directoryPath);
      if (!await directory.exists()) {
        print('Creating directory: $directoryPath');
        await directory.create(recursive: true);
      } else {
        print("exisy");
      }

      // Save the image to the specific directory as PNG
      String originalFilePath = '$directoryPath/image.png';
      await File(originalFilePath).writeAsBytes(uint8List);

      print('Image saved to: $originalFilePath');

      // Save the image to the gallery
      String fileName = 'IMG-' +
          Timestamp.now().toDate().year.toString() +
          Timestamp.now().toDate().month.toString().padLeft(2, "0") +
          Timestamp.now().toDate().day.toString().padLeft(2, "0") +
          '-' +
          Timestamp.now().toDate().hour.toString().padLeft(2, "0") +
          Timestamp.now().toDate().minute.toString().padLeft(2, "0") +
          Timestamp.now().toDate().second.toString().padLeft(2, "0") +
          '.jpg';
      String galleryPath = '/storage/emulated/0/Pictures/';

      String galleryFilePath = '$galleryPath$fileName';
      await File(originalFilePath).copy(galleryFilePath);

      // Save the image to the gallery
      await GallerySaver.saveImage(galleryFilePath,
          albumName: _txtVehicleNumber.text);

      // Cleanup: Delete the original file
      print(galleryFilePath);
      print(originalFilePath + "ss");
      // if (_txtVehicleNumber.text.isEmpty) {
      //   await _deleteFile(
      //       galleryFilePath.substring(0, galleryFilePath.length - 4) +
      //           " (1).jpg");
      // } else {
      await _deleteFile(galleryFilePath);
      // }
      await _deleteFile(originalFilePath);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image saved to gallery')));
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  Future<void> _deleteFile(String filePath) async {
    print("incoming" + filePath);
    try {
      File file = File(filePath);
      if (await file.exists()) {
        print('Deleting file: $filePath');
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  String formatTimestampToDateString(int timestamp) {
    // Convert timestamp to DateTime
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Format the DateTime to the desired format
    String formattedDate = "${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.month.toString().padLeft(2, '0')} "
        "${dateTime.year.toString()}  "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";

    return formattedDate;
  }
}
