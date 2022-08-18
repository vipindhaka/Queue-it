//import 'package:firebase_auth/firebase_auth.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:right/widgets/availableBarbers.dart';
import 'package:right/widgets/internet/InternetNotAvailable.dart';
//import 'package:right/widgets/startStopButton/palyPause.dart';
import 'package:right/widgets/startStopButton/startShoop.dart';
import '../requests/request.dart';

class RequestsWidget extends StatefulWidget {
  @override
  _RequestsWidgetState createState() => _RequestsWidgetState();
}

class _RequestsWidgetState extends State<RequestsWidget> {
  bool startShop;
  @override
  void initState() {
    final fbm = FirebaseMessaging();

    fbm.requestNotificationPermissions();
    fbm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
    // getUseruid()
    //     .then((value) => fbm.subscribeToTopic('shops/${value.uid}/requests'));
    super.initState();
  }

  // Future<FirebaseUser> getUseruid() async {
  //   final user = await FirebaseAuth.instance.currentUser();
  //   return user;
  // }

  void _startShopService(bool startShop) async {
    final user = await FirebaseAuth.instance.currentUser();

    await Firestore.instance
        .collection('shops') //shops
        .document(user.uid)
        .updateData({
      'accepting': startShop ? true : false,
    });
    if (!startShop) {
      var amount = await Firestore.instance
          .collection('shops') //shops
          .document(user.uid)
          .get();
      int totalAmount = amount['amountToPay'];
      await Firestore.instance
          .collection('shops/${user.uid}/requests') //shops
          .orderBy('timestamp')
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.documents) {
          if (doc.data['status'] == 'Completed' &&
              doc.data['personName'] != 'Offline') {
            totalAmount += doc.data['totalAmount'];
          }
          doc.reference.delete().then((value) => print("Deleted"));
        }
      });
      await Firestore.instance
          .collection('shops') //shops
          .document(user.uid)
          .updateData({'amountToPay': totalAmount});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return StreamBuilder(
              stream: Firestore.instance
                  .collection('shops') //shops
                  .document(userSnapshot.data.uid)
                  .snapshots(),
              builder: (context, seatSnapshot) {
                if (seatSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final data = seatSnapshot.data;
                seatSnapshot.data['accepting']
                    ? startShop = true
                    : startShop = false;
                //print(data['accepting']);
                return StreamBuilder<QuerySnapshot>(
                    //Getting only Incomplete and In Progress request
                    stream: Firestore.instance
                        .collection(
                            'shops/${userSnapshot.data.uid}/requests') //shops
                        .where("status", whereIn: ["Incomplete", "In Progress"])
                        .orderBy(
                          'timestamp',
                        )
                        .snapshots(),
                    builder: (context, requestSnapshot) {
                      if (requestSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final requestDocs = requestSnapshot.data.documents;
                      return SingleChildScrollView(
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                                visible: Provider.of<DataConnectionStatus>(
                                        context) ==
                                    DataConnectionStatus.disconnected,
                                child: InternetNotAvailable()),
                            Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: Colors.grey),
                                color: Colors.pink[50],
                              ),
                              margin: EdgeInsets.all(5),
                              height: MediaQuery.of(context).size.height * 0.5,
                              width: double.infinity,
                              child: requestDocs.length == 0
                                  ? Center(
                                      child: Text(
                                      'No requests',
                                      style: TextStyle(fontSize: 20),
                                    ))
                                  : ListView.builder(
                                      //reverse: true,
                                      itemCount: requestDocs.length,
                                      itemBuilder: (context, index) {
                                        return RequestBubble(
                                            index: index,
                                            seats: data['maxSeat'],
                                            shopId: userSnapshot.data.uid,
                                            requestSnapshot: requestDocs[index],
                                            key: ValueKey(
                                                requestDocs[index].documentID),
                                            services: requestDocs[index]
                                                ['services']);
                                      },
                                    ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                StartShopButton(_startShopService, startShop),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Available Barbers',
                                  style: TextStyle(fontSize: 20),
                                ),
                                //PlayPauseButton(_startService),
                                AvailableBarber(
                                    data['maxSeat'], userSnapshot.data.uid),
                              ],
                            )
                          ],
                        ),
                      );
                    });
              });
        });
  }
}

/*
                                          requestDocs[index]['personName'],
                                          index,
                                          //chatDocs[index]['userId'] == futureSnapShot.data.uid,
                                          ValueKey(
                                              requestDocs[index].documentID),
                                          requestDocs[index]['totalAmount'],
                                          requestDocs,
                                          requestDocs[index]['status'],
                                          userSnapshot.data.uid,
                                          data['maxSeat']


 */
