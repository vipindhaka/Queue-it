import 'package:flutter/material.dart';

import 'package:right/widgets/addOfflineService.dart';
import 'package:right/widgets/app_drawer.dart';
import 'package:right/widgets/requests/requestswidget.dart';
// import 'package:startup101/widgets/chat/messages.dart';
// import '../widgets/chat/new_message.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = 'home-screen';

  @override
  Widget build(BuildContext context) {
    //final shopName = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
      ),
      drawer: AppDrawer(),
      body: RequestsWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          return showDialog(
              context: context,
              builder: (ctx) {
                return AddOfflineService();
              });
        },
        child: Icon(Icons.add_to_queue),
      ),
    );
  }
}
