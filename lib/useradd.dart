import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:survey_cam/model/usermodel.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class UserAddPage extends StatefulWidget {
  UserModel? model;
  UserAddPage(
    this.model,
  );

  @override
  State<UserAddPage> createState() => _UserAddPageState();
}

class _UserAddPageState extends State<UserAddPage> {
  bool isAdmin = false;
  bool isActive = false;
  final _formkey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController userMobileController = TextEditingController();
  TextEditingController deviceIdController = TextEditingController();
  bool status = false;
  String? phone;
  String? deviceid;
  String? query;
  String? userID;
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

  checkUser() {
    if (widget.model != null) {
      userNameController.text = widget.model!.userName;
      userMobileController.text = widget.model!.userPhone;
      deviceIdController.text = widget.model!.deviceID;
      isActive = widget.model!.isActive;
      isAdmin = widget.model!.isAdmin;
    } else {
      print("New");
    }
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

  // checkRequest() {
  //   if (widget.model2 != null) {
  //     phone = widget.model2!.userPhone;
  //     deviceid = widget.model2!.deviceID;
  //     query = widget.model2!.query;
  //     userID = widget.model2!.userID;
  //     status = widget.model2!.status;
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: widget.model != null
            ? Text(
                "Edit User",
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenSize.height * 0.03125,
                    fontWeight: FontWeight.w500),
              )
            : Text(
                "Add User",
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenSize.height * 0.03125,
                    fontWeight: FontWeight.w500),
              ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: screenSize.height * 0.02,
              horizontal: screenSize.width * 0.028),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenSize.height * 0.0125,
                  ),
                  TextFormField(
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenSize.height * 0.0225,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                    controller: userNameController,
                    onChanged: (value) {
                      setState(() {
                        userNameController.text = value;
                      });
                    },
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
                  widget.model == null
                      ? TextFormField(
                          onChanged: (value) {
                            setState(() {
                              userMobileController.text = value;
                            });
                          },
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenSize.height * 0.0225,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                          keyboardType: TextInputType.phone,
                          controller: userMobileController,
                          decoration: InputDecoration(
                            suffixIcon: userMobileController.text.length > 9
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
                                      countryListTheme:
                                          const CountryListThemeData(
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
                                            fontSize:
                                                screenSize.height * 0.0225,
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
                            focusedErrorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.length < 13 || value.isEmpty) {
                              return "Please Enter valid Phone Number";
                            }
                            return null;
                          },
                        )
                      : TextFormField(
                          onChanged: (value) {
                            setState(() {
                              userMobileController.text = value;
                            });
                          },
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenSize.height * 0.0225,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                          keyboardType: TextInputType.phone,
                          controller: userMobileController,
                          decoration: InputDecoration(
                            suffixIcon: const Icon(
                              Icons.phone,
                              color: Colors.black,
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
                    height: screenSize.height * 0.0125,
                  ),
                  TextFormField(
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenSize.height * 0.0225,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                    controller: deviceIdController,
                    onChanged: (value) {
                      setState(() {
                        deviceIdController.text = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontFamily: "Montserrat",
                          fontSize: screenSize.height * 0.025,
                          fontWeight: FontWeight.w500),
                      alignLabelWithHint: true,
                      labelText: "Device ID",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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
                    height: screenSize.height * 0.0125,
                  ),
                  Container(
                    height: screenSize.height * 0.075,
                    padding: EdgeInsets.only(
                        left: screenSize.width * 0.028,
                        right: screenSize.width * 0.028,
                        top: screenSize.height * 0.0125,
                        bottom: screenSize.height * 0.0125),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.blue, width: 2)),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            // flex: 1,
                            child: Text(
                          "Admin:",
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenSize.height * 0.025,
                              fontWeight: FontWeight.w500),
                        )),
                        adminTypeWidget()
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenSize.height * 0.0125,
                  ),
                  Container(
                    height: screenSize.height * 0.075,
                    padding: EdgeInsets.only(
                        left: screenSize.width * 0.028,
                        right: screenSize.width * 0.028,
                        top: screenSize.height * 0.0125,
                        bottom: screenSize.height * 0.0125),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.blue, width: 2)),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            // flex: 1,
                            child: Text(
                          "Active:",
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenSize.height * 0.025,
                              fontWeight: FontWeight.w500),
                        )),
                        activeTypeWidget()
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenSize.height * 0.035,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_formkey.currentState?.validate() == true) {
                            bool isConnected =
                                await checkInternetConnectivity();
                            if (isConnected == false) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "No internet connection. Please try again."),
                                ),
                              );
                            } else {
                              if (widget.model == null) {
                                var uid = const Uuid();
                                String userId = uid.v4();
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(userId)
                                    .set({
                                  "name": userNameController.text,
                                  "phone": selectedCountry.phoneCode +
                                      userMobileController.text,
                                  "user_id": userId,
                                  "is_active": isActive,
                                  "is_admin": isAdmin,
                                  "device_id": deviceIdController.text,
                                  "last_used": DateTime.now()
                                }).then((value) => {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text("User Added"))),
                                          Navigator.pop(context),
                                        });
                              } else {
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(widget.model!.userID)
                                    .update({
                                  "name": userNameController.text,
                                  "phone": userMobileController.text,
                                  "is_active": isActive,
                                  "is_admin": isAdmin,
                                  "device_id": deviceIdController.text
                                }).then((value) => {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content:
                                                      Text("User Updated"))),
                                          Navigator.pop(context),
                                        });
                              }
                              setState(() {
                                widget.model = null;
                              });
                              userMobileController.clear();
                              userNameController.clear();
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
                            child: widget.model == null
                                ? Text(
                                    "Add User",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.025,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  )
                                : Text(
                                    "Edit User",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.025,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  )),
                      ),
                      // widget.model != null
                      //     ? SizedBox(
                      //         width: screenSize.width * 0.04166,
                      //       )
                      //     : Container(),
                      // widget.model != null
                      //     ? ElevatedButton(
                      //         onPressed: () {
                      //           FirebaseFirestore.instance
                      //               .collection("users")
                      //               .doc(widget.model!.userID)
                      //               .delete()
                      //               .then(
                      //                 (value) => ScaffoldMessenger.of(context)
                      //                     .showSnackBar(const SnackBar(
                      //                         content: Text("User Deleted"))),
                      //                 // Navigator.pop(context)
                      //               );
                      //         },
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: Colors.red,
                      //           elevation: 5,
                      //         ),
                      //         child: Text(
                      //           "Delete",
                      //           style: GoogleFonts.montserrat(
                      //             fontSize: 20,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //         ),
                      //       )
                      //     : Container(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void admintoggleButton() {
    setState(() {
      isAdmin = !isAdmin;
    });
  }

  Widget adminTypeWidget() {
    return GestureDetector(
      onTap: admintoggleButton,
      child: Container(
        // padding: EdgeInsets.all(5),
        width: 100,
        height: 25,
        decoration: BoxDecoration(
          // color: Colors.cyanAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            isAdmin == true ? 'Yes' : "No",
            style: const TextStyle(
                fontFamily: "Montserrat",
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void activetoggleButton() {
    setState(() {
      isActive = !isActive;
    });
  }

  Widget activeTypeWidget() {
    return GestureDetector(
      onTap: activetoggleButton,
      child: Container(
        // padding: EdgeInsets.all(5),
        width: 100,
        height: 25,
        decoration: BoxDecoration(
          // color: Colors.cyanAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            isActive == true ? 'Yes' : "No",
            style: const TextStyle(
                fontFamily: "Montserrat",
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
