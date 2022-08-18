import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isLoading);

  final bool isLoading;

  final void Function(String email, String password, String confirmPassword,
      bool isLogin, BuildContext ctx) submitFn;
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  AnimationController _animationController;
  Animation<Size> _heightAnimation;
  var _isLogin = true;
  var _userEmail = '';
  var _confirmPassword = '';
  var _userPassword = '';

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _heightAnimation = Tween<Size>(
            begin: Size(double.infinity, 300), end: Size(double.infinity, 360))
        .animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.bounceIn,
            reverseCurve: Curves.bounceOut));
    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(_userEmail.trim(), _userPassword.trim(),
          _confirmPassword.trim(), _isLogin, context);
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> _handleSignIn() async {
    // hold the instance of the authenticated user
    FirebaseUser user;
    // flag to check whether we're signed in already
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // get the credentials to (access / id token)
      // to sign in via Firebase Authentication
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      user = (await _auth.signInWithCredential(credential)).user;
    } on PlatformException catch (err) {
      var message = 'An error occured,please try again';
      if (err.message != null) {
        message = err.message;
      }
      Fluttertoast.showToast(msg: message);
    } catch (err) {
      // print(err);
      Fluttertoast.showToast(msg: 'An error occured Please try again');
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final _controller = TextEditingController();
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 8,
        margin: EdgeInsets.all(20),
        // child: SingleChildScrollView(
        child: AnimatedBuilder(
          animation: _heightAnimation,
          builder: (ctx, ch) => Container(
              height: _heightAnimation.value.height,
              //height: _isLogin ? 300 : 360,
              constraints:
                  BoxConstraints(minHeight: _heightAnimation.value.height),
              width: deviceSize.width * .75,
              padding: EdgeInsets.all(16),
              child: ch),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    key: ValueKey('email'),
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: 'Email address'),
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                  TextFormField(
                    controller: _pass,
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'password must be atleast 7 characters long';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSaved: (value) {
                      _userPassword = value;
                    },
                  ),
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                          //textColor: Theme.of(context).primaryColor,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Password reset'),
                                  content: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                        labelText: 'Email',
                                        hintText: 'Enter Your Email'),
                                  ),
                                  actions: [
                                    FlatButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Send Link'),
                                      onPressed: () {
                                        (_controller.text.isEmpty ||
                                                !_controller.text.contains('@'))
                                            ? Fluttertoast.showToast(
                                                msg:
                                                    'Please enter a valid email')
                                            : {
                                                FirebaseAuth.instance
                                                    .sendPasswordResetEmail(
                                                        email:
                                                            _controller.text),
                                                Navigator.of(context).pop()
                                              };
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 16),
                          )),
                    ),

                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('Confirm Password'),
                      validator: (value) {
                        if (value.isEmpty || value.length < 4) {
                          return 'please enter a atleast 4 characters';
                        }
                        if (value != _pass.text)
                          return 'Passwords do not match';
                        return null;
                      },
                      decoration:
                          InputDecoration(labelText: 'Confirm Password'),
                      onSaved: (value) {
                        _confirmPassword = value;
                      },
                      obscureText: true,
                    ),
                  // SizedBox(
                  //   height: 12,
                  // ),
                  if (widget.isLoading) CircularProgressIndicator(),
                  if (!widget.isLoading)
                    RaisedButton(
                      child: Text(_isLogin ? 'Login' : 'Signup'),
                      onPressed: _trySubmit,
                    ),
                  FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      onPressed: _handleSignIn,
                      color: Theme.of(context).primaryColor,
                      textColor: Theme.of(context).primaryColor,
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.account_circle, color: Colors.white),
                              SizedBox(width: 10),
                              Text('Login With Google',
                                  style: TextStyle(color: Colors.white))
                            ],
                          ))),
                  if (!widget.isLoading)
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Text(_isLogin
                          ? 'Create a new account'
                          : 'I already have an account'),
                      onPressed: () {
                        print('clicked');
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                        _isLogin
                            ? _animationController.reverse()
                            : _animationController.forward();
                      },
                    )
                ],
              ),
            ),
          ),
        ),
        // ),
      ),
    );
  }
}
