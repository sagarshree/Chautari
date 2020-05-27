import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import '../pages/home.dart';

class ShowPost extends StatefulWidget {
  final Post post;
  ShowPost({this.post});
  @override
  _ShowPostState createState() => _ShowPostState();
}

class _ShowPostState extends State<ShowPost> {
  List<Post> posts;

  @override
  void initState() {
    super.initState();
    showImage();
  }

  showImage() async {
    QuerySnapshot snapshot = await postsRef
        .document(widget.post.ownerId)
        .collection('userPosts')
        .where('postId', isEqualTo: widget.post.postId)
        .getDocuments();

    setState(() {
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });

    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Post', removeBackButton: false),
      body: SingleChildScrollView(
        child: posts == null
            ? circularProgress()
            : Column(
                children: posts,
              ),
      ),
    );
  }
}
