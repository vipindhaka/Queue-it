import 'package:flutter/material.dart';
import 'package:contactus/contactus.dart';
import 'package:right/widgets/app_drawer.dart';

class Contact extends StatelessWidget {
  static const routeName = 'contact-us';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: ContactUs(
          companyColor: Theme.of(context).primaryColor,
          textColor: Colors.white,
          logo: AssetImage('dev_assets/queueitIcon.jpg'),
          taglineColor: Theme.of(context).primaryColor,
          cardColor: Theme.of(context).primaryColor,
          //logo: AssetImage('images/crop.jpg'),
          email: 'vipindhaka99@gmail.com',
          companyName: 'Queue-it',
          phoneNumber: '+918295716758',
          phoneNumberText: 'Call Support',
          emailText: 'Mail Your Queries',

          //website: 'https://abhishekdoshi.godaddysites.com',
          //githubUserName: 'vipindhaka',
          //linkedinURL: 'https://www.linkedin.com/in/abhishek-doshi-520983199/',
          tagLine: 'Get in Queue',
          //twitterHandle: 'AbhishekDoshi26',
          instagram: 'vipin.dhaka8351',
        ),
      ),
    );
  }
}
