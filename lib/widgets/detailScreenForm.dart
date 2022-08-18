import 'package:flutter/material.dart';

class DetailScreenForm extends StatefulWidget {
  DetailScreenForm(this.submitFn);
  final void Function(
    String serviceName,
    int servicePrice,
    int serviceTime,
  ) submitFn;

  @override
  _DetailScreenFormState createState() => _DetailScreenFormState();
}

class _DetailScreenFormState extends State<DetailScreenForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  //var _isLogin = true;
  var _serviceName = '';
  int _servicePrice;
  int _serviceTime;

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _serviceName.trim(),
        _servicePrice,
        _serviceTime,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        //elevation: 20,
        //margin: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    key: ValueKey('Service Name'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a valid service name';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: 'Service Name'),
                    onSaved: (value) {
                      _serviceName = value;
                    },
                  ),
                  TextFormField(
                    key: ValueKey('price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty || int.parse(value) <= 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Price'),
                    //obscureText: true,
                    onSaved: (value) {
                      _servicePrice = int.parse(value);
                    },
                  ),
                  TextFormField(
                    key: ValueKey('Service Time'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty || int.parse(value) <= 0) {
                        return 'please enter a valid time';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Time(in minutes)'),
                    onSaved: (value) {
                      _serviceTime = int.parse(value);
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  _isLoading
                      ? CircularProgressIndicator()
                      : RaisedButton(
                          child: Text('Add Service'),
                          onPressed: _trySubmit,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
