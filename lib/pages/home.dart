import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/unauth_landscape.dart';
import 'package:fluttershare/widgets/unauth_portrait.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');

final timeStamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  int pageIndex = 0;

  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      signInHandler(account);
    }, onError: (err) {
      print('Error signing in!: $err');
    });

    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      signInHandler(account);
    }).catchError((err) {
      print('Error signing in!: $err');
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  signInHandler(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
      print('User Signed in!: $account');
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    //  1) check if user exists in user collection in database(acc to their id)

    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesnot exist, take them to the signup page
      final username =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return CreateAccount();
      }));
      // } else {
      //   Navigator.push(context, MaterialPageRoute(builder: (context) {
      //     Timeline();
      //   }));
      // }

      // 3) get username from signup page and use it to make new user document in document collection
      userRef.document(user.id).setData({
        'id': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timeStamp': timeStamp,
      });
      doc = await userRef.document(user.id).get();
    }
    currentUser = User.fromDocuments(doc);
    print(currentUser);
    print(currentUser.username);
  }

  logIn() {
    googleSignIn.signIn();
  }

  logOut() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.jumpToPage(pageIndex);
    // .animateToPage(pageIndex,
    //     duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          // Timeline(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Authenticated'),
              RaisedButton(
                child: Text('Logout'),
                onPressed: logOut,
              )
            ],
          ),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(
            profileId: currentUser?.id,
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 35.0,
          )),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: <Widget>[
    //     Text('Authenticated'),
    //     RaisedButton(
    //       child: Text('Logout'),
    //       onPressed: logOut,
    //     )
    //   ],
    // );
  }

  Widget buildUnAuthScreen() {
    final orientation = MediaQuery.of(context).orientation;

    return orientation == Orientation.portrait
        ? UnauthPortrait(func: logIn)
        : UnauthLandscape(func: logIn);
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
