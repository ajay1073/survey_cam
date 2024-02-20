// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously

import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:mycam/codegenerator.dart';
import 'package:mycam/login.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:share_plus/share_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;
import 'firebase_options.dart';
import 'package:path/path.dart' as path;

void main() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
    // home: LoginScreen());
    // home: CodeGeneratorScreen());
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
  String selectedResolution = "800*600";
  loc.Location location = loc.Location();
  loc.LocationData? currentLocation;
  final GlobalKey key = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  late Color currentColor = Colors.orange;
  late Color pickerColor = Colors.purple;
  bool? isChecked = true;
  bool? isfolder = true;
  List<XFile>? _selectedImages;
  List<String> resizeList = <String>[
    "1600*1200",
    "1280*960",
    "1024*768",
    "800*600",
    "640*480"
  ];
  bool? isSeparate = false; // for saving image separately
  bool? isLocation = false; // for having location stamp
  bool? isDate = true; // for not having date time stamp
  bool? isName = false; // for saving folder value

  // Future<XFile>? _reimage;

  Future<void> _captureImage() async {
    _saveImage();
    // getLocation();
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
    int height;
    int width;
    if (selectedResolution == "1600*1200") {
      height = 1200;
      width = 1600;
    } else if (selectedResolution == "1280*960") {
      height = 1280;
      width = 960;
    } else if (selectedResolution == "1024*768") {
      height = 1024;
      width = 768;
    } else if (selectedResolution == "640*480") {
      height = 640;
      width = 480;
    } else {
      height = 800;
      width = 600;
    }
    if (selectedResolution == "1600*1200") {
      if (originalImage.width > originalImage.height) {
        if (originalImage.width > height) {
          targetWidth = height;
          targetHeight = width;
        } else {
          targetWidth = width;
          targetHeight = height;
        }
      } else {
        if (originalImage.height > height) {
          targetWidth = width;
          targetHeight = height;
        }
        // else {
        //   if (originalImage.height < height) {
        //   } else {
        //     targetWidth = height;
        //     targetHeight = width;
        //   }
        // }
      }
    } else {
      if (originalImage.width > originalImage.height) {
        if (originalImage.width > height) {
          targetWidth = height;
          targetHeight = width;
        } else {
          targetWidth = width;
          targetHeight = height;
        }
      } else {
        if (originalImage.height > height) {
          targetWidth = width;
          targetHeight = height;
        } else {
          targetWidth = height;
          targetHeight = width;
        }
      }
    }

    // Get the format of the original image (jpg, png, etc.)
    // String originalImageFormat = path.extension(originalImagePath).toLowerCase();

    // Compress and resize the image
    List<int> resizedImageBytes = await FlutterImageCompress.compressWithList(
      imageData,
      minHeight: targetHeight,
      minWidth: targetWidth,
      format: CompressFormat.jpeg,
    );

    //  final int targetWidth = 800; // Adjust this to your desired width
    //  final int targetHeight = 600; // Adjust this to your desired height

    // final img.Image originalImage =
    //     img.decodeImage(originalImageFile.readAsBytesSync())!;

    // Resize the image
    // // print("ok");
    // final img.Image resizedImage =
    //     img.copyResize(originalImage, width: targetWidth, height: targetHeight);
    // print("ok2");
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
    // print("ok3");
    final File resizedImageFile = File(resizedImagePath);
    // print("ok4");
    // Convert the resized image to bytes without saving it
    // List<int> resizedImageBytes = img.encodeJpg(resizedImage);
    // print("ok5");
    // Save the resized image to a temporary file (if needed)
    await resizedImageFile.writeAsBytes(resizedImageBytes);
    // print("ok6");
    return resizedImageFile;
  }

  Future<void> _saveImage() async {
    // Check if permission is granted
    var status = await permission_handler.Permission.storage.status;
    if (status.isGranted) {
      // Your image-saving logic here
      print("Permission granted");
    } else {
      // If permission is not granted, request it
      var result = await permission_handler.Permission.storage.request();

      if (result.isGranted) {
        // Your image-saving logic here after permission is granted
        print("Permission granted");
      } else {
        // Handle the case where permission is denied or not permanently denied
        if (result.isDenied) {
          print('Permission denied');
        } else if (result.isPermanentlyDenied) {
          // Handle the case where permission is permanently denied
          print('Permission permanently denied');
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
    // _saveImage();
    getValue();
  }

  Future<void> getLocation() async {
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      // Handle exceptions
      print('Error: $e');
    }

    if (currentLocation != null) {
      print('Latitude: ${currentLocation?.latitude}');
      print('Longitude: ${currentLocation?.longitude}');
    } else {
      print('Unable to get location');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: screenSize.width * 0.006,
          ),
          borderRadius: BorderRadius.circular(screenSize.height *
              0.05), // Adjust the value based on your preference
        ),
        child: SpeedDial(
          // childMargin: EdgeInsets.all(10),
          icon: Icons.menu_book,
          backgroundColor: Colors.black,
          overlayColor: Colors.black,
          overlayOpacity: 0.4,
          childrenButtonSize:
              Size(screenSize.width * 0.15, screenSize.height * 0.1),
          children: [
            SpeedDialChild(
              child: const Icon(Icons.image_search),
              label: "Pick Images",
              labelStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: screenSize.height * 0.022,
                  fontWeight: FontWeight.w500),
              onTap: () {
                _pickImages();
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.share),
              label: "Share Images",
              labelStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: screenSize.height * 0.022,
                  fontWeight: FontWeight.w500),
              onTap: () {
                if (_selectedImages != null) {
                  _shareImages();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No Images Selected')));
                }
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.settings),
              label: "Settings",
              labelStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: screenSize.height * 0.022,
                  fontWeight: FontWeight.w500),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CheckboxDialog(
                        onCheckbox1Changed: (value) async {
                          setState(() {
                            isSeparate = value;
                          });
                          var prefs = await SharedPreferences.getInstance();
                          prefs.setBool('separate', isSeparate!);
                        },
                        onCheckbox2Changed: (value) async {
                          setState(() {
                            isLocation = value;
                          });
                          var prefs = await SharedPreferences.getInstance();
                          prefs.setBool('location', isLocation!);
                        },
                        onCheckbox3Changed: (value) async {
                          setState(() {
                            isDate = value;
                          });
                          var prefs = await SharedPreferences.getInstance();
                          prefs.setBool('date', isDate!);
                        },
                        onCheckbox4Changed: (value) async {
                          setState(() {
                            isName = value;
                          });
                          var prefs = await SharedPreferences.getInstance();
                          prefs.setBool('name', isName!);
                        },
                      );
                    });
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.info_outline),
              label: "Help",
              labelStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: screenSize.height * 0.022,
                  fontWeight: FontWeight.w500),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        // contentPadding: EdgeInsets.symmetric(vertical: 100.0),
                        title: Text(
                          "Help",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenSize.height * 0.03,
                              fontWeight: FontWeight.w500),
                        ),
                        content: Container(
                          height: 400,
                          // width: 500,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  "1. This application is use to save photo with DateTime Stamp, GPS Location Stamp and Folder name Stamp.",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.019,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                    height: screenSize.height * 0.0125,
                                    child: const Divider(
                                      color: Colors.grey,
                                      thickness: 0.5,
                                    )),
                                Text(
                                  "2. Prefered folder name and image will be saved in named folder. To remove the Folder Name stamp from image, uncheck the box at the right side of the Folder Name field.",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.019,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                    height: screenSize.height * 0.0125,
                                    child: const Divider(
                                      color: Colors.grey,
                                      thickness: 0.5,
                                    )),
                                Text(
                                  "3. Image can be resize in the size available in the Drop Down menu. To save original image uncheck the box at the right side of the resize field.",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.019,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                    height: screenSize.height * 0.0125,
                                    child: const Divider(
                                      color: Colors.grey,
                                      thickness: 0.5,
                                    )),
                                Text(
                                  "4. To share the images follow below steps:-",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.019,
                                      fontWeight: FontWeight.w500),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenSize.width * 0.0277,
                                      top: screenSize.height * 0.00625),
                                  child: Text(
                                    "4.1. Firstly pick the images you want to share with the help of Pick Image option.",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.019,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenSize.width * 0.0277,
                                      top: screenSize.height * 0.00625),
                                  child: Text(
                                    "4.2. After picking the desired image click on Share Images to see and share on all available options.",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.019,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(
                                    height: screenSize.height * 0.0125,
                                    child: const Divider(
                                      color: Colors.grey,
                                      thickness: 0.5,
                                    )),
                                Text(
                                  "5. Default settings can be change in following steps.",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.019,
                                      fontWeight: FontWeight.w500),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenSize.width * 0.0277,
                                      top: screenSize.height * 0.00625),
                                  child: Text(
                                    "5.1. If blank images issue occur, change the settings to save image individually. Use the button Save Image to save the image.",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.019,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenSize.width * 0.0277,
                                      top: screenSize.height * 0.00625),
                                  child: Text(
                                    "5.2. To save the GPS Location stamping check or uncheck the GPS Stamp checkbox",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.019,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenSize.width * 0.0277,
                                      top: screenSize.height * 0.00625),
                                  child: Text(
                                    "5.3. To save the Date-Time stamping check or uncheck the Date-Time Stamp checkbox",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.019,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenSize.width * 0.0277,
                                      top: screenSize.height * 0.00625),
                                  child: Text(
                                    "5.3. To save last used folder check or uncheck the Last Save Folder checkbox",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.019,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(
                                    height: screenSize.height * 0.0125,
                                    child: const Divider(
                                      color: Colors.grey,
                                      thickness: 0.5,
                                    )),
                                Text(
                                  "6. All saved images can be accessed from following directory:-",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.019,
                                      fontWeight: FontWeight.w500),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenSize.width * 0.0277,
                                      top: screenSize.height * 0.00625),
                                  child: Text(
                                    "6.1. With Folder Name: \n /storage/emulated/0/Pictures/FOLDERNAME",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.019,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenSize.width * 0.0277,
                                      top: screenSize.height * 0.00625),
                                  child: Text(
                                    "6.2. Without Folde Name: \n /storage/emulated/0/Pictures",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.019,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(
                                    height: screenSize.height * 0.0125,
                                    child: const Divider(
                                      color: Colors.grey,
                                      thickness: 0.5,
                                    )),
                                Text(
                                  "7. Reviews and Feedbacks are welcome at \nmycamfeedback@gmail.com",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.019,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                    height: screenSize.height * 0.0375,
                                    child: const Divider(
                                      color: Colors.grey,
                                      thickness: 0.5,
                                    )),
                                const Text(
                                  "Thank you for using MyCam.",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                    height: screenSize.height * 0.0125,
                                    child: const Divider(
                                      color: Colors.grey,
                                      thickness: 0.5,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          Ink(
                            decoration: const ShapeDecoration(
                                shape: CircleBorder(
                                    side:
                                        BorderSide(color: Color(0xFF4C4F5E)))),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.close)),
                          ),
                        ],
                      );
                    });
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.lock_person),
              label: "Code Generator",
              labelStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: screenSize.height * 0.022,
                  fontWeight: FontWeight.w500),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CodeGeneratorScreen()),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blueGrey,
      body: Stack(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: screenSize.height * 0.05625,
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
                            fit: BoxFit.contain,
                            // width: 300,
                            // height: 300,
                          ),
                        isDate == true
                            ? Positioned(
                                bottom: screenSize.height * 0.025,
                                right: screenSize.width * 0.055,
                                child: Text(
                                  formatTimestampToDateString(
                                      DateTime.now().millisecondsSinceEpoch),
                                  style: TextStyle(
                                      fontSize: screenSize.height * 0.015,
                                      color: currentColor,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            : Container(),
                        isLocation == true && currentLocation != null
                            ? Positioned(
                                bottom: screenSize.height * 0.00375,
                                right: screenSize.width * 0.055,
                                child: Text(
                                  formatgps(),
                                  style: TextStyle(
                                      fontSize: screenSize.height * 0.015,
                                      color: currentColor,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            : Container(),
                        isfolder == true
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: screenSize.height * 0.025,
                                      left: screenSize.width * 0.055),
                                  child: Text(
                                    _txtVehicleNumber.text,
                                    style: TextStyle(
                                        fontSize: screenSize.height * 0.015,
                                        color: currentColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: screenSize.height * 0.27125,
          child: colorPalette(context),
        ),
        Positioned(bottom: screenSize.height * 0, child: bottomToolBar())
      ]),
    );
  }

  saveColor() async {
    String colorHex = currentColor.value.toRadixString(16).padLeft(8, '0');
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("color", colorHex);
  }

  savePickedColor() async {
    String piccolorHex = pickerColor.value.toRadixString(16).padLeft(8, '0');
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("pickcolor", piccolorHex);
  }

  save() {
    _captureImage().then((value) async {
      if (_image == null) {
        print("Image is null");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          'No Image was taken',
          style: TextStyle(fontFamily: 'Montserrat'),
        )));
      } else {
        await Future.delayed(const Duration(milliseconds: 2500));
        if (isChecked == true) {
          // print("With Resize");
          captureAndSave();
          save();
          // _captureImage();
        } else {
          // print("without resize");
          captureAndSaveWithoutResize();
          save();
          // _captureImage();
        }
      }
    });
  }

  colorPalette(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      height: screenSize.height * 0.0625,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.white),
          )),
      child: Padding(
        padding: EdgeInsets.only(
            left: screenSize.width * 0.022, right: screenSize.width * 0.022),
        child: Row(
          children: [
            Row(
              children: [
                Text(
                  "Colors :",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: screenSize.height * 0.023,
                      color: Colors.white),
                ),
                SizedBox(
                  width: screenSize.height * 0.01,
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        "Pick a Color!",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                        ),
                      ),
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
                            onPressed: () async {
                              setState(() {
                                currentColor = pickerColor;
                              });
                              await saveColor();
                              await savePickedColor();
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Done",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                              ),
                            )),
                      ],
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Color(pickerColor.value),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white)),
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: screenSize.height * 0.003375,
                        horizontal: screenSize.width * 0.0075),
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
            SizedBox(
              width: screenSize.width * 0.016,
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  currentColor = pickerColor;
                });
                await saveColor();
              },
              child: Container(
                  height: screenSize.height * 0.035,
                  width: screenSize.width * 0.077,
                  decoration: BoxDecoration(
                      color: Color(pickerColor.value),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: pickerColor == currentColor
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
            SizedBox(
              width: screenSize.width * 0.016,
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  currentColor = Colors.white;
                });
                await saveColor();
              },
              child: Container(
                  height: screenSize.height * 0.035,
                  width: screenSize.width * 0.077,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.white
                      ? const Icon(Icons.check, color: Colors.black)
                      : Container()),
            ),
            SizedBox(
              width: screenSize.width * 0.016,
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  currentColor = Colors.black;
                });
                await saveColor();
              },
              child: Container(
                  height: screenSize.height * 0.035,
                  width: screenSize.width * 0.077,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.black
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
            SizedBox(
              width: screenSize.width * 0.016,
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  currentColor = Colors.red;
                });
                await saveColor();
              },
              child: Container(
                  height: screenSize.height * 0.035,
                  width: screenSize.width * 0.077,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.red ||
                          currentColor == const Color(0xfff44336)
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
            SizedBox(
              width: screenSize.width * 0.016,
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  currentColor = Colors.orange;
                });
                await saveColor();
              },
              child: Container(
                  height: screenSize.height * 0.035,
                  width: screenSize.width * 0.077,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.orange ||
                          currentColor == const Color(0xffff9800)
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
            SizedBox(
              width: screenSize.width * 0.016,
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  currentColor = Colors.green;
                });
                await saveColor();
              },
              child: Container(
                  height: screenSize.height * 0.035,
                  width: screenSize.width * 0.077,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.green ||
                          currentColor == const Color(0xff4caf50)
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
            SizedBox(
              width: screenSize.width * 0.016,
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  currentColor = Colors.blue;
                });
                await saveColor();
              },
              child: Container(
                  height: screenSize.height * 0.035,
                  width: screenSize.width * 0.077,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: currentColor == Colors.blue ||
                          currentColor == const Color(0xff2196f3)
                      ? const Icon(Icons.check, color: Colors.white)
                      : Container()),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomToolBar() {
    Size screenSize = MediaQuery.of(context).size;
    print(screenSize.height);
    print(screenSize.width);
    return Container(
      decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.white),
          )),
      width: MediaQuery.of(context).size.width,
      height: screenSize.height * 0.27125,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: screenSize.width * 0.611,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: screenSize.width * 0.0416,
                      right: screenSize.width * 0.0277,
                      top: screenSize.height * 0.0195),
                  child: TextField(
                    maxLines: 1,
                    minLines: 1,
                    style: const TextStyle(
                        fontFamily: 'Montserrat', color: Colors.white),
                    controller: _txtVehicleNumber,
                    onChanged: (value) async {
                      value = _txtVehicleNumber.text;
                      if (isName == true) {
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString("text", value);
                      }
                    },
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      suffixIcon: Checkbox(
                        side: const BorderSide(color: Colors.white),
                        value: isfolder,
                        onChanged: (value) async {
                          setState(() {
                            isfolder = value!;
                          });

                          var prefs = await SharedPreferences.getInstance();
                          prefs.setBool("folder", isfolder!);
                        },
                      ),
                      labelStyle: const TextStyle(
                        fontFamily: 'Montserrat',
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
              Padding(
                padding: EdgeInsets.only(
                    top: screenSize.height * 0.023,
                    left: screenSize.width * 0.04166),
                child: SizedBox(
                    width: screenSize.width * 0.5416,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        suffixIcon: Checkbox(
                          side: const BorderSide(color: Colors.white),
                          value: isChecked,
                          onChanged: (value) async {
                            setState(() {
                              isChecked = value!;
                            });
                            var prefs = await SharedPreferences.getInstance();
                            prefs.setBool("resize", isChecked!);
                          },
                        ),
                        labelStyle: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                        ),
                        labelText: "Resize",
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
                      dropdownColor: Colors.black,
                      onChanged: (value) async {
                        setState(() {
                          selectedResolution = value!;
                        });
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString("resolution", selectedResolution);
                      },
                      value: selectedResolution,
                      items: resizeList.map((e) {
                        return DropdownMenuItem<String>(
                            value: e,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.width * 0.0138),
                              child: Text(
                                e,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat'),
                              ),
                            ));
                      }).toList(),
                    )),
              ),
            ],
          ),
          isSeparate == false
              ? Padding(
                  padding: EdgeInsets.only(
                      left: screenSize.width * 0.00833,
                      top: screenSize.height * 0.04375),
                  child: SizedBox(
                    height: screenSize.height * 0.1125,
                    child: ElevatedButton(
                        onPressed: () {
                          // getLocation();
                          save();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, elevation: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: screenSize.height * 0.0125,
                                ),
                                const Icon(Icons.camera),
                                SizedBox(
                                  height: screenSize.height * 0.01875,
                                ),
                                const Icon(Icons.save_alt),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: screenSize.width * 0.02,
                                  top: screenSize.height * 0.0125,
                                  bottom: screenSize.height * 0.00625),
                              child: Text('Capture\nand\nSave',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: screenSize.height * 0.0225,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        )),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: screenSize.width * 0.00833,
                          top: screenSize.height * 0.0125),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _captureImage().then((value) {
                            if (_image == null) {
                              print("Image is null");
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('No Image was taken')));
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, elevation: 5),
                        icon: const Icon(Icons.camera),
                        label: Padding(
                          padding: EdgeInsets.only(
                              top: screenSize.height * 0.00625,
                              bottom: screenSize.height * 0.00625),
                          child: Text('Capture\nImage',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: screenSize.height * 0.02125,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenSize.width * 0.00833,
                        top: screenSize.height * 0.01625,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (isChecked == true) {
                            // print("With Resize");
                            captureAndSave();
                            // _captureImage();
                          } else {
                            // print("without resize");
                            captureAndSaveWithoutResize();
                            // _captureImage();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, elevation: 5),
                        icon: const Icon(Icons.save_alt),
                        label: Padding(
                          padding: EdgeInsets.only(
                              top: screenSize.height * 0.00625,
                              bottom: screenSize.height * 0.00625,
                              right: screenSize.width * 0.023),
                          child: Text('Save\nImage',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: screenSize.height * 0.02125,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    )
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
    const String text = 'Check out these images!';

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
        // print("exisy");
      }

      // Save the image to the specific directory as PNG
      String originalFilePath = '$directoryPath/image.png';
      // await File(originalFilePath).writeAsBytes(uint8List);

      print('Image saved to: $originalFilePath');

      // Resize the image
      // yahan se
      // print("resize ke pahle");
      File resizedImageFile = await _resizeImage(uint8List, originalFilePath);
      // print("resize");

      // Save the resized image to the specific directory as JPG
      // String resizedFilePath = '$directoryPath/image.jpg';
      // await File(resizedFilePath)
      //     .writeAsBytes(await resizedImageFile.readAsBytes());

      // print('Image saved to: $resizedFilePath');

      // Save the image to the gallery
      // await GallerySaver.saveImage(resizedImageFile,
      //     albumName: _txtVehicleNumber.text);

      // String fileName = 'IMG-YYYYMMDD-HHMMSS'+Timestamp.now().toDate().minute.toString() + '.jpg';
      String fileName =
          'IMG-${Timestamp.now().toDate().year}${Timestamp.now().toDate().month.toString().padLeft(2, "0")}${Timestamp.now().toDate().day.toString().padLeft(2, "0")}-${Timestamp.now().toDate().hour.toString().padLeft(2, "0")}${Timestamp.now().toDate().minute.toString().padLeft(2, "0")}${Timestamp.now().toDate().second.toString().padLeft(2, "0")}.jpg';
      String galleryPath = '/storage/emulated/0/Pictures/';

      String galleryFilePath = '$galleryPath$fileName';
      await resizedImageFile.copy(galleryFilePath);

      // Save the image to the gallery

      await GallerySaver.saveImage(galleryFilePath,
          albumName: _txtVehicleNumber.text);

      // Cleanup: Delete the original file
      // print(galleryFilePath);
      // print(originalFilePath + "ss");
      if (_txtVehicleNumber.text.isEmpty) {
        await _deleteFile(
            "${galleryFilePath.substring(0, galleryFilePath.length - 4)} (1).jpg");
      } else {
        await _deleteFile(galleryFilePath);
      }
      await _deleteFile(originalFilePath);
      await _deleteFile(resizedImageFile.path);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image saved to gallery')));
      // save();
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
        // print("exisy");
      }

      // Save the image to the specific directory as PNG
      String originalFilePath = '$directoryPath/image.png';
      await File(originalFilePath).writeAsBytes(uint8List);

      print('Image saved to: $originalFilePath');

      // Save the image to the gallery
      String fileName =
          'IMG-${Timestamp.now().toDate().year}${Timestamp.now().toDate().month.toString().padLeft(2, "0")}${Timestamp.now().toDate().day.toString().padLeft(2, "0")}-${Timestamp.now().toDate().hour.toString().padLeft(2, "0")}${Timestamp.now().toDate().minute.toString().padLeft(2, "0")}${Timestamp.now().toDate().second.toString().padLeft(2, "0")}.jpg';
      String galleryPath = '/storage/emulated/0/Pictures/';

      String galleryFilePath = '$galleryPath$fileName';
      await File(originalFilePath).copy(galleryFilePath);

      // Save the image to the gallery
      await GallerySaver.saveImage(galleryFilePath,
          albumName: _txtVehicleNumber.text);

      // Cleanup: Delete the original file
      // print(galleryFilePath);
      // print(originalFilePath + "ss");
      if (_txtVehicleNumber.text.isEmpty) {
        await _deleteFile(
            "${galleryFilePath.substring(0, galleryFilePath.length - 4)} (1).jpg");
      } else {
        await _deleteFile(galleryFilePath);
      }
      await _deleteFile(originalFilePath);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        'Image saved to gallery',
        style: TextStyle(fontFamily: "Montserrat"),
      )));
      // save();
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  Future<void> _deleteFile(String filePath) async {
    // print("incoming" + filePath);
    try {
      File file = File(filePath);
      if (await file.exists()) {
        // print('Deleting file: $filePath');
        await file.delete();
      }
    } catch (e) {
      // print('Error deleting file: $e');
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
        "${dateTime.minute.toString().padLeft(2, '0')}:"
        "${dateTime.second.toString().padLeft(2, '0')}";

    return formattedDate;
  }

  String formatgps() {
    String formattedgps = "${currentLocation?.latitude.toString()}° N : "
        "${currentLocation?.longitude.toString()}° W";
    return formattedgps;
  }

  void getValue() async {
    var prefs = await SharedPreferences.getInstance();

    var getFolder = prefs.getBool("folder");
    var getResize = prefs.getBool("resize");
    var getResolution = prefs.getString("resolution");
    var getColor = prefs.getString("color");
    var getPicColor = prefs.getString("pickcolor");
    var getSeparate = prefs.getBool('separate');
    var getLocation = prefs.getBool('location');
    var getDate = prefs.getBool('date');
    var getname = prefs.getBool('name');
    String? getText = prefs.getString("text") ?? "";

    setState(() {
      isChecked = getResize ?? true;
      isfolder = getFolder ?? true;
      selectedResolution = getResolution ?? "800*600";

      if (getColor != null) {
        setState(() {
          currentColor = Color(int.parse(getColor, radix: 16));
        });
      } else {
        // Default color if not saved in preferences
        setState(() {
          currentColor = Colors.orange;
        });
      }
      if (getPicColor != null) {
        setState(() {
          pickerColor = Color(int.parse(getPicColor, radix: 16));
        });
      } else {
        setState(() {
          pickerColor = Colors.purple;
        });
      }
      isSeparate = getSeparate ?? false;
      isLocation = getLocation ?? false;
      isDate = getDate ?? true;
      isName = getname ?? false;
      if (isName == true) {
        _txtVehicleNumber.text = getText;
      }
    });
  }
}

