import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mycam/useradd.dart';
import 'package:mycam/usercard.dart';
import 'package:mycam/usermodel.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => UserAddPage(null)));
        },
      ),
      appBar: AppBar(
        title: Text(
          "User List",
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
                    .collection("users")
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
                          return UserCard(
                              model: UserModel.fromfirestore(
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
