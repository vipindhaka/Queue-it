import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:right/widgets/offlineavailableServices.dart';
import 'package:right/widgets/requests/addInQueueButton.dart';

class AddOfflineService extends StatelessWidget {
  List<Map<String, dynamic>> _selectedServices = [];
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Add Offline Service',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: MediaQuery.of(context).size.height * .5,
              child: FutureBuilder(
                future: FirebaseAuth.instance.currentUser(),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  // if (!futureSnapshot.hasData) {
                  //   return Center(child: Text('no services found'));
                  // }
                  return StreamBuilder(
                    stream: Firestore.instance
                        .collection('shops/${futureSnapshot.data.uid}/services')
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
                                return OfflineServiceAvailable(
                                    services, index, _selectedServices);
                              },
                            );
                    },
                  );
                },
              ),
            ),
            AddInQueueButton(_selectedServices),
          ],
        ),
      ),
    );
  }
}
