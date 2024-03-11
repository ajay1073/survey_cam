import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:survey_cam/useradd.dart';
import 'package:survey_cam/card/usercard.dart';
import 'package:survey_cam/model/usermodel.dart';

class UserListPage extends StatefulWidget {
  bool search;
  String? item;
  UserListPage({super.key, required this.search, this.item});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  TextEditingController _searchController = TextEditingController();
  Widget _buildSearchField() {
    if (widget.item != null) {
      _searchController.text = widget.item!;
    }
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        hintText: 'Search',
        border: InputBorder.none,
      ),
      onChanged: (value) {
        _searchController.text = value;
        print(_searchController.text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => UserAddPage(null)));
        },
      ),
      appBar: AppBar(
        title: widget.search == false
            ? Text(
                "User List",
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenSize.height * 0.03125,
                    fontWeight: FontWeight.w500),
              )
            : _buildSearchField(),
        actions: [
          IconButton(
            icon: Icon(widget.search == false ? Icons.search : Icons.close),
            onPressed: () {
              setState(() {
                widget.search = !widget.search;
                if (!widget.search) {
                  _searchController.clear();
                  // Reset search results or hide them if needed
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: _searchController.text == ""
                  ? StreamBuilder<QuerySnapshot>(
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
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .where("phone",
                              isGreaterThanOrEqualTo: _searchController.text)
                          .where("phone",
                              isLessThan: '${_searchController.text}z')
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
