import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SingleService extends StatelessWidget {
  SingleService(
    this.services,
    this.index,
    //this.futureSnapshot,
  );

  final services;
  final index;
//  final futureSnapshot;

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
      child: ListTile(
        //leading: CircleAvatar(),
        title: Text(
          services[index]['name'],
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(services[index]['completionTimeInMinute'].toString() + ' Min'),
            Text(services[index]['price'].toString() + ' Rupee'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete,
            color: Theme.of(context).errorColor,
          ),
          onPressed: () async {
            await Firestore.instance.runTransaction((transaction) async =>
                await transaction.delete(services[index].reference));
          },
        ),
      ),
    );
  }
}
