import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:right/screens/DetailScreen.dart';
import 'package:right/widgets/SingleServiceView.dart';

class ServicesDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          margin: EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height * .7,
          child: FutureBuilder(
            future: FirebaseAuth.instance.currentUser(),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              // if (!futureSnapshot.hasData) {
              //   return Center(child: Text('no services found'));
              // }
              return StreamBuilder(
                stream: Firestore.instance
                    .collection(
                        'shops/${futureSnapshot.data.uid}/services') //shopp
                    .orderBy('price', descending: true)
                    .snapshots(),
                builder: (context, serviceSnapshot) {
                  if (serviceSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final services = serviceSnapshot.data.documents;

                  // if (!serviceSnapshot.hasData) {
                  //   return Text(
                  //     'no services found',
                  //     style: TextStyle(fontWeight: FontWeight.bold),
                  //   );
                  // }
                  return services.length == 0
                      ? Center(
                          child: Text(
                          'No services Added',
                          style: TextStyle(fontSize: 20),
                        ))
                      : ListView.builder(
                          //reverse: true,
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            return SingleService(
                              services,
                              index,
                            );
                          },
                        );
                },
              );
            },
          )),
    );
  }
}
