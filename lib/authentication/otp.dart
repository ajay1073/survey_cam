import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_cam/camerapage.dart';
import 'package:uuid/uuid.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationID;
  final String deviceID;
  final String name;
  final String role;
  // final Function()? onVerificationSuccess;
  const OTPPage({
    Key? key,
    required this.phoneNumber,
    required this.verificationID,
    required this.deviceID,
    this.name = '',
    this.role = '',
    // this.onVerificationSuccess
  }) : super(key: key);

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FocusNode _focusNode = FocusNode();

  final _formkey = GlobalKey<FormState>();
  var code = '';
  bool isAdmin = false;
  bool isActive = true;

  Future<bool> checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: screenSize.height * 0.075,
                horizontal: screenSize.width * 0.055),
            child: Center(
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Text("OTP Verification",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.0375,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    SizedBox(
                      height: screenSize.height * 0.035,
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
                                    "Please enter the otp sent to your mobile number:-"),
                            TextSpan(
                                text: widget.phoneNumber.substring(0, 2),
                                style: const TextStyle(color: Colors.blue)),
                            TextSpan(
                                text: "${widget.phoneNumber.substring(2)} ",
                                style: const TextStyle(color: Colors.blue)),
                          ]),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.035,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        FocusScope.of(context).requestFocus(_focusNode);
                      },
                      child: Pinput(
                        defaultPinTheme: PinTheme(
                          width: screenSize.width * 0.15,
                          height: screenSize.height * 0.07,
                          textStyle: TextStyle(
                            fontSize: screenSize.height * 0.04,
                            color:
                                Colors.blueAccent, // Change the text color here
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(
                                color: Colors
                                    .black), // Change the border color here
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        focusNode: _focusNode,
                        length: 6,
                        showCursor: true,
                        onChanged: (value) {
                          code = value;
                          print(code);
                        },
                      ),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.05,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        var prefs = await SharedPreferences.getInstance();
                        bool isConnected = await checkInternetConnectivity();
                        if (isConnected == false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "No internet connection. Please try again."),
                            ),
                          );
                        } else {
                          try {
                            print("1");
                            PhoneAuthCredential creds =
                                PhoneAuthProvider.credential(
                                    verificationId: widget.verificationID,
                                    smsCode: code);
                            print(widget.verificationID);
                            print(code);
                            print("2");
                            User? user =
                                (await auth.signInWithCredential(creds)).user;
                            print(user!.phoneNumber.toString());
                            print("3");
                            if (user != null) {
                              // carry our logic
                              // _user = user;
                              print("success case");
                              if (widget.name != '') {
                                print("hello");
                                var uid = const Uuid();
                                String userId = uid.v4();
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(userId)
                                    .set({
                                  "name": widget.name,
                                  "phone": widget.phoneNumber,
                                  "user_id": userId,
                                  "device_id": [widget.deviceID],
                                  "is_active": isActive,
                                  "is_admin": isAdmin,
                                  "last_used": DateTime.now(),
                                  "sign_up": DateTime.now()
                                }).then((value) => {
                                          prefs.setBool("isLoggedIn", true),
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text("User Added"))),
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CaptureAndStampImage(
                                                      role: "User",
                                                    )),
                                          ),
                                        });
                              } else {
                                QuerySnapshot<Map<String, dynamic>> snapshot =
                                    await FirebaseFirestore.instance
                                        .collection("users")
                                        .where("phone",
                                            isEqualTo: widget.phoneNumber)
                                        .get();

                                if (snapshot.docs.isNotEmpty) {
                                  // Assuming phone numbers are unique, so there should be at most one document
                                  DocumentSnapshot<Map<String, dynamic>>
                                      userDocument = snapshot.docs.first;
                                  String userId = userDocument.id;
                                  print('User ID: $userId');
                                  prefs.setBool("isLoggedIn", true);
                                  FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(userId)
                                      .update({
                                    "last_used": DateTime.now(),
                                  }).then((value) => {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content:
                                                        Text("User Verified"))),
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CaptureAndStampImage(
                                                        role: widget.role,
                                                      )),
                                            ),
                                          });
                                }
                              }
                            }
                          } on FirebaseAuthException catch (e) {
                            print("${e}is error");
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 5,
                      ),
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.0277,
                              vertical: screenSize.height * 0.0125),
                          child: Text(
                            "Verify OTP",
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                color: Colors.white,
                                fontSize: screenSize.height * 0.025,
                                fontWeight: FontWeight.w600),
                          )),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.1,
                      child: const Divider(
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Edit Phone Number?',
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: screenSize.height * 0.024,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue),
                            ))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
