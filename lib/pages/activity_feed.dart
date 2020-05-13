import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getNotifications() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timeStamp', descending: true)
        .limit(50)
        .getDocuments();
    snapshot.documents.forEach((doc) {
      print('Activity feed item: ${doc.data}');
    });
    return snapshot.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Notifications'),
      body: Container(
        child: FutureBuilder(
          future: getNotifications(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return Center(child: Text('Notifications'));
          },
        ),
      ),
    );
  }
}

class ActivityFeedItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Activity Feed Item');
  }
}
