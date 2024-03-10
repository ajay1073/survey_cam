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
  bool search = false;
  TextEditingController _searchController = TextEditingController();
  Widget _buildSearchField() {
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
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserListPage(
                    search: false,
                  )));
        },
      ),
      appBar: AppBar(
        title: search == false
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
            icon: Icon(search == false ? Icons.search : Icons.close),
            onPressed: () {
              setState(() {
                search = !search;
                if (!search) {
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
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("request")
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
