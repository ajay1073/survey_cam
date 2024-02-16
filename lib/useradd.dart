import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:survey_cam/usermodel.dart';
import 'package:uuid/uuid.dart';

class UserAddPage extends StatefulWidget {
  UserModel? model;
  UserAddPage(this.model);

  @override
  State<UserAddPage> createState() => _UserAddPageState();
}

class _UserAddPageState extends State<UserAddPage> {
  bool isAdmin = false;
  bool isActive = false;
  final _formkey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController userMobileController = TextEditingController();
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
      isActive = widget.model!.isActive;
      isAdmin = widget.model!.isAdmin;
    } else {
      print("New");
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add User"),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: userNameController,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
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
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        userMobileController.text = value;
                      });
                    },
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
                        padding: const EdgeInsets.all(8),
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
                      labelStyle: const TextStyle(color: Colors.black),
                      alignLabelWithHint: true,
                      labelText: "User Phone",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: userMobileController.text.length > 9
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
                        borderSide: userMobileController.text.length > 9
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
                    validator: (value) {
                      if (value!.length < 10 || value.isEmpty) {
                        return "Please Enter valid Phone Number";
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.purple, width: 2)),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                              // flex: 1,
                              child: Text(
                            "Admin:",
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                          adminTypeWidget()
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.purple, width: 2)),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                              // flex: 1,
                              child: Text(
                            "Active:",
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                          activeTypeWidget()
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_formkey.currentState?.validate() == true) {
                            if (widget.model == null) {
                              var uid = const Uuid();
                              String userId = uid.v4();
                              FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(userId)
                                  .set({
                                "name": userNameController.text,
                                "phone": userMobileController.text,
                                "user_id": userId,
                                "is_active": isActive,
                                "is_admin": isAdmin,
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
                              }).then((value) => {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text("User Updated"))),
                                        Navigator.pop(context),
                                      });
                            }
                            setState(() {
                              widget.model = null;
                            });
                            userMobileController.clear();
                            userNameController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          elevation: 5,
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: widget.model == null
                                ? Text(
                                    "Add User",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : Text(
                                    "Edit User",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                      ),
                      widget.model != null
                          ? const SizedBox(
                              width: 15,
                            )
                          : Container(),
                      widget.model != null
                          ? ElevatedButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(widget.model!.userID)
                                    .delete()
                                    .then(
                                      (value) => ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text("User Deleted"))),
                                      // Navigator.pop(context)
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                elevation: 5,
                              ),
                              child: Text(
                                "Delete",
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : Container(),
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
            style: GoogleFonts.montserrat(
              // color: Colors.b,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
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
            style: GoogleFonts.montserrat(
              // color: Colors.b,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
