import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_cam/list/userlist.dart';
import 'package:survey_cam/model/requestmodel.dart';

class RequestCard extends StatelessWidget {
  final RequestModel model;
  final BuildContext context;
  const RequestCard({super.key, required this.model, required this.context});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.028,
            vertical: screenSize.height * 0.0125),
        child: Container(
            decoration: BoxDecoration(
                color: model.status == false
                    ? Colors.red[200]
                    : Colors.green[200]),
            padding: EdgeInsets.symmetric(
                vertical: screenSize.height * 0.01,
                horizontal: screenSize.width * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenSize.width * 0.028,
                        right: screenSize.width * 0.028,
                      ),
                      child: Text(
                        "Query: ${model.query}",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.025,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Divider(
                      color: Colors.white,
                      endIndent: 10,
                      indent: 10,
                      thickness: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: screenSize.width * 0.028,
                          right: screenSize.width * 0.028,
                          top: screenSize.height * 0.00625,
                          bottom: screenSize.height * 0.00625),
                      child: Text(
                        "User-ID: ${model.userID}",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.025,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Divider(
                      color: Colors.white,
                      endIndent: 10,
                      indent: 10,
                      thickness: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenSize.width * 0.028,
                        right: screenSize.width * 0.028,
                      ),
                      child: Text(
                        "Phone: ${model.userPhone}",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.025,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Divider(
                      color: Colors.white,
                      endIndent: 10,
                      indent: 10,
                      thickness: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenSize.width * 0.028,
                        right: screenSize.width * 0.028,
                      ),
                      child: Text(
                        "Query: ${model.query}",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.025,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Divider(
                      color: Colors.white,
                      endIndent: 10,
                      indent: 10,
                      thickness: 1,
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                          left: screenSize.width * 0.028,
                          right: screenSize.width * 0.028,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenSize.height * 0.025,
                              fontWeight: FontWeight.w500,
                              color: Colors
                                  .black, // Set the color according to your design
                            ),
                            children: [
                              const TextSpan(
                                text: "Device: ",
                              ),
                              TextSpan(
                                text: model.deviceID,
                                style: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: screenSize.height * 0.025,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Colors.black, // Optional: add underline
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Clipboard.setData(
                                        ClipboardData(text: model.deviceID));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Device ID copied to clipboard'),
                                      ),
                                    );
                                    // Handle the tap on the selectable text
                                    print('Selectable text tapped');
                                  },
                              ),
                            ],
                          ),
                        )),
                    const Divider(
                      color: Colors.white,
                      endIndent: 10,
                      indent: 10,
                      thickness: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenSize.width * 0.028,
                        right: screenSize.width * 0.028,
                      ),
                      child: Text(
                        "Request Time: ${model.requestTime.toDate()}",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.025,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.white,
                  endIndent: 10,
                  indent: 10,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: screenSize.width * 0.00),
                      child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.0138),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.symmetric(
                              vertical: screenSize.height * 0.0075,
                              horizontal: screenSize.width * 0.0194),
                          child: model.status == false
                              ? Text(
                                  "Status: Incomplete",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.02,
                                      fontWeight: FontWeight.w500),
                                )
                              : Text(
                                  "Status : Complete",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.02,
                                      fontWeight: FontWeight.w500),
                                )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: screenSize.width * 0.035),
                      child: ElevatedButton(
                          onPressed: () {
                            if (model.status == false) {
                              FirebaseFirestore.instance
                                  .collection("request")
                                  .doc(model.userID)
                                  .update({"status": true}).then((value) => {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text("User Updated"))),
                                      });
                            } else {
                              FirebaseFirestore.instance
                                  .collection("request")
                                  .doc(model.userID)
                                  .update({"status": false}).then((value) => {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text("User Updated"))),
                                      });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            elevation: 5,
                          ),
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: screenSize.height * 0.00625,
                              ),
                              child: Text(
                                "Change",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: screenSize.height * 0.025,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ))),
                    )
                  ],
                ),
              ],
            )));
  }
}
