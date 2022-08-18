import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddInQueueButton extends StatefulWidget {
  final List<Map<String, dynamic>> services;
  AddInQueueButton(this.services);

  @override
  _AddInQueueButtonState createState() => _AddInQueueButtonState();
}

class _AddInQueueButtonState extends State<AddInQueueButton> {
  int totalAmount = 0;
  int totalCompletionTIme = 0;
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : RaisedButton(
            child: Text(
              'Add In Queue',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              if (widget.services.isNotEmpty) {
                final user = await FirebaseAuth.instance.currentUser();
                for (int v = 0; v < widget.services.length; v++) {
                  totalAmount += widget.services[v]['price'];
                  totalCompletionTIme += widget.services[v]['CompletionTime'];
                }
                print(widget.services);
                await Firestore.instance
                    .collection('shops/${user.uid}/requests')
                    .add({
                  'personName': 'Offline',
                  'status': 'Incomplete',
                  'timestamp': Timestamp.now(),
                  'services': widget.services.toList(),
                  'totalAmount': totalAmount,
                  'totalCompletionTime': totalCompletionTIme
                });
                _isLoading = false;
                Navigator.of(context).pop();
              }
            });
  }
}
