import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:right/screens/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:right/service/locationService.dart';
import 'package:right/widgets/shopDetailForm.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ShopDetailScreen extends StatefulWidget {
  static const routeName = 'shopDetailScreen';

  @override
  _ShopDetailScreenState createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  var _isLoading = false;
  void _submitServiceForm(
      String shopName,
      int maxSeat,
      File image,
      BuildContext ctx,
      String gender,
      List<Location> address,
      String shopAddress) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (address.length > 0) {
        var location = Geoflutterfire().point(
            latitude: address[0].latitude, longitude: address[0].longitude);

        final user = await FirebaseAuth.instance.currentUser();
        final ref = FirebaseStorage.instance
            .ref()
            .child('shop-Images')
            .child(user.uid + '.jpg');
        await ref.putFile(image).onComplete;
        final url = await ref.getDownloadURL();
        //Changed collection to shops
        await Firestore.instance
            .collection('shops')
            .document(user.uid)
            .setData({
          'address': shopAddress,
          'shopName': shopName,
          'location': location.data,
          'maxSeat': maxSeat,
          'serviceFor': gender,
          'image_url': url,
          'timeStamp': Timestamp.now(),
          'accepting': false,
          'amountToPay': 0,
        });
        Navigator.of(context).pushReplacementNamed(
          HomeScreen.routeName,
          //arguments: shopName
        );
      }
      //Navigator.of(context).pop();
    } on PlatformException catch (err) {
      var message = 'An error occured,please try again';
      if (err.message != null) {
        message = err.message;
      }
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      //print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }
  //    else {
  //     print(locationResult);
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Shop Details'),
          // actions: [
          //   IconButton(
          //     icon: Icon(Icons.chevron_right),
          //     onPressed: () {
          //       Navigator.of(context)
          //           .pushReplacementNamed(HomeScreen.routeName);
          //     },
          //   )
          // ],
        ),
        body: Center(
          child: ShopDetailForm(_submitServiceForm, _isLoading),
        ));
  }
}
