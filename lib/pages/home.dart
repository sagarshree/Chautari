import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

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
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
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

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Chautari',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 140,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            GestureDetector(
              onTap: logIn,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
