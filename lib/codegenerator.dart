import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mycam/userlist.dart';

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
          "Code Generator",
          style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: screenSize.height * 0.03125,
              fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => UserListPage()));
        },
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.025,
            horizontal: screenSize.width * 0.055),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Code Generator",
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenSize.height * 0.0375,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            SizedBox(
              height: screenSize.height * 0.025,
            ),
            Text("This code generator take the number given to user",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenSize.height * 0.01875,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
            SizedBox(
              height: screenSize.height * 0.025,
            ),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  codeController.text = value;
                });
                enterdnumber = int.parse(codeController.text);
              },
              controller: codeController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: screenSize.height * 0.0225,
              ),
              decoration: InputDecoration(
                labelText: "Generated Number",
                labelStyle: TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: screenSize.height * 0.0255,
                ),
                hintText: "Enter generated number",
                hintStyle: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenSize.height * 0.0175,
                    fontWeight: FontWeight.w500),
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
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.025,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  code = genrateCode(enterdnumber, 2.5);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          // contentPadding: EdgeInsets.symmetric(vertical: 100.0),
                          title: Text(
                            "Thanks for using Code Generator",
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenSize.height * 0.025,
                                fontWeight: FontWeight.w500),
                          ),
                          content: SizedBox(
                            height: screenSize.height * 0.25,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenSize.height * 0.02,
                                ),
                                Text(
                                  "For your entered number: ${codeController.text}",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.01875,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                                SizedBox(
                                  height: screenSize.height * 0.05,
                                ),
                                SelectableText.rich(TextSpan(children: [
                                  TextSpan(
                                    text: "The code is: ",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.022,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: code,
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: screenSize.height * 0.022,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue),
                                  )
                                ])),
                                SizedBox(
                                  height: screenSize.height * 0.05,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    "Okay",
                                    style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.025,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
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
                    "Genrate Code",
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: screenSize.height * 0.025,
                      fontWeight: FontWeight.w500,
                    ),
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
