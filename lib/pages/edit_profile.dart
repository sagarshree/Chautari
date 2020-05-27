import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  File file;
  String photoUrl;
  bool isLoading = false;
  User user;
  bool _validBio = true;
  bool _validDisplayName = true;
  bool filePicked = false;
  bool isUploading = false;
  bool isSubmitButtonDisabled = false;
  bool _validUsername = true;

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
    usernameController.text = user.username;
    setState(() {
      isLoading = false;
    });
  }

  Container buildDisplayNameField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: displayNameController,
        decoration: InputDecoration(
            hintText: 'Update Name',
            border: OutlineInputBorder(),
            labelText: 'Display Name',
            errorText: _validDisplayName ? null : 'Display Name too short!!'),
      ),
    );
  }

  buildBioNameField() {
    return Container(
        child:
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
    ));
  }

  buildUsernameField() {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child:
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
          controller: usernameController,
          decoration: InputDecoration(
              hintText: 'Update username',
              border: OutlineInputBorder(),
              labelText: 'Username',
              errorText: _validUsername
                  ? null
                  : 'Username can\'t be less than 5 and greater than 25 characters!!'),
        ));
  }

  updateProfileData() async {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _validDisplayName = false
          : _validDisplayName = true;
      bioController.text.trim().length > 100
          ? _validBio = false
          : _validBio = true;
      (usernameController.text.trim().length < 5 &&
              usernameController.text.trim().length > 25)
          ? _validUsername = false
          : _validUsername = true;
    });

    if (_validBio && _validDisplayName) {
      setState(() {
        isUploading = true;
        isSubmitButtonDisabled = true;
      });

      userRef.document(widget.currentUserId).updateData({
        'displayName': displayNameController.text,
        'bio': bioController.text,
        'username': usernameController.text.trim(),
      });

      setState(() {
        isUploading = false;
      });
    }
    file = null;
    filePicked = false;

    Navigator.pop(context);
  }

  handleCameraPhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
    await compressImage();
    String photoUrl = await uploadImage(file);
    userRef.document(widget.currentUserId).updateData({
      'photoUrl': photoUrl,
    });
    setState(() {
      filePicked = true;
    });
  }

  handleGalleryPhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = file;
    });
    await compressImage();
    String photoUrl = await uploadImage(file);
    userRef.document(widget.currentUserId).updateData({
      'photoUrl': photoUrl,
    });
    setState(() {
      filePicked = true;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Update Image'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Camera'),
                onPressed: handleCameraPhoto,
              ),
              SimpleDialogOption(
                child: Text('From Gallery'),
                onPressed: handleGalleryPhoto,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedFile = File('$path/profile_pic.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedFile;
      print('file loaded');
    });
  }

  Future<String> uploadImage(File imageFile) async {
    StorageUploadTask uploadTask = storageRef
        .child('post_profile_pic_postId:${currentUser.id}.jpg')
        .putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  cancelButtonAction() {
    file = null;
    filePicked = false;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                isUploading ? linearProgress() : Text(''),
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: GestureDetector(
                          onTap: () => selectImage(context),
                          child: CircleAvatar(
                            backgroundImage: filePicked
                                ? FileImage(file)
                                : CachedNetworkImageProvider(user.photoUrl),
                            child: Icon(
                              Icons.photo_camera,
                              size: 40.0,
                            ),
                            radius: 50,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildUsernameField(),
                            buildDisplayNameField(),
                            buildBioNameField(),
                          ],
                        ),
                      ),
                      Container(
                        height: 50.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                          color: isSubmitButtonDisabled == false
                              ? Colors.teal
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: GestureDetector(
                          onTap: isSubmitButtonDisabled == false
                              ? updateProfileData
                              : null,
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
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        height: 50.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: GestureDetector(
                          onTap: cancelButtonAction,
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
