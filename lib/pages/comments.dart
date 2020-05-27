import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });
  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaUrl: this.postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  Color commentIconColor = Colors.grey;
  bool isCommentEmpty = true;
  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .document(postId)
          .collection('comments')
          .orderBy(
            'timeStamp',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          comments.add((Comment.fromDocument(doc)));
        });
        return ListView(
          shrinkWrap: true,
          reverse: true,
          children: comments,
        );
      },
    );
  }

  addComment() {
    commentsRef.document(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentController.text,
      'timeStamp': timeStamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id,
    });
    bool isNotPostOwner = postOwnerId != currentUser.id;
    // if (isNotPostOwner) {
    activityFeedRef.document(postOwnerId).collection('feedItems').add({
      'type': 'comment',
      'commentData': commentController.text,
      'username': currentUser.username,
      'userId': currentUser.id,
      'userProfileImage': currentUser.photoUrl,
      'postId': postId,
      'mediaUrl': postMediaUrl,
      'timeStamp': timeStamp,
    });
    // }

    if (!isCommentEmpty) {
      SnackBar snackBar = SnackBar(
        duration: Duration(milliseconds: 500),
        content: Text(
          'Comment posted!!',
        ),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
    commentController.clear();
    setState(() {
      isCommentEmpty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, title: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          SafeArea(
            child: ListTile(
              title: TextFormField(
                onChanged: (val) {
                  if (val.trim().isEmpty) {
                    setState(() {
                      isCommentEmpty = true;
                    });
                  } else {
                    setState(() {
                      isCommentEmpty = false;
                    });
                  }
                },
                controller: commentController,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: isCommentEmpty == false ? addComment : null,
                      icon: Icon(
                        Icons.send,
                        color: isCommentEmpty == true
                            ? Colors.grey
                            : Colors.blueAccent,
                        size: 30.0,
                      ),
                    ),
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    fillColor: Colors.grey),
              ),
              // trailing: IconButton(
              //   onPressed: addComment,
              //   icon: Icon(
              //     Icons.send,
              //     color: Colors.blueAccent,
              //     size: 30.0,
              //   ),
              // ),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timeStamp;

  Comment({
    this.username,
    this.comment,
    this.avatarUrl,
    this.timeStamp,
    this.userId,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timeStamp: doc['timeStamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
            backgroundColor: Colors.grey,
            radius: 28.0,
          ),
          title: Text(comment),
          subtitle: Text(timeago.format(timeStamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
