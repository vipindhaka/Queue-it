import 'package:flutter/material.dart';
import 'package:right/widgets/appNameContainer.dart';
import 'package:right/widgets/backgroundGradientContainer.dart';

//Added loading screen
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundGradientContainer(),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * (0.2)),
              child: AppNameContainer(),
            ),
          ),
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.pink),
            ),
          )
        ],
      ),
    );
  }
}
