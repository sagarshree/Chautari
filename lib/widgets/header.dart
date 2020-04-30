import 'package:flutter/material.dart';

Widget header(context, {String title}) {
  return AppBar(
    backgroundColor: Theme.of(context).accentColor,
    title: Center(
      child: Text(
        title == null ? 'Chautari' : title,
        style: title == null
            ? TextStyle(
                fontFamily: 'Signatra',
                fontSize: 60.0,
              )
            : TextStyle(fontSize: 25),
      ),
    ),
  );
}
