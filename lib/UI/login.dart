import 'package:flutter/material.dart';

import 'package:jmm_quiz_app/const.dart';

import 'package:jmm_quiz_app/services/auth_service.dart';
import 'package:jmm_quiz_app/widget/loading.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  late AuthService? authService;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    authService!.isSignedIn(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Social Login',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      authService!.googleLogin().catchError((err) {
                        Fluttertoast.showToast(msg: err.toString());
                        print(err.toString());
                        this.setState(() {
                          isLoading = false;
                        });
                      });
                    },
                    child: isLoading
                        ? SizedBox()
                        : Text(
                            'SIGN IN WITH GOOGLE',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xffdd4b39)),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await authService!.facebookLogin();
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: isLoading
                        ? SizedBox()
                        : Text(
                            'SIGN IN WITH FACEBOOK',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0))),
                  ),
                ],
              ),
            ),
            // Loading
            Positioned(
              child: isLoading ? const Loading() : Container(),
            ),
          ],
        ));
  }
}
