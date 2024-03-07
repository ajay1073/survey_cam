import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:survey_cam/list/requestlist.dart';
import 'package:survey_cam/list/userlist.dart';

class CodeGeneratorScreen extends StatefulWidget {
  const CodeGeneratorScreen({super.key});

  @override
  State<CodeGeneratorScreen> createState() => _CodeGeneratorScreenState();
}

class _CodeGeneratorScreenState extends State<CodeGeneratorScreen> {
  TextEditingController codeController = TextEditingController();
  late String code;
  int enterdnumber = 0;

  genrateCode(int n, double a) {
    return ((pow(n, 2) + 3 * a) / 2 - sqrt(a + n / 2)).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "User Info",
          style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: screenSize.height * 0.03125,
              fontWeight: FontWeight.w500),
        ),
      ),
      // floatingActionButton: Container(
      //     decoration: BoxDecoration(
      //       border: Border.all(
      //         color: Colors.white,
      //         width: screenSize.width * 0.006,
      //       ),
      //       borderRadius: BorderRadius.circular(screenSize.height *
      //           0.05), // Adjust the value based on your preference
      //     ),
      //     child: SpeedDial(
      //         // childMargin: EdgeInsets.all(10),
      //         icon: (Icons.menu_book),
      //         iconTheme: const IconThemeData(color: Colors.white),
      //         backgroundColor: Colors.black,
      //         overlayColor: Colors.black,
      //         overlayOpacity: 0.4,
      //         childrenButtonSize:
      //             Size(screenSize.width * 0.15, screenSize.height * 0.1),
      //         children: [
      //           SpeedDialChild(
      //             shape: const CircleBorder(),
      //             child: const Icon(Icons.person_2_outlined),
      //             label: "User List",
      //             labelStyle: TextStyle(
      //                 fontFamily: 'Montserrat',
      //                 fontSize: screenSize.height * 0.022,
      //                 fontWeight: FontWeight.w500),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (context) => const UserListPage()),
      //               );
      //             },
      //           ),
      //           SpeedDialChild(
      //             shape: const CircleBorder(),
      //             child: const Icon(Icons.person_remove_alt_1_outlined),
      //             label: "Request List",
      //             labelStyle: TextStyle(
      //                 fontFamily: 'Montserrat',
      //                 fontSize: screenSize.height * 0.022,
      //                 fontWeight: FontWeight.w500),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (context) => const RequestList()),
      //               );
      //             },
      //           ),
      //         ])),
      body: Center(
          child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.025,
            horizontal: screenSize.width * 0.055),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text("Code Generator",
            //     style: TextStyle(
            //         fontFamily: "Montserrat",
            //         fontSize: screenSize.height * 0.0375,
            //         fontWeight: FontWeight.w600,
            //         color: Colors.black)),
            // SizedBox(
            //   height: screenSize.height * 0.025,
            // ),
            // Text("This code generator take the number given to user",
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //         fontFamily: "Montserrat",
            //         fontSize: screenSize.height * 0.01875,
            //         fontWeight: FontWeight.w600,
            //         color: Colors.grey)),
            // SizedBox(
            //   height: screenSize.height * 0.025,
            // ),
            // TextFormField(
            //   onChanged: (value) {
            //     setState(() {
            //       codeController.text = value;
            //     });
            //     enterdnumber = int.parse(codeController.text);
            //   },
            //   controller: codeController,
            //   keyboardType: TextInputType.phone,
            //   style: TextStyle(
            //     fontFamily: "Montserrat",
            //     fontSize: screenSize.height * 0.0225,
            //   ),
            //   decoration: InputDecoration(
            //     labelText: "Generated Number",
            //     labelStyle: TextStyle(
            //       fontFamily: "Montserrat",
            //       fontSize: screenSize.height * 0.0255,
            //     ),
            //     hintText: "Enter generated number",
            //     hintStyle: TextStyle(
            //         fontFamily: "Montserrat",
            //         fontSize: screenSize.height * 0.0175,
            //         fontWeight: FontWeight.w500),
            //     enabledBorder: const OutlineInputBorder(
            //       borderSide: BorderSide(
            //         width: 2,
            //         color: Colors.blue,
            //       ),
            //     ),
            //     focusedBorder: const OutlineInputBorder(
            //       borderSide: BorderSide(
            //         width: 2,
            //         color: Colors.blue,
            //       ),
            //     ),
            //   ),
            // ),
            // SizedBox(
            //   height: screenSize.height * 0.025,
            // ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserListPage()),
                  );
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
                    "User List",
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenSize.height * 0.025,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.025,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RequestList()),
                  );
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
                    "Request List",
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenSize.height * 0.025,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
