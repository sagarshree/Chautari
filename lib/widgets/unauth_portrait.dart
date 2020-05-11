import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UnauthPortrait extends StatelessWidget {
  final Function func;

  UnauthPortrait({this.func});

  @override
  Widget build(BuildContext context) {
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
                fontFamily: 'Galada',
                fontSize: 100,
                color: Colors.white,
              ),
            ),
            Text(
              'Let\'s share thoughts together!!',
              style: TextStyle(
                fontFamily: 'Galada',
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 200.0,
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Sign in with',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.0,
                        fontFamily: 'Galada'),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: func,
                            child: CircleAvatar(
                              radius: 35.0,
                              backgroundColor: Colors.white,
                              child: Icon(
                                FontAwesomeIcons.google,
                                size: 40.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            'Google',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontFamily: 'Galada'),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 80.0,
                      ),
                      Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              print('Facebook Login!');
                            },
                            child: CircleAvatar(
                              radius: 35.0,
                              backgroundColor: Colors.white,
                              child: Icon(
                                FontAwesomeIcons.facebookF,
                                size: 40,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            'Facebook',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontFamily: 'Galada',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
            // GestureDetector(
            //   onTap: logIn,

            //   // child: Container(
            //   //   width: 260.0,
            //   //   height: 60.0,
            //   //   decoration: BoxDecoration(
            //   //     image: DecorationImage(
            //   //       image: AssetImage('assets/images/google_signin_button.png'),
            //   //       fit: BoxFit.cover,
            //   //     ),
            //   //   ),
            //   // ),
            // ),
          ],
        ),
      ),
    );
  }
}
