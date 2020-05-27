import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function funcFacebook;
  final Function funcGoogle;

  LoginPage({
    this.funcFacebook,
    this.funcGoogle,
  });
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  logoutAlert(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            content: Text('Feature Coming Soon !!!'),
          );
        });
  }

  otherLoginFields(parentContext, orientation) {
    return Column(
      children: <Widget>[
        Container(
          child: Text(
            'or login with',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(parentContext).size.height * 0.025,
        ),
        Container(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap:
                      // () {},
                      widget.funcFacebook,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/facebook.png'),
                  ),
                ),
                SizedBox(
                  width: 50,
                ),
                GestureDetector(
                    onTap: widget.funcGoogle,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/google.png'),
                      backgroundColor: Colors.white,
                      radius: 25,
                    ))
              ]),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Don\'t have an account ?',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FlatButton(
                onPressed: () => print('Register tapped'),
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  inputAndLoginFields(parentContext, orientation) {
    final focus = FocusNode();
    final height = MediaQuery.of(parentContext).size.height;
    final width = MediaQuery.of(parentContext).size.width;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: orientation == Orientation.portrait
                ? EdgeInsets.only(bottom: 10.0)
                : EdgeInsets.only(bottom: 5.0),
            height: orientation == Orientation.portrait
                ? height * 0.068
                : height * 0.125,
            width:
                orientation == Orientation.portrait ? width * 0.8 : width * 0.4,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: kElevationToShadow[4]),
            child: ListTile(
              contentPadding: EdgeInsets.only(bottom: 15, left: 20),
              leading: Icon(
                Icons.email,
                size: 20,
              ),
              title: TextField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Email or Phone',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: orientation == Orientation.portrait
                ? EdgeInsets.only(top: 10.0, bottom: 5.0)
                : EdgeInsets.only(top: 5.0, bottom: 5.0),
            height: orientation == Orientation.portrait
                ? height * 0.068
                : height * 0.125,
            width:
                orientation == Orientation.portrait ? width * 0.8 : width * 0.4,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: kElevationToShadow[4]),
            child: ListTile(
              contentPadding: EdgeInsets.only(bottom: 15, left: 20),
              leading: Icon(
                Icons.vpn_key,
                size: 20,
              ),
              title: TextFormField(
                focusNode: focus,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Align(
              alignment: Alignment.center,
              child: FlatButton(
                padding: EdgeInsets.all(0.0),
                onPressed: () => print('Forgot Password'),
                child: Text(
                  'Forgot Password ?',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => logoutAlert(context),
            child: Container(
              margin: EdgeInsets.only(bottom: 5.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple,
                      Colors.teal,
                    ],
                  )),
              height: orientation == Orientation.portrait
                  ? height * 0.068
                  : height * 0.125,
              width: orientation == Orientation.portrait
                  ? width * 0.8
                  : width * 0.4,
              child: Center(
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.36,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple,
                        Colors.teal,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100.0),
                      // bottomRight: Radius.circular(100.0),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.account_circle,
                        size: MediaQuery.of(context).size.height * 0.32 * 0.33,
                        color: Colors.white,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Chautari',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontFamily: 'Galada',
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'Galada'),
                      ),
                    ),
                  ],
                ),
              ),
              orientation == Orientation.portrait
                  ? Column(
                      children: <Widget>[
                        inputAndLoginFields(context, orientation),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        otherLoginFields(context, orientation),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        inputAndLoginFields(context, orientation),
                        otherLoginFields(context, orientation),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
