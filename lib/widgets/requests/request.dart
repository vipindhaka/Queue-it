//import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:right/service/databaseService.dart';

class RequestBubble extends StatefulWidget {
  //final String userName;
  //final bool isMe;
  final Key key;
  final int index;
  final int seats;
  final String shopId;
  final DocumentSnapshot requestSnapshot;
  final List<dynamic> services;

  RequestBubble(
      {this.index,
      //this.isMe,
      this.key,
      this.seats,
      this.requestSnapshot,
      this.shopId,
      this.services});

  @override
  _RequestBubbleState createState() => _RequestBubbleState();
}

class _RequestBubbleState extends State<RequestBubble> {
  // bool inProgress;
  // bool completed;
  Timer _timer;
  int _totalCompletionTime;

  @override
  void initState() {
    super.initState();
    _totalCompletionTime =
        widget.requestSnapshot.data['totalCompletionTime'] as int;
    if (widget.requestSnapshot.data['status'] == "In Progress") {
      Future.delayed(Duration.zero, () {
        updateTimeCompletionTime();
      });
    }
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    print("Dispose");
    super.dispose();
  }

  void updateTimeCompletionTime() {
    //Once we make the request as In Progress
    //we change the totalCompletionTimeInMinute
    //after every 5 minutes until the request is delete
    //or request will complete

    //Assigning timer to _timer
    //setState(() {
    print("Update Start");
    _timer = Timer.periodic(Duration(seconds: 300), (timer) {
      //Update totalCompletionTime after every
      //5 minte(Minute can be change) in future
      if (_totalCompletionTime > 0) {
        DatabaseService.updateRequestTime(widget.shopId,
                widget.requestSnapshot.documentID, _totalCompletionTime - 5)
            .then((value) {
          //This method return requestId if status updated
          //successfully
          if (value.toString() == widget.requestSnapshot.documentID) {
            setState(() {
              _totalCompletionTime = _totalCompletionTime - 5;
            });
            print("Update Completed");
          } else {
            //Show erro message
            print(value);
            _totalCompletionTime = 0;
            _timer.cancel();
          }
        });
      }
    });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      key: widget.key,
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        //Status will never be Completed in this Request
        //So checking this condition will not any impact
        /*
        if (widget.status == 'Completed') {
          var amount = await Firestore.instance
              .collection('shops') //shops
              .document(widget.uid)
              .get();
          int updatedAmountToPay = amount['amountToPay'] + widget.totalAmount;
          await Firestore.instance
              .collection('shops') //shops
              .document(widget.uid)
              .updateData({'amountToPay': updatedAmountToPay});
        }
        */
        await Firestore.instance.runTransaction((transaction) async =>
            await transaction.delete(widget.requestSnapshot.reference));
      },
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('Are You Sure?'),
                  content: const Text('Do you want to delete this service?'),
                  actions: <Widget>[
                    FlatButton(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                    ),
                    FlatButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                    )
                  ],
                ));
      },
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
              Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
            ],
          ),
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
        child: ExpansionTile(
          // onTap: () {
          //   print('welcome');
          //   return showDialog(
          //     context: context,
          //     builder: (ctx) {
          //       final List<Map<String, dynamic>> services =
          //           widget.requestSnapshot.data['services'];
          //       return AlertDialog(
          //         title: Text('Services Booked'),
          //         content: Expanded(
          //           child: ListView(
          //             children: services.map((e) => Text(e['name'])).toList(),
          //           ),
          //         ),
          //       );
          //     },
          //   );
          // },
          children: widget.services
              .map((e) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        e['name'].toString().toUpperCase(),
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(e['price'].toString(),
                          style: TextStyle(fontSize: 20))
                    ],
                  ))
              .toList(),
          key: widget.key,
          leading: CircleAvatar(child: Text((widget.index + 1).toString())),
          title: Text(
            widget.requestSnapshot.data['personName'],
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  widget.requestSnapshot.data['totalAmount'].toString() + 'Rs'),
              Text(widget.requestSnapshot.data['status']),
              Text("Time left $_totalCompletionTime")
            ],
          ),
          //Add button to start service (If status Incomplete)
          trailing: widget.index < widget.seats
              ? IconButton(
                  icon: Icon(
                    widget.requestSnapshot.data['status'] == 'In Progress'
                        ? Icons.check
                        : Icons.play_arrow,
                    color: Theme.of(context).errorColor,
                  ),
                  //Changed onPressed Function
                  onPressed: () async {
                    if (widget.requestSnapshot.data['status'] ==
                        "In Progress") {
                      DatabaseService.updateRequestStatus(widget.shopId,
                              widget.requestSnapshot.documentID, "Completed")
                          .then((value) {
                        if (value.toString() !=
                            widget.requestSnapshot.documentID) {
                          ////_timer.cancel();
                          ///print("Error message");
                        } else {
                          //If no error occured while completing the request
                          //

                        }
                      });
                    } else {
                      DatabaseService.updateRequestStatus(widget.shopId,
                              widget.requestSnapshot.documentID, "In Progress")
                          .then((value) {
                        //This method return requestId if status updated
                        //successfully
                        if (value.toString() ==
                            widget.requestSnapshot.documentID) {
                          updateTimeCompletionTime();
                        } else {
                          //Show snackbar with errorMsg
                        }
                      });
                    }
                  },
                )
              : Icon(Icons.block),
        ),
      ),
    );
  }
}
