import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_cam/authentication/otp.dart';
import 'package:survey_cam/authentication/request.dart';
import 'package:survey_cam/authentication/signup.dart';
import 'package:survey_cam/authentication/utils/check_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController codeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  int randomNumber = Random().nextInt(1000) + 1;
  late String code;
  String? mobile;
  bool isActive = true;
  bool isLogin = false;
  bool deviceSame = true;
  bool isAdmin = false;
  bool numberExist = true;
  String selectedQuery = "--Select Query--";
  String role = "";
  List<String> query = <String>[
    "--Select Query--",
    "Not an Active Member",
    "Authorize this device",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getValue();
    // checkLogin();
    // code = genrateCode(randomNumber, 2.5);
    // print(genrateCode(randomNumber, 2.5));
  }

  void getValue() async {
    var prefs = await SharedPreferences.getInstance();
    var isLoggedIn = prefs.getBool('isLoggedIn');
    // print(isLoggedIn);
    var phoneNo = prefs.getString("phone") ?? "";

    setState(() {
      isLogin = isLoggedIn ?? false;
      mobile = phoneNo;
    });
  }

  void checkotpLogin(BuildContext context, String storedPhone) async {
    print(storedPhone);
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("users")
        .where("phone", isEqualTo: storedPhone)
        .get();
    if (snapshot.docs.isNotEmpty) {
      // Assuming phone numbers are unique, so there should be at most one document
      DocumentSnapshot<Map<String, dynamic>> userDocument = snapshot.docs.first;
      String userId = userDocument.id;
      bool active = userDocument.data()!["is_active"];
      String device = userDocument.data()!["device_id"];
      print('User ID: $userId');

      if (active == true) {
        // If there is a user with the provided isActive is true, navigate to the next screen
        String? deviceId = await CheckLoginLogic.getDeviceId();
        print(deviceId);

        if (deviceId == device) {
          print("yahan 2");
          var prefs = await SharedPreferences.getInstance();
          prefs.setString(
              "phone", "+${selectedCountry.phoneCode}${phoneController.text}");
          _checkIfNumberExistsAndSignUp(context);
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

  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "India",
    displayName: "India",
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
          child: Padding(
        padding: EdgeInsets.symmetric(
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
                SizedBox(height: screenSize.height * 0.035),
                TextFormField(
                  onChanged: (value) async {
                    setState(() {
                      phoneController.text = value;
                    });
                  },
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: screenSize.height * 0.0225,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  decoration: InputDecoration(
                    suffixIcon: phoneController.text.length > 9
                        ? const Icon(
                            Icons.phone,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.phone,
                            color: Colors.black,
                          ),
                    prefixIcon: Container(
                      width: screenSize.width * 0.29,
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                              countryListTheme: const CountryListThemeData(
                                bottomSheetHeight: 500,
                              ),
                              context: context,
                              onSelect: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              });
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenSize.height * 0.014,
                                  bottom: screenSize.height * 0.014,
                                  left: screenSize.width * 0.031,
                                  right: screenSize.width * 0.01),
                              child: Text(
                                "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: screenSize.height * 0.0225,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              "l",
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: screenSize.height * 0.07,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ),
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontFamily: "Montserrat",
                        fontSize: screenSize.height * 0.025,
                        fontWeight: FontWeight.w500),
                    alignLabelWithHint: true,
                    labelText: "User Phone",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.black,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.black,
                      ),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.red,
                      ),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value!.length < 10 || value.isEmpty) {
                      return "Please Enter valid Phone Number";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.025,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formkey.currentState?.validate() == true) {
                        bool isConnected =
                            await CheckLoginLogic.checkInternetConnectivity();
                        if (isConnected == false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "No internet connection. Please try again."),
                            ),
                          );
                        } else {
                          numberExist = await CheckLoginLogic.checkExist(
                              "+${selectedCountry.phoneCode}${phoneController.text}");
                          print("2");
                          if (numberExist == false) {
                            print("3");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'The entered phone number is not registered. Please Sign-Up'),
                              ),
                            );
                          } else {
                            checkotpLogin(context,
                                "+${selectedCountry.phoneCode}${phoneController.text}");
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
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenSize.height * 0.03,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: screenSize.width * 0.4,
                      height: screenSize.height * 0.03,
                      child: const Divider(
                        color: Colors.blueGrey,
                      ),
                    ),
                    Text(
                      "OR",
                      style: TextStyle(
                          fontFamily: "Oswald",
                          fontSize: screenSize.height * 0.025),
                    ),
                    SizedBox(
                      width: screenSize.width * 0.4,
                      height: screenSize.height * 0.03,
                      child: const Divider(
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenSize.height * 0.03,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Not a User?  ',
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenSize.height * 0.02,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'SIGN-UP',
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.02,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                        // Add an onTap handler for the TextButton
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Handle the login button press
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()));
                            print('Login button pressed');
                          },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }

  Future<void> _checkIfNumberExistsAndSignUp(BuildContext context) async {
    try {
      print('+${selectedCountry.phoneCode}${phoneController.text}');
      // Check if the user already exists in Firestore
      print("hello old");
      String? deviceId = await CheckLoginLogic.getDeviceId();
      print(deviceId);
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+${selectedCountry.phoneCode}${phoneController.text}',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {
          // SignUpPage.verify = verificationId;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OTPPage(
                        phoneNumber:
                            "+${selectedCountry.phoneCode}${phoneController.text}",
                        verificationID: verificationId,
                        deviceID: deviceId.toString(),
                      )));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      // User not found, proceed with the sign-up process

      // Send OTP logic here (you need to implement this)

      // Navigate to OTPPage with user information
    } catch (e) {
      print('Error checking account: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred. Please try again later.'),
      ));
    }
  }
}


