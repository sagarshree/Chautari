import 'package:flutter/material.dart';

Widget header(
  context, {
  String title,
  bool removeBackButton = false,
}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    backgroundColor: Theme.of(context).accentColor,
    title: Center(
      child: Text(
        title == null ? 'Chautari' : title,
        style: title == null
            ? TextStyle(
                fontFamily: 'Galada',
                fontSize: 50.0,
              )
            : TextStyle(fontSize: 25),
      ),
    ),
  );
}
