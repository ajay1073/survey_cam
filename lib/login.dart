import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPhoneNumber = true;
  bool isSendingOTP = false;
  final _formkey = GlobalKey<FormState>();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String verificationCode = "";

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
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Login",
                  style: GoogleFonts.montserrat(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              const SizedBox(
                height: 20,
              ),
              Text("Enter your registered mobile number and login with otp",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) {
                  if (value!.length < 10 || value.isEmpty) {
                    return "Please Enter valid Phone Number";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _mobileController.text = value;
                  });
                },
                readOnly: !isPhoneNumber,
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  suffixIcon: _mobileController.text.length > 9
                      ? const Icon(
                          Icons.phone,
                          color: Colors.green,
                        )
                      : const Icon(
                          Icons.phone,
                          color: Colors.black,
                        ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.only(top: 13, left: 8, right: 8),
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
                      child: Text(
                        "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  hintText: "Enter registered number",
                  hintStyle: GoogleFonts.montserrat(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  // labelText: 'Mobile Number',
                  // labelStyle: GoogleFonts.montserrat(
                  //     fontSize: 14, fontWeight: FontWeight.w500),
                  enabledBorder: OutlineInputBorder(
                    borderSide: _mobileController.text.length > 9
                        ? const BorderSide(
                            width: 2,
                            color: Colors.green,
                          )
                        : const BorderSide(
                            width: 2,
                            color: Colors.blue,
                          ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: _mobileController.text.length > 9
                        ? const BorderSide(
                            width: 2,
                            color: Colors.green,
                          )
                        : const BorderSide(
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
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    print(_mobileController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mobileController.text.length > 9
                        ? Colors.green
                        : Colors.blue,
                    elevation: 5,
                  ),
                  child: Text(
                    "Login",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
