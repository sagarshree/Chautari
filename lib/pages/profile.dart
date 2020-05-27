import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/edit_profile.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;
  final func;

  Profile({this.profileId, this.func});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  String postOrientation = 'grid';
  Color listIconColor = Colors.grey;
  Color gridIconColor;
  bool isFollowing = false;
  int followersCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfilePosts();
    getFollowersCount();
    getFollowingCount();
    checkIfFollowing();
  }

  getFollowersCount() async {
    QuerySnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followersCount = doc.documents.length;
    });
  }

  getFollowingCount() async {
    QuerySnapshot doc = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = doc.documents.length;
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Flexible buildFollowUnfollowButton({String text, Function function}) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.only(top: 2.0),
        child: FlatButton(
            onPressed: function,
            child: Container(
              height: 35.0,
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isFollowing ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: isFollowing ? Colors.white : Colors.blue,
                border: Border.all(
                  color: isFollowing ? Colors.grey : Colors.blue,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
            )),
      ),
    );
  }

  Row buildButton(
      {String editProfileText,
      BuildContext parentContext,
      String logoutText,
      Function editProfileButtonFunction,
      Function logoutButtonFunction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 2.0),
          child: GestureDetector(
              onTap: editProfileButtonFunction,
              child: Container(
                width: MediaQuery.of(parentContext).size.width * 0.37,
                height: 35.0,
                child: Center(
                  child: Text(
                    editProfileText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.blueAccent, Colors.teal]),
                  borderRadius: BorderRadius.circular(15.0),
                ),
              )),
        ),
        SizedBox(
          width: MediaQuery.of(parentContext).size.width * 0.05,
        ),
        Container(
          padding: EdgeInsets.only(top: 2.0),
          child: GestureDetector(
              onTap: logoutButtonFunction,
              child: Container(
                width: MediaQuery.of(parentContext).size.width * 0.2,
                height: 35.0,
                child: Center(
                  child: Text(
                    logoutText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.blueAccent, Colors.teal]),
                  borderRadius: BorderRadius.circular(15.0),
                ),
              )),
        ),
      ],
    );
  }

  logoutAlert(parentContext, Function function) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            content: Text('Are you sure?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: function,
                child: Text('Yes'),
              )
            ],
          );
        });
  }

  logout(Function func) async {
    func();
    return Home();
  }

  buildProfileButton(BuildContext parentContext) {
    // viewing your own profile: should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        parentContext: parentContext,
        editProfileText: 'Edit Profile',
        editProfileButtonFunction: editProfile,
        logoutText: 'Logout',
        logoutButtonFunction: () => logoutAlert(context, widget.func),
      );
    } else if (isFollowing) {
      return buildFollowUnfollowButton(
        text: 'Unfollow',
        function: () => logoutAlert(context, handleUnfollow),
      );
    } else {
      return buildFollowUnfollowButton(
        text: 'Follow',
        function: handleFollow,
      );
    }
  }

  handleUnfollow() {
    setState(() {
      isFollowing = false;
    });

    //remove you from their followers collection
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // remove them from your following collection
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // delete from activityfeed

    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    setState(() {
      followersCount -= 1;
    });
    Navigator.pop(context);
  }

  handleFollow() {
    setState(() {
      isFollowing = true;
    });

    //add you to their followers collection
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});

    // add them to your following collection
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});

    // notify them about new follower by adding to activityfeed

    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser.username,
      'userId': currentUserId,
      'userProfileImage': currentUser.photoUrl,
      'timeStamp': timeStamp,
    });
    setState(() {
      followersCount += 1;
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocuments(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn('posts', postCount),
                            buildCountColumn('followers', followersCount),
                            buildCountColumn('following', followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(context),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  '@${user.username}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.bio,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Container buildNoPostsScreen() {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/no_content.svg',
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'No Posts',
              style: TextStyle(
                color: Colors.redAccent,
                fontFamily: 'Signatra',
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildNoPostsScreen();
    } else if (postOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(
          GridTile(
            child: PostTile(
              post: post,
            ),
          ),
        );
      });
      return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: gridTiles);
    } else if (postOrientation == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.grid_on,
            color: postOrientation == 'grid'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () => setOrientation('grid'),
        ),
        IconButton(
          icon: Icon(
            Icons.list,
            size: 35.0,
            color: postOrientation == 'list'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () => setOrientation('list'),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        title: 'Profile',
      ),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
