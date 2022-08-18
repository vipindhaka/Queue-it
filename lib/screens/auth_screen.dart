import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:right/widgets/appNameContainer.dart';
import 'package:right/widgets/backgroundGradientContainer.dart';
import 'package:right/widgets/internet/InternetNotAvailable.dart';
import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = 'auth-screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;

  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String password,
    String confirmPassword,
    bool isLogin,
    BuildContext ctx,
  ) async {
    AuthResult authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        // await Firestore.instance
        //     .collection('shops')
        //     .document(authResult.user.uid)
        //     .setData({'shopName': userName, 'email': email});
      }
    } on PlatformException catch (err) {
      var message = 'An error occured,please check credentials';
      if (err.message != null) {
        message = err.message;
      }
      Fluttertoast.showToast(
        msg: message,
      );
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text(message),
      //   backgroundColor: Theme.of(ctx).errorColor,
      // ));
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      // print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      //resize to avoid bottomInset: false
      body: Stack(children: <Widget>[
        Positioned(
          top: 0.0,
          right: 0.0,
          left: 0.0,
          child: Visibility(
            visible: Provider.of<DataConnectionStatus>(context) ==
                DataConnectionStatus.disconnected,
            child: InternetNotAvailable(),
          ),
        ),
        BackgroundGradientContainer(),
        SingleChildScrollView(
          child: Container(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(child: AppNameContainer()),
                Flexible(
                  flex: deviceSize.width > 600 ? 2 : 1,
                  child: AuthForm(_submitAuthForm, _isLoading),
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}
