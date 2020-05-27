import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/fb_auth_page.dart';
import 'package:fluttershare/pages/login_page.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final activityFeedRef = Firestore.instance.collection('feed');
final timelineRef = Firestore.instance.collection('timeline');

final timeStamp = DateTime.now();
User currentUser;
bool googleAuth = false;
bool facebookAuth = false;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  int pageIndex = 0;
  PageController pageController;
  String _fbtoken;
  FirebaseUser userData;
  String fbUserId;
  bool goToTimeline = false;
  bool goToLoginPage = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen(
        (GoogleSignInAccount account) async {
      await googleSignInHandler(account);
    }, onError: (err) {
      print('Error signing in!: $err');
    });

    googleSignIn.signInSilently(suppressErrors: false).then((account) async {
      await googleSignInHandler(account);
    }).catchError((err) {
      print('Error signing in!: $err');
    });
    _fbCheckIfIsLogged();
    isLoading = false;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  googleSignInHandler(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      print('User Signed in!: $account');

      configurePushNotifications();
    } else {
      setState(() {
        googleAuth = false;
      });
    }
  }

  _fbCheckIfIsLogged() async {
    final AccessToken accessToken = await FacebookAuth.instance.isLogged;
    if (accessToken != null) {
      print("is Logged");
      print(accessToken.token);

      // now you can call to  FacebookAuth.instance.getUserData();
      await fbLogin();

      // print('userdayta is${userInfo['id']}');
      print('facebookuser id :$fbUserId');
      // final userData = await FacebookAuth.instance.getUserData(fields:"email,birthday");
      _fbtoken = accessToken.token;
    } else {
      setState(() {
        facebookAuth = false;
      });
    }
  }

  // _printCredentials(FacebookLoginResult result) {
  //   _fbtoken = result.accessToken.token;
  //   print("userId: ${result.accessToken.userId}");
  //   print("token: $_fbtoken");
  //   print("expires: ${result.accessToken.expires}");
  //   print("grantedPermission: ${result.accessToken.permissions}");
  //   print("declinedPermissions: ${result.accessToken.declinedPermissions}");
  //   print("photoUrl: ${result.accessToken}");
  // }

  Future<void> fbLogin() async {
    try {
      var facebookLogin = FacebookLogin();
      var result = await facebookLogin.logIn(['email']);
      if (result.status == FacebookLoginStatus.loggedIn) {
        setState(() {
          _fbtoken = result.accessToken.token;
        });
        // _printCredentials(result);
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: _fbtoken,
        );
        final FirebaseUser user =
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        setState(() {
          fbUserId = result.accessToken.userId;

          userData = user;
        });
        await createUserInFirestoreFacebook();
        configurePushNotifications();

        print('Signed In: $user');
      } else {
        setState(() {
          facebookAuth = false;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  fbLogOut() async {
    await FacebookAuth.instance.logOut();
    await _auth.signOut();

    _fbtoken = null;
    setState(() {
      facebookAuth = false;
    });
    Navigator.pop(context);
    return LoginPage();
  }

  configurePushNotifications() {
    // final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) {
      getIOSPermission();
    }
    _firebaseMessaging.getToken().then((token) {
      print('Token received: $token');
      usersRef.document(currentUser.id).updateData({
        'androidNotificationToken': token,
      });

      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('Message is : $message');
          final String recipientId = message['data']['recipient'];
          final String body = message['notification']['body'];
          print('body is: $body');
          print('id is: $recipientId');

          if (recipientId == currentUser.id) {
            print('Notification Shown');
            print(body);
            print(recipientId);
            SnackBar snackbar = SnackBar(
              content: Text(
                body,
                overflow: TextOverflow.ellipsis,
              ),
            );
            _scaffoldKey.currentState.showSnackBar(snackbar);
          } else {
            print('Notification not shown');
          }
        },
        onResume: (Map<String, dynamic> message) async {},
        onLaunch: (Map<String, dynamic> message) async {},
      );
    });
  }

  getIOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(
        alert: true,
        badge: true,
        sound: true,
      ),
    );
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print('Settings registered: $settings');
    });
  }

  createUserInFirestore() async {
    //  1) check if user exists in user collection in database(acc to their id)

    final FirebaseUser user = await _auth.currentUser();

    DocumentSnapshot doc = await userRef.document(user.uid).get();

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
      userRef.document(user.uid).setData({
        'id': user.uid,
        'username':
            username == null ? user.displayName.trim().toLowerCase() : username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timeStamp': timeStamp,
      });
      doc = await userRef.document(user.uid).get();

      await followersRef
          .document(user.uid)
          .collection('userFollowers')
          .document(user.uid)
          .setData({});
    }
    currentUser = User.fromDocuments(doc);
    setState(() {
      googleAuth = true;
    });
    print(currentUser);
    print(currentUser.username);
  }

  createUserInFirestoreFacebook() async {
    //  1) check if user exists in user collection in database(acc to their id)
    final FirebaseUser user = await _auth.currentUser();

    DocumentSnapshot doc = await userRef.document(user.uid).get();

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
      userRef.document(user.uid).setData({
        'id': user.uid,
        'username':
            username == null ? user.displayName.trim().toLowerCase() : username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timeStamp': timeStamp,
      });
      doc = await userRef.document(user.uid).get();

      await followersRef
          .document(user.uid)
          .collection('userFollowers')
          .document(user.uid)
          .setData({});
    }
    currentUser = User.fromDocuments(doc);
    setState(() {
      facebookAuth = true;
    });
    print(currentUser);
    print(currentUser.username);
  }

  // googleLogIn() async {
  //   googleSignIn.signIn();
  //   final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
  //   print(currentUser.email);
  // }

  void _signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print(user);
    googleSignInHandler(googleUser);
  }

  googleLogOut() async {
    await googleSignIn.signOut();
    await _auth.signOut();

    setState(() {
      googleAuth = false;
    });
    Navigator.pop(context);
    return LoginPage();
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
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(
            profileId: currentUser?.id,
            func: googleAuth ? googleLogOut : fbLogOut,
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
    return LoginPage(
      funcFacebook: fbLogin,
      funcGoogle: _signInWithGoogle,
    );
  }

  fbAuthScreen() {
    return FbAuth(func: fbLogOut);
  }

  Widget spinnerPage() {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple,
                Colors.teal,
              ],
            ),
          ),
          child: SpinKitCircle(
            color: Colors.white,
          ),
        ),
      );
    } else if (facebookAuth || googleAuth) {
      return buildAuthScreen();
    } else {
      return LoginPage(
        funcFacebook: fbLogin,
        funcGoogle: _signInWithGoogle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return spinnerPage();
  }
}
