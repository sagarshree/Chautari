import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/models/constanta.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String username;
  final _formKey = GlobalKey<FormState>();

  submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      SnackBar snackBar = SnackBar(
        content: Text('Welcome $username'),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);

      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, title: 'Create Account', removeBackButton: true),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Center(
              child: Text(
                'Create a username',
                style: kCreateUsernameTextStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                autovalidate: true,
                validator: (val) {
                  if (val.trim().length < 3 || val.isEmpty) {
                    return 'Username too short';
                  } else if (val.trim().length > 12) {
                    return 'Username too long';
                  } else {
                    return null;
                  }
                },
                onSaved: (val) {
                  username = val;
                },
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(FontAwesomeIcons.user),
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                  labelStyle: TextStyle(fontSize: 15.0),
                  hintText: 'At least 3 characters',
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: submit,
            child: Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  'SUBMIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