// if (_formkey.currentState?.validate() == true) {
//                         if (isLogin == false) {
//                           var prefs = await SharedPreferences.getInstance();
//                           var uid = const Uuid();
//                           String userId = uid.v4();
//                           prefs.setString("userid", userId);
//                           bool operationCompleted = true;
//                           try {
//                             // Check internet connectivity before attempting Firestore operation
//                             bool isConnected =
//                                 await checkInternetConnectivity();
//                             if (isConnected == false) {
//                               print("yahan");
//                               // Handle lack of internet connectivity
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text(
//                                       "No internet connection. Please try again."),
//                                 ),
//                               );
//                               return;
//                             }

//                             await FirebaseFirestore.instance
//                                 .collection("users")
//                                 .doc(userId)
//                                 .set({
//                               "name": nameController.text,
//                               "phone": phoneController.text,
//                               "user_id": userId,
//                               "is_active": isActive,
//                               "is_admin": isAdmin,
//                             }).timeout(Duration(seconds: 30),
//                                     onTimeout: () async {
//                               operationCompleted = false;
//                               // Handle timeout, for example, show a message to the user
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text(
//                                       "Please check your internet connection and try again"),
//                                 ),
//                               );

//                               // Return a value or throw an error to indicate the timeout
//                               return Future.error(
//                                   "No internet connection"); // You can customize this based on your needs
//                             });

//                             if (operationCompleted) {
//                               prefs.setString("userid", userId);
//                               prefs.setBool("isLoggedIn", true);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text("User Added")),
//                               );
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => CaptureAndStampImage(),
//                                 ),
//                               );
//                             }
//                           } catch (e) {
//                             // Handle Firestore errors if needed
//                             print("Firestore error: $e");
//                           }
//                         } else {
//                           var prefs = await SharedPreferences.getInstance();
//                           String? storedid = prefs.getString("userid");
//                           bool operationCompleted = true;
//                           try {
//                             // Check internet connectivity before attempting Firestore operation
//                             bool isConnected =
//                                 await checkInternetConnectivity();
//                             if (isConnected == false) {
//                               print("yahan");
//                               // Handle lack of internet connectivity
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text(
//                                       "No internet connection. Please try again."),
//                                 ),
//                               );
//                               return;
//                             }
//                             await FirebaseFirestore.instance
//                                 .collection("users")
//                                 .doc(storedid)
//                                 .update({
//                               "name": nameController.text,
//                               "phone": phoneController.text,
//                               "is_active": isActive,
//                             }).timeout(Duration(seconds: 30),
//                                     onTimeout: () async {
//                               operationCompleted = false;
//                               // Handle timeout, for example, show a message to the user
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text(
//                                       "Please check your internet connection and try again"),
//                                 ),
//                               );

//                               // Return a value or throw an error to indicate the timeout
//                               return Future.error(
//                                   "No internet connection"); // You can customize this based on your needs
//                             });

//                             if (operationCompleted) {
//                               prefs.setBool("isLoggedIn", true);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                       content: Text("User Updated")));
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         CaptureAndStampImage()),
//                               );
//                             }
//                           } catch (e) {
//                             // Handle Firestore errors if needed
//                             print("Firestore error: $e");
//                           }
//                         }
//                       }
