import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AvailableBarber extends StatefulWidget {
  final barber;
  final id;
  AvailableBarber(this.barber, this.id);

  @override
  _AvailableBarberState createState() => _AvailableBarberState();
}

class _AvailableBarberState extends State<AvailableBarber> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 50,
            icon: Icon(Icons.arrow_left),
            onPressed: widget.barber == 1
                ? null
                : () async {
                    Firestore.instance
                        .collection('shops')
                        .document(widget.id)
                        .updateData({'maxSeat': widget.barber - 1});
                    setState(() {});
                  },
          ),
          Text(
            widget.barber.toString(),
            style: TextStyle(fontSize: 20),
          ),
          IconButton(
            iconSize: 50,
            icon: Icon(Icons.arrow_right),
            onPressed: () async {
              Firestore.instance
                  .collection('shops')
                  .document(widget.id)
                  .updateData({'maxSeat': widget.barber + 1});
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
