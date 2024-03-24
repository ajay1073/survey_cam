// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_cam/authentication/otp.dart';
import 'package:survey_cam/authentication/login.dart';
import 'package:survey_cam/authentication/utils/check_login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static String verify = "";

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formkey = GlobalKey<FormState>();
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
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
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
                    Text("Sign-Up",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.0375,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    SizedBox(
                      height: screenSize.height * 0.025,
                    ),
                    TextFormField(
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenSize.height * 0.0225,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.025,
                            fontWeight: FontWeight.w500),
                        alignLabelWithHint: true,
                        labelText: "User Name",
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
                        if (value!.isEmpty) {
                          return "Please Enter Valid Name";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: screenSize.height * 0.035,
                    ),
                    TextFormField(
                      onChanged: (value) {
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
                      height: screenSize.height * 0.05,
                    ),
                    ElevatedButton(
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
                            var prefs = await SharedPreferences.getInstance();
                            prefs.setString("phone",
                                "+${selectedCountry.phoneCode}${phoneController.text}");
                            _checkIfNumberExistsAndSignUp(context);
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
                            "Send OTP",
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenSize.height * 0.025,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          )),
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
                        text: 'Already have an account?  ',
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.02,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'LOG-IN',
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
                                        builder: (context) => LoginScreen()));
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
          ),
        ),
      ),
    );
  }

  Future<void> _checkIfNumberExistsAndSignUp(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      print('+' + selectedCountry.phoneCode + phoneController.text);
      // Check if the user already exists in Firestore
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('phone',
              isEqualTo: '+' + selectedCountry.phoneCode + phoneController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("Old User");
        // User already exists, display a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'The entered phone number is already registered. Please Login'),
          ),
        );
      } else {
        print("hello new");
        String? deviceId = await CheckLoginLogic.getDeviceId();
        print(deviceId);
        // User not found, proceed with the sign-up process

        // Send OTP logic here (you need to implement this)

        // Navigate to OTPPage with user information
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+${selectedCountry.phoneCode}${phoneController.text}',
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential);
          },
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
                          name: nameController.text,
                        )));
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } catch (e) {
      print('Error checking account: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred. Please try again later.'),
      ));
    }
  }
}
