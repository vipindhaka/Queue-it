import 'dart:io';

import 'package:flutter/material.dart';
import 'package:right/widgets/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ShopDetailForm extends StatefulWidget {
  ShopDetailForm(this.submitFn, this.isLoading);
  final bool isLoading;
  final void Function(
      String shopName,
      int maxSeat,
      File image,
      BuildContext context,
      String gender,
      List<Location> latlong,
      String address) submitFn;

  @override
  _ShopDetailFormState createState() => _ShopDetailFormState();
}

class _ShopDetailFormState extends State<ShopDetailForm> {
  Position userLocation;
  List<Location> locations;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _address = TextEditingController();
  //var _isLogin = true;
  var _shopName = '';
  int _maxSeat;
  var group = 'Male';
  //int _serviceTime;
  File _shopImageFile;

  void _pickedImage(File image) {
    _shopImageFile = image;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_shopImageFile == null) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Please pick an image'),
        backgroundColor: Theme.of(context).errorColor,
      ));
      return;
    }

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(_shopName.trim(), _maxSeat, _shopImageFile, context,
          group, locations, _address.text);
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation().then((position) {
      userLocation = position;
      _getAddress(position);
      print(userLocation);
    });
    //_getAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      //elevation: 20,
      margin: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ShopImagePicker(_pickedImage),
                TextFormField(
                  key: ValueKey('Shop Name'),
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Please enter a valid Shop name';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(labelText: 'Shop Name'),
                  onSaved: (value) {
                    _shopName = value;
                  },
                ),
                TextFormField(
                  key: ValueKey('max seat'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty || int.parse(value) <= 0) {
                      return 'Please enter a valid no of seats';
                    }
                    return null;
                  },
                  decoration:
                      InputDecoration(labelText: 'Max Seats(Max Barbers)'),
                  //obscureText: true,
                  onSaved: (value) {
                    _maxSeat = int.parse(value);
                  },
                ),
                TextFormField(
                  controller: _address,
                  key: ValueKey('Address'),
                  keyboardType: TextInputType.streetAddress,
                  validator: (value) {
                    if (value.isEmpty || value.length <= 10) {
                      return 'Please enter a valid address';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Address'),
                  //obscureText: true,
                  onSaved: (value) async {
                    // _address = value;
                    locations = await locationFromAddress(value);
                    print(value);
                  },
                ),
                SizedBox(
                  height: 12,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Services Provided For: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                    textAlign: TextAlign.start,
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Radio(
                            value: 'Male',
                            groupValue: group,
                            onChanged: (t) {
                              setState(() {
                                group = t;
                              });
                            }),
                        // SizedBox(
                        //   width: 2,
                        // ),
                        Text('Male'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                            value: 'Female',
                            groupValue: group,
                            onChanged: (t) {
                              setState(() {
                                group = t;
                              });
                            }),
                        // SizedBox(
                        //   width: 2,
                        // ),
                        Text('Female'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                            value: 'Both',
                            groupValue: group,
                            onChanged: (t) {
                              setState(() {
                                group = t;
                              });
                            }),
                        // SizedBox(
                        //   width: 2,
                        // ),
                        Text('Both'),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                if (widget.isLoading) CircularProgressIndicator(),
                if (!widget.isLoading)
                  RaisedButton(
                    child: Text('Save Shop'),
                    onPressed: _trySubmit,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation =
          await getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future _getAddress(Position position) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    _address.text = placemark[0].name +
        ' ' +
        placemark[0].subLocality +
        ' ' +
        placemark[0].locality +
        ' ' +
        placemark[0].administrativeArea +
        ' ' +
        placemark[0].country;
  }
}
