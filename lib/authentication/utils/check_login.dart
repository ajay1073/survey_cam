import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_cam/authentication/login.dart';
import 'package:survey_cam/authentication/request.dart';
import 'package:survey_cam/camerapage.dart';

class CheckLoginLogic {
  static Future<String?> getDeviceId() async {
    String? deviceId;

    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId =
            "ID: ${androidInfo.androidId} Model: ${androidInfo.model} Manufacturer: ${androidInfo.manufacturer}"; // Get Android device ID
        print(deviceId);
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId =
            "ID: ${iosInfo.identifierForVendor} Model: ${iosInfo.utsname.machine} Manufacturer: Apple"; // Get iOS device ID
        print(deviceId);
      }
    } catch (e) {
      print('Error getting device ID: $e');
    }

    return deviceId;
  }

  static void checkLogin(BuildContext context) async {
    bool isActive;
    bool deviceSame;
    bool isAdmin;
    String role;
    var prefs = await SharedPreferences.getInstance();
    String? storedPhone = prefs.getString("phone");
    var isLogin = prefs.getBool('isLoggedIn');
    print(isLogin);

    if (isLogin == true) {
      // User is logged in, get the stored name
      if (storedPhone != null) {
        // Check in Firestore if the storedName has isActive value as true
        isActive = await checkActive(storedPhone);
        if (isActive == true) {
          // If there is a user with the provided isActive is true, navigate to the next screen
          String? deviceId = await getDeviceId();
          print(deviceId);
          deviceSame = await checkDevice(storedPhone);

          if (deviceSame == true) {
            isAdmin = await checkadmin(storedPhone);
            if (isAdmin == true) {
              role = "Admin";
            } else {
              role = "User";
            }
            QuerySnapshot<Map<String, dynamic>> snapshot =
                await FirebaseFirestore.instance
                    .collection("users")
                    .where("phone", isEqualTo: storedPhone)
                    .get();

            if (snapshot.docs.isNotEmpty) {
              // Assuming phone numbers are unique, so there should be at most one document
              DocumentSnapshot<Map<String, dynamic>> userDocument =
                  snapshot.docs.first;
              String userId = userDocument.id;
              // String device = userDocument.data()!["device"];
              print('User ID: $userId');

              prefs.setBool("isLoggedIn", true);
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .update({
                "last_used": DateTime.now(),
              }).then((value) => {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Welcome Back!"))),
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CaptureAndStampImage(
                                    role: role,
                                  )),
                        ),
                      });
            }
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
            showDialog(
                context: context,
                builder: (BuildContext) {
                  return RequestPage(
                      phoneNumber: storedPhone,
                      message:
                          "It's seems like this account is registered  on another device. If you want to authorize this device with your account send us your query with selected problem given in drop down menu below.");
                });
            // Handle the case when the user is not found or isActive is not true
            // You can show a message or take appropriate action
            print("User device ID is not same");
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
          showDialog(
              context: context,
              builder: (BuildContext) {
                return RequestPage(
                    phoneNumber: storedPhone,
                    message:
                        "It's seems like you are not an active member, if it's a mistake, send us your query with selected problem given in drop down menu below.");
              });
          // Handle the case when the user is not found or isActive is not true
          // You can show a message or take appropriate action
          print("User not active, ");
        }
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  static Future<bool> checkDevice(String? storedphone) async {
    String? deviceId = await getDeviceId();
    String? devicePhone = storedphone;
    print(deviceId);
    print(storedphone);
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("users")
        .where("phone", isEqualTo: devicePhone)
        .where("device_id", isEqualTo: deviceId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // If there is a user with the provided device is same, navigate to the next screen
      print("device same");
      return true;
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text("Account is registered in another device")));
      // Handle the case when the user is not found or isActive is not true
      // You can show a message or take appropriate action
      print("User device ID is not same");
      return false;
    }
  }

  static Future<bool> checkActive(String? storedphone) async {
    String? devicePhone = storedphone;
    // Check if the user already exists in Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where("phone", isEqualTo: devicePhone)
        .where("is_active", isEqualTo: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      print("Active");
      // User already exists, display a message

      return true;
    } else {
      print("NotActive");
      return false;
    }
  }

  static Future<bool> checkadmin(String? storedphone) async {
    String? devicePhone = storedphone;
    // Check if the user already exists in Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where("phone", isEqualTo: devicePhone)
        .where("is_admin", isEqualTo: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      print("Admin");
      return true;
    } else {
      print("NotAdmin");
      return false;
    }
  }
}
