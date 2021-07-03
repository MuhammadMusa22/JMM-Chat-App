import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:jmm_quiz_app/const.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatSettings extends StatelessWidget {
  final LocalAuthentication localAuthentication = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'SETTINGS',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: InkWell(
          onTap: () async {
            final isBioMetricsAvailable =
                await localAuthentication.canCheckBiometrics;
            if (isBioMetricsAvailable) {
              bool isAuthenticate = await localAuthentication.authenticate(
                  localizedReason: 'Authenticate for JMM Quiz');
              Fluttertoast.showToast(msg: 'FingerPrintValid');
            } else {
              Fluttertoast.showToast(msg: 'InValid');
            }
            //add biometrics
          },
          child: Container(
            width: 150,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Center(
              child: Row(
                children: [
                  SizedBox(
                    width: 6,
                  ),
                  Icon(
                    Icons.fingerprint,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Add Biometrics',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
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
