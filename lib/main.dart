import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:right/screens/DetailScreen.dart';
import 'package:right/screens/auth_screen.dart';
import 'package:right/screens/contactUs.dart';
import 'package:right/screens/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:right/screens/loadingScreen.dart';
import 'package:right/screens/payDues.dart';
import 'package:right/screens/shopDetails.dart';
import 'package:right/service/dataConnectivityService.dart';
import 'package:right/service/databaseService.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //var user;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<DataConnectionStatus>(
          create: (context) {
            return DataConnectivityService()
                .connectivityStreamController
                .stream;
          },
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // textTheme: ,
          primarySwatch: Colors.pink,
          backgroundColor: Colors.pink,
          accentColor: Colors.deepPurple,
          accentColorBrightness: Brightness.dark,
          buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: Colors.pink,
            textTheme: ButtonTextTheme.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),

          //visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (ctx, userSnapshot) {
            if (userSnapshot.hasData) {
              print(userSnapshot.data);
              //user = userSnapshot.data;
              return FutureBuilder(
                future: DatabaseService.isShopExist(userSnapshot.data.uid),
                builder: (context, snapshot) {
                  print('hello');
                  if (!snapshot.hasData) {
                    print('0');
                    return LoadingScreen();
                  }
                  if (snapshot.data is bool) {
                    print('1');
                    if (snapshot.data) {
                      print('2');
                      return HomeScreen();
                    } else {
                      print('3');
                      return ShopDetailScreen();
                    }
                  }
                  return Scaffold(
                    body: Center(
                      child: Text(snapshot.data),
                    ),
                  );
                },
              ); //DetailScreen(userSnapshot.data);
            }
            print(userSnapshot.data);
            return AuthScreen();
          },
        ),
        //Can use onGeneratedRoute method
        routes: {
          HomeScreen.routeName: (ctx) => HomeScreen(),
          ShopDetailScreen.routeName: (ctx) => ShopDetailScreen(),
          PayDues.routeName: (ctx) => PayDues(),
          DetailScreen.routeName: (ctx) => DetailScreen(),
          Contact.routeName: (ctx) => Contact(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
        }, //ChatScreen(),,
      ),
    );
  }
}
