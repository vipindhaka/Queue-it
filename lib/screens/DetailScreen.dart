import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:right/widgets/ServicesDisplay.dart';
import 'package:right/widgets/app_drawer.dart';
import 'package:right/widgets/detailScreenForm.dart';

class DetailScreen extends StatelessWidget {
  static const routeName = 'add_services';
  //DetailScreen(this.user);

  //final user;
  void _submitServiceForm(
    String serviceName,
    int servicePrice,
    int serviceTime,
  ) async {
    final user = await FirebaseAuth.instance.currentUser();

    //Changed collcetion from shops to shops
    await Firestore.instance.collection('shops/${user.uid}/services').add({
      'completionTimeInMinute': serviceTime,
      'price': servicePrice,
      'name': serviceName,
    });

    //Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Services'),
      ),
      drawer: AppDrawer(),
      body: ServicesDisplay(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          return showDialog(
              context: context,
              builder: (ctx) {
                // onTap: () {},
                return DetailScreenForm(_submitServiceForm);
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
