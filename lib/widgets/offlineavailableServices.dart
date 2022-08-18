//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OfflineServiceAvailable extends StatefulWidget {
  OfflineServiceAvailable(this.services, this.index, this.selectedServices
      //this.futureSnapshot,
      );

  final services;
  final index;
  final List<Map<String, dynamic>> selectedServices;

  @override
  _OfflineServiceAvailableState createState() =>
      _OfflineServiceAvailableState();
}

class _OfflineServiceAvailableState extends State<OfflineServiceAvailable> {
  var _checked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: CheckboxListTile(
        title: Text(
          widget.services[widget.index]['name'],
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle:
            Text(widget.services[widget.index]['price'].toString() + ' Rupee'),
        value: _checked,
        onChanged: (value) {
          setState(() {
            _checked = value;
            _checked
                ? widget.selectedServices.add({
                    'name': widget.services[widget.index]['name'],
                    'CompletionTime': widget.services[widget.index]
                        ['completionTimeInMinute'],
                    'price': widget.services[widget.index]['price']
                  })
                : widget.selectedServices.remove({
                    'name': widget.services[widget.index]['name'],
                    'CompletionTime': widget.services[widget.index]
                        ['completionTimeInMinute'],
                    'price': widget.services[widget.index]['price']
                  });
          });
        },
      ),
    );
  }
}
