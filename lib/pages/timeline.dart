import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

final userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts = [];
  final String profileId = currentUser?.id;
  bool isLoading = false;
  List<String> followingList = [];
  // bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .getDocuments();

    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  getTimeline() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await timelineRef
        .document(profileId)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
      isLoading = false;
    });
  }

  buildTimeline() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return StreamBuilder(
        stream: userRef.orderBy('timeStamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> userResults = [];
          snapshot.data.documents.forEach((doc) {
            User user = User.fromDocuments(doc);
            final bool isAuthUser = currentUser.id == user.id;
            final bool isFollowing = followingList.contains(user.id);
            if (isAuthUser) {
              return;
            } else if (isFollowing) {
              return;
            } else {
              UserResult userResult = UserResult(user: user);
              userResults.add(userResult);
            }
          });
          return SingleChildScrollView(
            child: Container(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                child: Column(
                  children: <Widget>[
                    Container(
                      // padding: EdgeInsets.all(12.0),
                      height: 80.0,
                      child: Card(
                        elevation: 6.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.person_add,
                              color: Theme.of(context).primaryColor,
                              size: 30.0,
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              'Let\'s make some friends!!',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 30.0),
                            )
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: userResults,
                    )
                  ],
                )),
          );
        },
      );
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(context),
        body: RefreshIndicator(
          onRefresh: () => getTimeline(),
          child: buildTimeline(),
        ));
  }
}
