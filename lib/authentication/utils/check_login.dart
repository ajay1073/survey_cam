import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_cam/authentication/login.dart';
import 'package:survey_cam/authentication/request.dart';
import 'package:survey_cam/camerapage.dart';
import 'package:survey_cam/model/usermodel.dart';
import 'package:location/location.dart' as loc;

class CheckLoginLogic {
  static loc.Location location = loc.Location();
  static loc.LocationData? currentLocation;
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

  static Future<bool> checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static void checkLogin(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    String? storedPhone = prefs.getString("phone");
    var isLogin = prefs.getBool('isLoggedIn');
    print(isLogin);

    if (isLogin == true) {
      // User is logged in, get the stored name
      if (storedPhone != null) {
        print(storedPhone);
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection("users")
            .where("phone", isEqualTo: storedPhone)
            .get();
        if (snapshot.docs.isNotEmpty) {
          // Assuming phone numbers are unique, so there should be at most one document
          DocumentSnapshot<Map<String, dynamic>> userDocument =
              snapshot.docs.first;
          String userId = userDocument.id;
          String name = userDocument.data()!["name"];
          bool active = userDocument.data()!["is_active"];
          String device = userDocument.data()!["device_id"];
          bool admin = userDocument.data()!["is_admin"];
          Timestamp signup = userDocument.data()!["sign_up"];
          print('User ID: $userId');

          if (active == true) {
            // If there is a user with the provided isActive is true, navigate to the next screen
            String? deviceId = await getDeviceId();
            print(deviceId);

            if (deviceId == device) {
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
                                    user: UserModel(
                                        userName: name,
                                        userPhone: storedPhone,
                                        userID: userId,
                                        deviceID: device,
                                        isAdmin: admin,
                                        isActive: active,
                                        lastUsed: Timestamp.now(),
                                        signUp: signup),
                                  )),
                        ),
                      });
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
        } else {
          // No user found with the given phone number
          print('User not found');
        }
        // Check in Firestore if the storedName has isActive value as true
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  static Future<bool> checkExist(String? storedphone) async {
    print(storedphone);
    // Check if the user already exists in Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: storedphone)
        .get();
    if (querySnapshot.docs.isEmpty) {
      print("ja be new");
      // User already exists, display a message

      return false;
    } else {
      print("hello old");
      return true;
    }
  }

  static Future<void> getLocation() async {
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

  genrateCode(int n, double a) {
    return ((pow(n, 2) + 3 * a) / 2 - sqrt(a + n / 2)).toStringAsFixed(2);
  }
}
