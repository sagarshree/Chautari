import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _validBio = true;
  bool _validDisplayName = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.currentUserId).get();
    user = User.fromDocuments(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Container buildDisplayNameField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Padding(
          //   padding: EdgeInsets.only(top: 12),
          //   child: Text(
          //     'DisplayName',
          //     style: TextStyle(
          //       color: Colors.grey,
          //     ),
          //   ),
          // ),
          TextField(
            controller: displayNameController,
            decoration: InputDecoration(
                hintText: 'Update Name',
                border: OutlineInputBorder(),
                labelText: 'Display Name',
                errorText:
                    _validDisplayName ? null : 'Display Name too short!!'),
          )
        ],
      ),
    );
  }

  buildBioNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Padding(
        //   padding: EdgeInsets.only(top: 12),
        //   child: Text(
        //     'Bio',
        //     style: TextStyle(
        //       color: Colors.grey,
        //     ),
        //   ),
        // ),
        TextFormField(
          controller: bioController,
          decoration: InputDecoration(
              hintText: 'Update Bio',
              border: OutlineInputBorder(),
              labelText: 'Bio',
              errorText: _validBio ? null : 'Bio too long!!'),
        )
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _validDisplayName = false
          : _validDisplayName = true;
      bioController.text.trim().length > 100
          ? _validBio = false
          : _validBio = true;
    });
    if (_validBio && _validDisplayName) {
      userRef.document(widget.currentUserId).updateData({
        'displayName': displayNameController.text,
        'bio': bioController.text,
      });
      SnackBar snackBar = SnackBar(
        content: Text('Profile Updated'),
      );

      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
              color: Colors.green,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                          radius: 50,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildDisplayNameField(),
                            buildBioNameField(),
                          ],
                        ),
                      ),
                      Container(
                        height: 50.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: GestureDetector(
                          onTap: updateProfileData,
                          child: Center(
                            child: Text(
                              'Update Profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.0),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
