import 'package:flutter/material.dart';
import 'package:survey_cam/useradd.dart';
import 'package:survey_cam/model/usermodel.dart';

class UserCard extends StatelessWidget {
  final UserModel model;
  final BuildContext context;
  const UserCard({Key? key, required this.model, required this.context});

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
                color: model.isActive == true
                    ? Colors.green[200]
                    : Colors.red[200]),
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
                          top: screenSize.height * 0.00625,
                          bottom: screenSize.height * 0.00625),
                      child: Text(
                        "Name: ${model.userName}",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.025,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Divider(
                      color:
                          model.isActive == true ? Colors.yellow : Colors.white,
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
                    Divider(
                      color:
                          model.isActive == true ? Colors.yellow : Colors.white,
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
                        "User-ID: ${model.userID}",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.025,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Divider(
                      color:
                          model.isActive == true ? Colors.yellow : Colors.white,
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
                        "Device-ID: ${model.deviceID}",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: screenSize.height * 0.025,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: model.isActive == true ? Colors.yellow : Colors.white,
                  endIndent: 10,
                  indent: 10,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: screenSize.width * 0.028),
                      child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.0138),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.symmetric(
                              vertical: screenSize.height * 0.0075,
                              horizontal: screenSize.width * 0.0194),
                          child: model.isAdmin == true
                              ? Text(
                                  "Admin : Yes",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenSize.height * 0.02,
                                      fontWeight: FontWeight.w500),
                                )
                              : Text(
                                  "Admin : No",
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserAddPage(model)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            elevation: 5,
                          ),
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenSize.height * 0.00625,
                                  horizontal: screenSize.width * 0.0138),
                              child: Text(
                                "Edit User",
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
