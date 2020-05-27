import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/show_post.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/post.dart';
import '../pages/home.dart';

class PostTile extends StatefulWidget {
  final Post post;

  PostTile({
    this.post,
  });

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  List<Post> posts = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ShowPost(post: widget.post);
      })),
      child: cachedNetworkImage(widget.post.mediaUrl),
    );
  }
}
