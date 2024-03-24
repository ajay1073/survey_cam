import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class RequestPage extends StatefulWidget {
  final String phoneNumber;
  final String message;
  const RequestPage(
      {super.key, required this.phoneNumber, required this.message});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final _formkey = GlobalKey<FormState>();
  String selectedQuery = "--Select Query--";
  List<String> query = <String>[
    "--Select Query--",
    "Not an Active Member",
    "Authorize this device",
  ];

  Future<bool> checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String?> getDeviceId() async {
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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      contentPadding: EdgeInsets.only(bottom: screenSize.height * 0.02),
      content: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.055,
            horizontal: screenSize.width * 0.055),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Text("Query",
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenSize.height * 0.0375,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                SizedBox(
                  height: screenSize.height * 0.03,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenSize.height * 0.01875,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey),
                      children: [
                        const TextSpan(
                            text:
                                "We got an issue related to your account registered on:-"),
                        TextSpan(
                            text: widget.phoneNumber.substring(0, 2),
                            style: const TextStyle(color: Colors.blue)),
                        TextSpan(
                            text: "${widget.phoneNumber.substring(2)} ",
                            style: const TextStyle(
                              color: Colors.blue,
                            )),
                      ]),
                ),
                SizedBox(
                  height: screenSize.height * 0.05,
                ),
                Text(
                  widget.message,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: screenSize.height * 0.01875,
                      fontWeight: FontWeight.w600,
                      color: Colors.red),
                ),
                SizedBox(
                  height: screenSize.height * 0.05,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    labelText: "Query",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  onChanged: (value) async {
                    setState(() {
                      selectedQuery = value!;
                    });
                  },
                  value: selectedQuery,
                  validator: (value) {
                    if (value == "--Select Query--") {
                      return "Please select a valid option";
                    }
                    return null; // Return null if validation succeeds
                  },
                  items: query.map((e) {
                    return DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600),
                        ));
                  }).toList(),
                ),
                SizedBox(
                  height: screenSize.height * 0.05,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formkey.currentState?.validate() == true) {
                        bool isConnected = await checkInternetConnectivity();
                        if (isConnected == false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "No internet connection. Please try again."),
                            ),
                          );
                        } else {
                          sendRquest();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 5,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: screenSize.height * 0.0125,
                          horizontal: screenSize.width * 0.0277),
                      child: Text(
                        "Send Request",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.025,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  sendRquest() async {
    String? deviceId = await getDeviceId();
    print(deviceId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("users")
        .where("phone", isEqualTo: widget.phoneNumber)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Assuming phone numbers are unique, so there should be at most one document
      DocumentSnapshot<Map<String, dynamic>> userDocument = snapshot.docs.first;
      String userId = userDocument.id;
      String name = userDocument.data()!["name"];
      print('User ID: $userId');

      QuerySnapshot<Map<String, dynamic>> snapshot2 = await FirebaseFirestore
          .instance
          .collection("request")
          .where("user_id", isEqualTo: userId)
          .where("status", isEqualTo: false)
          .get();

      if (snapshot2.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("A request from your account is already active")));
      }
      // Now you have the user ID based on the phone number
      else {
        FirebaseFirestore.instance.collection("request").doc(userId).set({
          "phone": widget.phoneNumber,
          "user_id": userId,
          "new_device_id": deviceId,
          "request_time": DateTime.now(),
          "query": selectedQuery,
          "status": false
        }).then((value) => {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Request Added"))),
            });
      }
    } else {
      // No user found with the given phone number
      print('User not found');
    }
  }
}
