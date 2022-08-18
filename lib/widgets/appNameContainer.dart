import 'dart:math';

import 'package:flutter/material.dart';

class AppNameContainer extends StatelessWidget {
  const AppNameContainer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
      transform: Matrix4.rotationZ(-8.0 * pi / 180)..translate(-10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.deepOrange.shade900,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black26,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Text('Q-It',
          style: TextStyle(
            color: Theme.of(context).accentTextTheme.headline1.color,
            fontSize: 50,
            fontFamily: 'Anton',
            fontWeight: FontWeight.normal,
          )),
    );
  }
}
