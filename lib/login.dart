import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mycam/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  int randomNumber = Random().nextInt(1000) + 1;
  late String code;
  bool isAdmin = false;
  bool isActive = true;
  bool isLogin = false;
  late String name;
  late String phone;
  late String id = "";

  genrateCode(int n, double a) {
    return ((pow(n, 2) + 3 * a) / 2 - sqrt(a + n / 2)).toStringAsFixed(2);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getValue();
    checkLogin();
    code = genrateCode(randomNumber, 2.5);
    print(genrateCode(randomNumber, 2.5));
  }

  void getValue() async {
    var prefs = await SharedPreferences.getInstance();
    var getName = prefs.getString("username");
    var getPhone = prefs.getString("userphone");
    var getid = prefs.getString("userid");
    var isLoggedIn = prefs.getBool('isLoggedIn');

    setState(() {
      id = getid ?? "";
      nameController.text = getName ?? "";
      phoneController.text = getPhone ?? "";

      isLogin = isLoggedIn ?? false;
    });
  }

  Future<bool> checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void checkLogin() async {
    var prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print(isLoggedIn);

    if (isLoggedIn == true) {
      // User is logged in, get the stored name
      String? storedId = prefs.getString("userid");
      if (storedId != null) {
        // Check in Firestore if the storedName has isActive value as true
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection("users")
            .where("user_id", isEqualTo: storedId)
            .where("is_active", isEqualTo: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // If there is a user with the provided name and isActive is true, navigate to the next screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CaptureAndStampImage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("User is current not an active member")));
          // Handle the case when the user is not found or isActive is not true
          // You can show a message or take appropriate action
          print("User not found or not active, ");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
          child: Padding(
        padding: isLogin == true
            ? EdgeInsets.only(
                top: screenSize.height * 0.075,
                bottom: screenSize.height * 0.03,
                left: screenSize.width * 0.055,
                right: screenSize.width * 0.055,
              )
            : EdgeInsets.symmetric(
                vertical: screenSize.height * 0.075,
                horizontal: screenSize.width * 0.055),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Login",
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenSize.height * 0.0375,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                SizedBox(
                  height: screenSize.height * 0.025,
                ),
                isLogin == true
                    ? RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenSize.height * 0.01875,
                                fontWeight: FontWeight.w600,
                                color: Colors.red),
                            children: [
                              const TextSpan(
                                  text:
                                      "You are not an active member, if it's a mistake SMS us at 9425143900 or 9039607701 this given number "),
                              TextSpan(
                                  text: "$randomNumber",
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue)),
                              const TextSpan(text: " and user id.")
                            ]),
                      )
                    : RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.021875,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(
                              text: "SMS ",
                            ),
                            TextSpan(
                              text: "$randomNumber",
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors
                                    .blue, // You can use any color you want
                              ),
                            ),
                            const TextSpan(
                              text:
                                  " along with your name and phone number to 9425143900 or 9039607701 to get your code",
                            ),
                          ],
                        ),
                      ),
                SizedBox(height: screenSize.height * 0.025),
                Text(
                    "NOTE: Do not close your app fully while waiting for the code. Preffered to keep it in recent apps, otherwise generated number can get changed",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenSize.height * 0.015,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey)),
                SizedBox(
                  height: screenSize.height * 0.025,
                ),
                // Text("Your generated code is: $code",
                //     textAlign: TextAlign.center,
                //     style: const TextStyle(
                //         fontFamily: "Montserrat",
                //         fontSize: 15,
                //         fontWeight: FontWeight.w600,
                //         color: Colors.grey)),

                isLogin == false
                    ? Column(
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "This field is important";
                              }
                              return null;
                            },
                            onChanged: (value) async {
                              setState(() {
                                nameController.text = value;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString("username", value);
                            },
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenSize.height * 0.0225,
                            ),
                            decoration: InputDecoration(
                              labelText: "Name",
                              labelStyle: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenSize.height * 0.0255,
                              ),
                              hintText: "Enter Your Name",
                              hintStyle: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: screenSize.height * 0.0175,
                                  fontWeight: FontWeight.bold),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.red,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: nameController.text.isEmpty
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenSize.height * 0.025,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.length != 10) {
                                return "Please enter valid mobile number";
                              }
                              return null;
                            },
                            onChanged: (value) async {
                              setState(() {
                                phoneController.text = value;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString("userphone", value);
                            },
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenSize.height * 0.0225,
                            ),
                            decoration: InputDecoration(
                              labelText: "Phone Number",
                              labelStyle: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenSize.height * 0.0255,
                              ),
                              hintText: "Enter Your Phone Number",
                              hintStyle: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: screenSize.height * 0.0175,
                                  fontWeight: FontWeight.bold),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 2, color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2,
                                    color: phoneController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenSize.height * 0.025,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          SelectableText.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'User-ID: ',
                                  style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: screenSize.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: SizedBox(
                                          width: screenSize.width * 0.01388),
                                    ),
                                    TextSpan(
                                      text: id,
                                      style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.02,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            style: TextStyle(
                              fontSize: screenSize.height * 0.02,
                            ),
                            cursorColor: Colors.blue,
                          ),
                          SizedBox(
                            height: screenSize.height * 0.025,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "This field is important";
                              }
                              return null;
                            },
                            onChanged: (value) async {
                              setState(() {
                                nameController.text = value;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString("username", value);
                            },
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenSize.height * 0.0225,
                            ),
                            decoration: InputDecoration(
                              labelText: "Name",
                              labelStyle: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenSize.height * 0.0255,
                              ),
                              hintText: "Enter Your Name",
                              hintStyle: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: screenSize.height * 0.0175,
                                  fontWeight: FontWeight.bold),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.red,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: nameController.text.isEmpty
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenSize.height * 0.025,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.length != 10) {
                                return "Please enter valid mobile number";
                              }
                              return null;
                            },
                            onChanged: (value) async {
                              setState(() {
                                phoneController.text = value;
                              });
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString("userphone", value);
                            },
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenSize.height * 0.0225,
                            ),
                            decoration: InputDecoration(
                              labelText: "Phone Number",
                              labelStyle: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenSize.height * 0.0255,
                              ),
                              hintText: "Enter Your Phone Number",
                              hintStyle: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: screenSize.height * 0.0175,
                                  fontWeight: FontWeight.bold),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 2, color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2,
                                    color: phoneController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenSize.height * 0.025,
                          )
                        ],
                      ),

                TextFormField(
                  validator: (value) {
                    if (value != code.toString() || value!.isEmpty) {
                      return "Entered code is not valid";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      codeController.text = value;
                    });
                  },
                  controller: codeController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenSize.height * 0.0225,
                  ),
                  decoration: InputDecoration(
                    labelText: "Code",
                    labelStyle: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: screenSize.height * 0.0255,
                    ),
                    hintText: "Enter Given Code",
                    hintStyle: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenSize.height * 0.0175,
                        fontWeight: FontWeight.bold),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.blue,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.blue,
                      ),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.red,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: codeController.text.isEmpty
                            ? Colors.red
                            : Colors.blue,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: screenSize.height * 0.025,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formkey.currentState?.validate() == true) {
                        if (isLogin == false) {
                          var prefs = await SharedPreferences.getInstance();
                          var uid = const Uuid();
                          String userId = uid.v4();
                          prefs.setString("userid", userId);
                          bool operationCompleted = true;
                          try {
                            // Check internet connectivity before attempting Firestore operation
                            bool isConnected =
                                await checkInternetConnectivity();
                            if (isConnected == false) {
                              print("yahan");
                              // Handle lack of internet connectivity
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "No internet connection. Please try again."),
                                ),
                              );
                              return;
                            }

                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(userId)
                                .set({
                              "name": nameController.text,
                              "phone": phoneController.text,
                              "user_id": userId,
                              "is_active": isActive,
                              "is_admin": isAdmin,
                            }).timeout(Duration(seconds: 30),
                                    onTimeout: () async {
                              operationCompleted = false;
                              // Handle timeout, for example, show a message to the user
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please check your internet connection and try again"),
                                ),
                              );

                              // Return a value or throw an error to indicate the timeout
                              return Future.error(
                                  "No internet connection"); // You can customize this based on your needs
                            });

                            if (operationCompleted) {
                              prefs.setString("userid", userId);
                              prefs.setBool("isLoggedIn", true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("User Added")),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CaptureAndStampImage(),
                                ),
                              );
                            }
                          } catch (e) {
                            // Handle Firestore errors if needed
                            print("Firestore error: $e");
                          }
                        } else {
                          var prefs = await SharedPreferences.getInstance();
                          String? storedid = prefs.getString("userid");
                          bool operationCompleted = true;
                          try {
                            // Check internet connectivity before attempting Firestore operation
                            bool isConnected =
                                await checkInternetConnectivity();
                            if (isConnected == false) {
                              print("yahan");
                              // Handle lack of internet connectivity
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "No internet connection. Please try again."),
                                ),
                              );
                              return;
                            }
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(storedid)
                                .update({
                              "name": nameController.text,
                              "phone": phoneController.text,
                              "is_active": isActive,
                            }).timeout(Duration(seconds: 30),
                                    onTimeout: () async {
                              operationCompleted = false;
                              // Handle timeout, for example, show a message to the user
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please check your internet connection and try again"),
                                ),
                              );

                              // Return a value or throw an error to indicate the timeout
                              return Future.error(
                                  "No internet connection"); // You can customize this based on your needs
                            });

                            if (operationCompleted) {
                              prefs.setBool("isLoggedIn", true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("User Updated")));
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CaptureAndStampImage()),
                              );
                            }
                          } catch (e) {
                            // Handle Firestore errors if needed
                            print("Firestore error: $e");
                          }
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
                        "Login",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenSize.height * 0.025,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    height: screenSize.height * 0.0625,
                    child: const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    )),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
