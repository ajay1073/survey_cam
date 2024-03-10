import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_cam/list/userlist.dart';
import 'package:survey_cam/model/requestmodel.dart';
import 'package:http/http.dart' as http;

class RequestCard extends StatelessWidget {
  final RequestModel model;
  final BuildContext context;
  const RequestCard({super.key, required this.model, required this.context});

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
                                text: "Phone: ",
                              ),
                              TextSpan(
                                text: model.userPhone,
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
                                        ClipboardData(text: model.userPhone));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Phone Number copied to clipboard'),
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
                                text: "User-ID: ",
                              ),
                              TextSpan(
                                text: model.userID,
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
                                        ClipboardData(text: model.userID));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('User ID copied to clipboard'),
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
                        "Request Time: ${model.requestTime.toDate().day.toString().padLeft(2, '0')}/${model.requestTime.toDate().month.toString().padLeft(2, '0')}/${model.requestTime.toDate().year.toString()} ${model.requestTime.toDate().hour.toString().padLeft(2, '0')}:${model.requestTime.toDate().minute.toString().padLeft(2, '0')}:${model.requestTime.toDate().second.toString().padLeft(2, '0')}",
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
                        child: model.status == false
                            ? Text(
                                "Status: Incomplete",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: screenSize.height * 0.025,
                                    fontWeight: FontWeight.w500),
                              )
                            : Text(
                                "Status: Complete",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: screenSize.height * 0.025,
                                    fontWeight: FontWeight.w500),
                              )),
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
                      padding: EdgeInsets.only(right: screenSize.width * 0.035),
                      child: ElevatedButton(
                          onPressed: () async {
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
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => UserListPage(
                                        search: true,
                                        item: model.userPhone,
                                      )));
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
                                "Show User",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: screenSize.height * 0.025,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: screenSize.width * 0.035),
                      child: ElevatedButton(
                          onPressed: () async {
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
                              if (model.status == false) {
                                FirebaseFirestore.instance
                                    .collection("request")
                                    .doc(model.userID)
                                    .update({"status": true}).then((value) => {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content:
                                                      Text("User Updated"))),
                                        });
                              } else {
                                FirebaseFirestore.instance
                                    .collection("request")
                                    .doc(model.userID)
                                    .update({"status": false}).then((value) => {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content:
                                                      Text("User Updated"))),
                                        });
                              }
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
