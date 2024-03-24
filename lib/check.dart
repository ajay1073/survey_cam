import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stamp_image/stamp_image.dart';
import 'package:survey_cam/card/image.dart';
import 'package:survey_cam/model/image.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final picker = ImagePicker();
  File? image;

  void takePicture() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await resetImage();
      uploadFile(File(pickedFile.path));
      StampImage.create(
        context: context,
        image: File(pickedFile.path),
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: _watermarkItem(),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: _logoFlutter(),
          )
        ],
        onSuccess: (file) => resultStamp(file),
      );
    }
  }

  ///Resetting an image file
  Future resetImage() async {
    setState(() {
      image = null;
    });
  }

  ///Handler when stamp image complete
  void resultStamp(File? file) {
    print(file?.path);
    setState(() {
      image = file;
    });
  }

  Widget _watermarkItem() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateTime.now().toString(),
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          SizedBox(height: 5),
          Text(
            "Made By Stamp Image",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoFlutter() {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: FlutterLogo(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stamp Imager"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageWidget(),
              SizedBox(height: 10),
              _buttonTakePicture(),
              showOnlineImage(),
            ],
          ),
        ),
      ),
    );
  }

  showOnlineImage() {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc("f9dc1445-9b70-4483-8d7b-bc63ad3fc853")
            .collection("photos")
            .doc("MP 16")
            .collection("13032024")
            // .doc("13032024 : 163048")
            .snapshots(),
        builder: (context, photoSnapshot) {
          if (!photoSnapshot.hasData) {
            return const Text(
              "No Photos...",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 16,
                color: Colors.black,
              ),
            );
          } else {
            // Build a list of photos for the current user
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: photoSnapshot.data!.docs.length,
              itemBuilder: (context, photoIndex) {
                // var photoDoc = photoSnapshot.data!.docs[photoIndex];
                return ImageCaer(
                    model: ImageModel.fromfirestore(
                        photoSnapshot.data!.docs[photoIndex]),
                    context: context);
                // Use the photo document to display or process the photo data
                // You can create a widget for displaying individual photos
                // For example: PhotoCard(photoData: PhotoModel.fromFirestore(photoDoc))
              },
            );
          }
        },
      ),
    );
  }

  Widget _buttonTakePicture() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () => takePicture(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          "Take Picture",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Widget _imageWidget() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      child: image != null ? Image.file(image!) : SizedBox(),
    );
  }

  Future<void> uploadFile(
    File filePath,
  ) async {
    try {
      TaskSnapshot task = await FirebaseStorage.instance
          .ref()
          .child("fileName.png")
          .putFile(filePath);

      String url = await FirebaseStorage.instance
          .ref()
          .child("fileName.png")
          .getDownloadURL();
      print("Downloaded");
      print(url);
      String date = DateTime.now().day.toString().padLeft(2, '0') +
          DateTime.now().month.toString().padLeft(2, '0') +
          DateTime.now().year.toString();
      String doc = DateTime.now().day.toString().padLeft(2, '0') +
          DateTime.now().month.toString().padLeft(2, '0') +
          DateTime.now().year.toString() +
          " : " +
          DateTime.now().hour.toString().padLeft(2, '0') +
          DateTime.now().minute.toString().padLeft(2, '0') +
          DateTime.now().second.toString().padLeft(2, '0');
      FirebaseFirestore.instance
          .collection("users")
          .doc("f9dc1445-9b70-4483-8d7b-bc63ad3fc853")
          .collection("photos")
          .doc("MP 16")
          .collection(date)
          .doc(doc)
          .set({"image": url}).then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Image Uploaded"))));
    } catch (e) {
      print(e);
    }
  }
}
