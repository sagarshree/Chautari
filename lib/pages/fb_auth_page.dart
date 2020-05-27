import 'package:flutter/material.dart';

class FbAuth extends StatelessWidget {
  final Function func;
  FbAuth({this.func});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Fb Authenticated'),
              RaisedButton(
                onPressed: func,
                child: Text('Logout'),
                color: Colors.purple,
              )
            ],
          ),
        ),
      ),
    );
  }
}
