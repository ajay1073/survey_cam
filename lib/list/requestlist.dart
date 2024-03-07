import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:survey_cam/card/requestcard.dart';
import 'package:survey_cam/list/userlist.dart';
import 'package:survey_cam/model/requestmodel.dart';

class RequestList extends StatefulWidget {
  const RequestList({super.key});

  @override
  State<RequestList> createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        label: Text("User List",
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: screenSize.height * 0.022,
                fontWeight: FontWeight.w500,
                color: Colors.white)),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => UserListPage()));
        },
      ),
      appBar: AppBar(
        title: Text(
          "Request List",
          style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: screenSize.height * 0.03125,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("request")
                    // .orderBy(field)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text(
                      "No User...",
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenSize.height * 0.02875,
                          fontWeight: FontWeight.w600,
                          color: Colors.red),
                    );
                  } else {
                    return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return RequestCard(
                              model: RequestModel.fromfirestore(
                                  snapshot.data!.docs[index]),
                              context: context);
                        });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
