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
  @override
  void initState() {
    super.initState();
    getUsersById();
  }

  // getUsers() {
  //   userRef.getDocuments().then((QuerySnapshot snapshot) {
  //     snapshot.documents.forEach((DocumentSnapshot doc) {
  //       print(doc.data);
  //       print(doc.documentID);
  //       print(doc.exists);
  //     });
  //   });
  // }

  getUsersById() {
    final String id = 'xjPeHPNeSIHSKuIRZpBJ';
    userRef.document(id).get().then((DocumentSnapshot doc) {
      print(doc.data);
      print(doc.documentID);
      print(doc.exists);
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context),
      body: circularProgress(),
    );
  }
}
