import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:right/widgets/app_drawer.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:right/widgets/internet/InternetNotAvailable.dart';
import 'package:upi_india/upi_india.dart';

class PayDues extends StatefulWidget {
  static const routeName = 'paye-dues';

  @override
  _PayDuesState createState() => _PayDuesState();
}

class _PayDuesState extends State<PayDues> {
  Future<UpiResponse> _transaction;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp> apps;
  // static const platform = const MethodChannel("razorpay_flutter");
  int totalAmount = 0;
  //Razorpay _razorpay;
  @override
  void initState() {
    // UpiApp app = UpiApp.;
    // setState(() {
    //   apps = app;
    // });
    _upiIndia.getAllUpiApps().then((value) {
      setState(() {
        apps = value;
      });
    });
    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    super.initState();
  }

  Future<UpiResponse> initiateTransaction(String app, int amount) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: '9466795401@paytm',
      receiverName: 'Queue It Pvt Ltd',
      transactionRefId: 'Thank You For the Support',
      transactionNote: 'Thanks for Your Services',
      amount: amount.toDouble(),
    );
  }

  Widget displayUpiApps(int totalAmount) {
    if (apps == null) return Center(child: CircularProgressIndicator());
    if (apps.length == 0)
      return Center(child: Text("No apps found to handle transaction."));
    else
      return Center(
        child: Wrap(
          children: apps.map<Widget>((UpiApp app) {
            return GestureDetector(
              onTap: () {
                _transaction = initiateTransaction(app.app, totalAmount);
                setState(() {});
              },
              child: Container(
                height: 100,
                width: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.memory(
                      app.icon,
                      height: 60,
                      width: 60,
                    ),
                    Text(app.name),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
  }

  @override
  void dispose() {
    super.dispose();
    // _razorpay.clear();
  }

  // void _getDues() async {
  //   final user = await FirebaseAuth.instance.currentUser();
  //   final data =
  //       await Firestore.instance.collection('shops').document(user.uid).get();
  //   setState(() {
  //     totalAmount = data['amountToPay'];
  //     totalAmount = (totalAmount / 10).round();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dues'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder: (context, usersnapshot) {
            if (usersnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            return FutureBuilder(
                future: Firestore.instance
                    .collection('shops')
                    .document(usersnapshot.data.uid)
                    .get(),
                builder: (context, rupeeSnapshot) {
                  if (rupeeSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  totalAmount =
                      ((rupeeSnapshot.data['amountToPay']) / 5).round();
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Visibility(
                          visible: Provider.of<DataConnectionStatus>(context) ==
                              DataConnectionStatus.disconnected,
                          child: InternetNotAvailable()),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     // RaisedButton.icon(
                      //     //     onPressed: _getDues,
                      //     //     icon: Icon(Icons.payment),
                      //     //     label: Text('See Your Dues')),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Text(
                          'Your Dues are: ' +
                              ((rupeeSnapshot.data['amountToPay']) / 5)
                                  .round()
                                  .toString() +
                              ' Rs',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      displayUpiApps(totalAmount),
                      FutureBuilder(
                        future: _transaction,
                        builder: (BuildContext context,
                            AsyncSnapshot<UpiResponse> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('An Unknown error has occured'));
                            }
                            UpiResponse _upiResponse;
                            _upiResponse = snapshot.data;
                            if (_upiResponse.error != null) {
                              String text = '';
                              switch (snapshot.data.error) {
                                case UpiError.APP_NOT_INSTALLED:
                                  text =
                                      "Requested app not installed on device";
                                  break;
                                case UpiError.INVALID_PARAMETERS:
                                  text =
                                      "Requested app cannot handle the transaction";
                                  break;
                                case UpiError.NULL_RESPONSE:
                                  text =
                                      "requested app didn't returned any response";
                                  break;
                                case UpiError.USER_CANCELLED:
                                  text = "You cancelled the transaction";
                                  break;
                              }
                              return Center(
                                child: Text(text),
                              );
                            }
                            String txnId = _upiResponse.transactionId;
                            String resCode = _upiResponse.responseCode;
                            String txnRef = _upiResponse.transactionRefId;
                            String status = _upiResponse.status;
                            String approvalRef = _upiResponse.approvalRefNo;
                            switch (status) {
                              case UpiPaymentStatus.SUCCESS:
                                Firestore.instance
                                    .collection('shops')
                                    .document(usersnapshot.data.uid)
                                    .updateData({'amountToPay': 0});
                                print('Transaction Successful');

                                break;
                              case UpiPaymentStatus.SUBMITTED:
                                print('Transaction Submitted');
                                break;
                              case UpiPaymentStatus.FAILURE:
                                print('Transaction Failed');
                                break;
                              default:
                                print('Received an Unknown transaction status');
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Transaction Id: $txnId\n'),
                                Text('Response Code: $resCode\n'),
                                Text('Reference Id: $txnRef\n'),
                                Text('Status: $status\n'),
                                Text('Approval No: $approvalRef'),
                              ],
                            );
                          } else
                            return Text(' ');
                        },
                      ),

                      //   ],
                      // ),
                      // SizedBox(
                      //   height: size * 0.7,
                      // ),
                      // RaisedButton(
                      //   onPressed: rupeeSnapshot.data['amountToPay'] <= 0
                      //       ? null
                      //       : openCheckout,
                      //   child: Text('Pay Dues'),
                      // )
                    ],
                  );
                });
          }),
    );
  }

  // void openCheckout() async {
  //   var options = {
  //     'key': 'rzp_test_1DP5mmOlF5G5ag',
  //     'amount': (double.parse(totalAmount.toString()) * 100.roundToDouble())
  //         .toString(),
  //     'name': 'Q-It',
  //     'description': 'Your Dues',
  //     'prefill': {'contact': '', 'email': ''},
  //     'external': {
  //       'wallets': ['paytm']
  //     }
  //   };

  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     debugPrint(e);
  //   }
  // }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   Fluttertoast.showToast(
  //     msg: "SUCCESS: " + response.paymentId,
  //   );
  //   final user = await FirebaseAuth.instance.currentUser();

  //   await Firestore.instance
  //       .collection('shops')
  //       .document(user.uid)
  //       .updateData({'amountToPay': 0});
  // }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   Fluttertoast.showToast(
  //     msg: "ERROR: " + response.code.toString() + " - " + response.message,
  //   );
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   Fluttertoast.showToast(
  //     msg: "EXTERNAL_WALLET: " + response.walletName,
  //   );
  // }
}
