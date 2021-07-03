import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jmm_quiz_app/UI/home.dart';
import 'package:jmm_quiz_app/UI/settings.dart';
import 'package:jmm_quiz_app/const.dart';
import 'package:jmm_quiz_app/main.dart';

class UserServices extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  BuildContext? homeContext;

  void setContext(BuildContext context) {
    homeContext = context;
  }

  int _limit = 20;
  int _limitIncrement = 20;
  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Add Biometrics', icon: Icons.fingerprint),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  void loadingTrue() {
    isLoading = true;

    //notifyListeners();
  }

  void loadingFalse() {
    isLoading = false;

    //notifyListeners();
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      googleSignOut();
    } else {
      Navigator.push(homeContext!,
          MaterialPageRoute(builder: (context) => ChatSettings()));
    }
  }

  Future<Null> googleSignOut() async {
    loadingTrue();

    final isSignedIn = await googleSignIn.isSignedIn();
    if (isSignedIn) {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.disconnect();
      await googleSignIn.signOut();

      Navigator.of(homeContext!).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false);
    } else {
      FacebookAuth.instance.logOut();
      Navigator.of(homeContext!).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false);
    }

    loadingFalse();
  }

  Future<Null> facebookSignOut() async {
    loadingTrue();

    await FirebaseAuth.instance.signOut();
    await FacebookAuth.instance.logOut();

    loadingFalse();

    Navigator.of(homeContext!).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: homeContext!,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }
}