class CheckboxDialog extends StatefulWidget {
  final ValueChanged<bool> onCheckbox1Changed;
  final ValueChanged<bool> onCheckbox2Changed;
  final ValueChanged<bool> onCheckbox3Changed;
  final ValueChanged<bool> onCheckbox4Changed;

  const CheckboxDialog({
    required this.onCheckbox1Changed,
    required this.onCheckbox2Changed,
    required this.onCheckbox3Changed,
    required this.onCheckbox4Changed,
  });

  @override
  _CheckboxDialogState createState() => _CheckboxDialogState();
}

class _CheckboxDialogState extends State<CheckboxDialog> {
  Map<String, bool> checkBoxStatus = {
    'isSeparate': false, // for saving image separately
    'isLocation': false, // for having location stamp
    'isDate': true, // for not having date time stamp
    'isName': false // for saving folder value
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    var prefs = await SharedPreferences.getInstance();
    var getSeparate = prefs.getBool('separate');
    var getLocation = prefs.getBool('location');
    var getDate = prefs.getBool('date');
    var getname = prefs.getBool('name');
    setState(() {
      checkBoxStatus['isSeparate'] = getSeparate ?? false;
      checkBoxStatus['isLocation'] = getLocation ?? false;
      checkBoxStatus['isDate'] = getDate ?? true;
      checkBoxStatus['isName'] = getname ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      title: Text(
        'Settings',
        style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: screenSize.height * 0.025,
            fontWeight: FontWeight.bold),
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  height: screenSize.height * 0.01875,
                  child: const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  )),
              CheckboxListTile(
                subtitle: Padding(
                  padding: EdgeInsets.only(bottom: screenSize.height * 0.00625),
                  child: Text(
                    "(Take and save image individually)",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                title: Padding(
                  padding: EdgeInsets.only(
                      top: screenSize.height * 0.00625,
                      bottom: screenSize.height * 0.00625),
                  child: Text(
                    "Save Image Individually",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: screenSize.height * 0.01875,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                value: checkBoxStatus['isSeparate'],
                onChanged: (value) async {
                  setState(() {
                    checkBoxStatus['isSeparate'] = value!;
                  });
                  widget.onCheckbox1Changed(value!);
                },
              ),
              SizedBox(
                  height: screenSize.height * 0.01875,
                  child: const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  )),
              CheckboxListTile(
                title: Padding(
                  padding: EdgeInsets.only(
                      top: screenSize.height * 0.00625,
                      bottom: screenSize.height * 0.00625),
                  child: Text(
                    "GPS Location Stamp",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: screenSize.height * 0.01875,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                value: checkBoxStatus['isLocation'],
                onChanged: (value) async {
                  setState(() {
                    checkBoxStatus['isLocation'] = value!;
                  });
                  widget.onCheckbox2Changed(value!);
                },
              ),
              SizedBox(
                  height: screenSize.height * 0.01875,
                  child: const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  )),
              CheckboxListTile(
                title: Padding(
                  padding: EdgeInsets.only(
                      top: screenSize.height * 0.00625,
                      bottom: screenSize.height * 0.00625),
                  child: Text(
                    "DateTime Stamp",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: screenSize.height * 0.01875,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                value: checkBoxStatus['isDate'],
                onChanged: (value) async {
                  setState(() {
                    checkBoxStatus['isDate'] = value!;
                  });
                  // widget.onCheckboxChanged({'isDate': value!});
                  widget.onCheckbox3Changed(value!);
                },
              ),
              SizedBox(
                  height: screenSize.height * 0.01875,
                  child: const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  )),
              CheckboxListTile(
                subtitle: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    "(Last used folder name will be stored)",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                title: Padding(
                  padding: EdgeInsets.only(
                      top: screenSize.height * 0.00625,
                      bottom: screenSize.height * 0.00625),
                  child: Text(
                    "Save Folder Name",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: screenSize.height * 0.01875,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                value: checkBoxStatus['isName'],
                onChanged: (value) async {
                  setState(() {
                    checkBoxStatus['isName'] = value!;
                  });
                  widget.onCheckbox4Changed(value!);
                },
              ),
              SizedBox(
                  height: screenSize.height * 0.01875,
                  child: const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  )),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  var prefs = await SharedPreferences.getInstance();
                  prefs.setBool('separate', checkBoxStatus['isSeparate']!);
                  prefs.setBool('location', checkBoxStatus['isLocation']!);
                  prefs.setBool('date', checkBoxStatus['isDate']!);
                  prefs.setBool('name', checkBoxStatus['isName']!);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, elevation: 5),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: screenSize.height * 0.00625,
                      bottom: screenSize.height * 0.00625),
                  child: Text('Save',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: screenSize.height * 0.0225,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
