import 'package:flutter/material.dart';

class StartShopButton extends StatefulWidget {
  StartShopButton(this.shopFn, this.startShop);
  final void Function(bool startShop) shopFn;
  final startShop;
  @override
  _StartShopButtonState createState() => _StartShopButtonState(this.startShop);
}

class _StartShopButtonState extends State<StartShopButton> {
  var startShopstage;
  _StartShopButtonState(this.startShopstage);
  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
        onPressed: !startShopstage
            ? () {
                setState(() {
                  startShopstage = !startShopstage;
                });
                widget.shopFn(startShopstage);
              }
            : () {
                return showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: Text('Are You Sure?'),
                      content: Text('Close the Shop?'),
                      actions: [
                        FlatButton(
                          child: const Text('No'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                        FlatButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            setState(() {
                              startShopstage = !startShopstage;
                            });
                            widget.shopFn(startShopstage);
                          },
                        )
                      ],
                    );
                  },
                );
              },
        icon: Icon(
          startShopstage ? Icons.pause : Icons.play_arrow,
          size: 30,
        ),
        label: Text(startShopstage ? 'Close Shop' : 'Start Shop'));
  }
}
