import 'package:flutter/material.dart';

Widget header(
  context, {
  String title,
  bool removeBackButton = false,
}) {
  return AppBar(
    centerTitle: true,
    automaticallyImplyLeading: removeBackButton ? false : true,
    backgroundColor: Colors.white,
    // Theme.of(context).primaryColor,
    title: Text(
      title == null ? 'Chautari' : title,
      style: title == null
          ? TextStyle(
              fontFamily: 'Galada',
              fontSize: 50.0,
              color: Colors.black,
            )
          : TextStyle(fontSize: 25, color: Colors.black),
    ),
  );
}
