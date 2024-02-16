import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:survey_cam/useradd.dart';
import 'package:survey_cam/usermodel.dart';

class UserCard extends StatelessWidget {
  final UserModel model;
  final BuildContext context;
  const UserCard({Key? key, required this.model, required this.context});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        margin: const EdgeInsets.all(10),
        child: Container(
            decoration: BoxDecoration(
                color: model.isActive == true
                    ? Colors.green[200]
                    : Colors.red[200]),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          model.userName,
                          style: GoogleFonts.montserrat(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        child: Text(
                          model.userPhone.toString(),
                          style: GoogleFonts.montserrat(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  endIndent: 10,
                  indent: 10,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 7),
                        child: model.isAdmin == true
                            ? Text(
                                "Admin : Yes",
                                style: GoogleFonts.actor(fontSize: 16),
                              )
                            : Text(
                                "Admin : No",
                                style: GoogleFonts.actor(fontSize: 16),
                              )),
                    ElevatedButton(
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
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Edit User",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            )))
                  ],
                ),
              ],
            )));
  }
}
