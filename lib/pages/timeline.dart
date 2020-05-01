import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

final userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    // createUser();
    updateUser();
    getUsers();
  }

  createUser() {
    userRef.document('sadsgdjgas').setData({
      'username': 'Manoj',
      'postCount': 0,
      'isAdmin': false,
    });
  }

  updateUser() {
    userRef.document('nC150cG9K2P2wkhanf3N').updateData({
      'username': 'Rupesh',
      'postCount': 0,
      'isAdmin': false,
    });
  }

  getUsers() async {
    final QuerySnapshot snapshot = await userRef.getDocuments();
    setState(() {
      users = snapshot.documents;
    });
  }

  // getUsersById() async {
  //   final String id = 'h2tcpe1jnOPs602iO5F2';
  //   final DocumentSnapshot doc = await userRef.document(id).get();
  //   print(doc.data);
  //   print(doc.documentID);
  //   print(doc.exists);
  // }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final List<Text> children = snapshot.data.documents
              .map((doc) => Text(doc['username']))
              .toList();
          return Container(
            child: ListView(
              children: children,
            ),
          );
        },
      ),
    );
  }
}
