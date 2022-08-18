import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:right/screens/DetailScreen.dart';

import 'package:right/screens/contactUs.dart';
import 'package:right/screens/homeScreen.dart';
import 'package:right/screens/payDues.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hello Friend'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Divider(),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('My Shop'),
                onTap: () {
                  Navigator.of(context)
                      .pushReplacementNamed(HomeScreen.routeName);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.payment),
                title: Text('My Dues'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(PayDues.routeName);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.library_add),
                title: Text('Add Services'),
                onTap: () {
                  Navigator.of(context)
                      .pushReplacementNamed(DetailScreen.routeName);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.contact_mail),
                title: Text('Contact Us'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(Contact.routeName);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () {
                  try {
                    FirebaseAuth.instance.signOut();
                    GoogleSignIn().disconnect();
                    //GoogleSignIn().signOut();
                    // FirebaseAuth.instance.
                    Navigator.of(context).pop();
                    // Navigator.of(context)
                    //     .pushReplacementNamed(AuthScreen.routeName);
                  } on PlatformException catch (err) {
                    var message = 'An error occured,please try again';
                    if (err.message != null) {
                      message = err.message;
                    }
                    Fluttertoast.showToast(msg: message);
                  } catch (e) {
                    print(e);
                  }

                  // Navigator.of(context)
                  //     .pushReplacementNamed(UserProductsScreen.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
