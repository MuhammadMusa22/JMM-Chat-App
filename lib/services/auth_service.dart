import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jmm_quiz_app/UI/home.dart';
import 'package:jmm_quiz_app/model/user_chat.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences? prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  User? currentUser;

  BuildContext? providerContext;

  Future facebookLogin() async {
    bool _isLoggedIn = false;
    Map _userObj = {};

    FacebookAuth.instance
        .login(permissions: ["public_profile", "email"]).then((value) {
      FacebookAuth.instance.getUserData().then((userData) async {
        _userObj = userData;
        if (value.status == LoginStatus.success) {
          AuthCredential credential =
              FacebookAuthProvider.credential(value.accessToken!.token);
          User? firebaseUser =
              (await firebaseAuth.signInWithCredential(credential)).user;
          if (firebaseUser != null) {
            // Check is already sign up
            final QuerySnapshot result = await FirebaseFirestore.instance
                .collection('users')
                .where('id', isEqualTo: firebaseUser.uid)
                .get();
            final List<DocumentSnapshot> documents = result.docs;
            if (documents.length == 0) {
              // Update data to server if new user
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(firebaseUser.uid)
                  .set({
                'nickname': firebaseUser.displayName,
                'photoUrl': firebaseUser.photoURL,
                'id': firebaseUser.uid,
                'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
                'chattingWith': null
              });

              // Write data to local
              currentUser = firebaseUser;
              await prefs?.setString('id', currentUser!.uid);
              await prefs?.setString(
                  'nickname', currentUser!.displayName ?? "");
              await prefs?.setString('photoUrl', currentUser!.photoURL ?? "");
            } else {
              DocumentSnapshot documentSnapshot = documents[0];
              UserChat userChat = UserChat.fromDocument(documentSnapshot);
              // Write data to local
              await prefs?.setString('id', userChat.id);
              await prefs?.setString('nickname', userChat.nickname);
              await prefs?.setString('photoUrl', userChat.photoUrl);
              await prefs?.setString('aboutMe', userChat.aboutMe);
            }
            Fluttertoast.showToast(msg: "Sign in success");
            loadingFalse();

            Navigator.push(
                providerContext!,
                MaterialPageRoute(
                    builder: (context) =>
                        HomeScreen(currentUserId: firebaseUser.uid)));
          }
        }
      });
    });
  }

  void isSignedIn(BuildContext context) async {
    loadingTrue();
    providerContext = context;

    prefs = await SharedPreferences.getInstance();

    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn && prefs?.getString('id') != null) {
      Navigator.pushReplacement(
        providerContext!,
        MaterialPageRoute(
            builder: (providerContext) =>
                HomeScreen(currentUserId: prefs!.getString('id') ?? "")),
      );
    }

    loadingFalse();
  }

  Future<Null> googleLogin() async {
    prefs = await SharedPreferences.getInstance();

    loadingTrue();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        // Check is already sign up
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.length == 0) {
          // Update data to server if new user
          FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .set({
            'nickname': firebaseUser.displayName,
            'photoUrl': firebaseUser.photoURL,
            'id': firebaseUser.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            'chattingWith': null
          });

          // Write data to local
          currentUser = firebaseUser;
          await prefs?.setString('id', currentUser!.uid);
          await prefs?.setString('nickname', currentUser!.displayName ?? "");
          await prefs?.setString('photoUrl', currentUser!.photoURL ?? "");
        } else {
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          // Write data to local
          await prefs?.setString('id', userChat.id);
          await prefs?.setString('nickname', userChat.nickname);
          await prefs?.setString('photoUrl', userChat.photoUrl);
          await prefs?.setString('aboutMe', userChat.aboutMe);
        }
        Fluttertoast.showToast(msg: "Sign in success");
        loadingFalse();

        Navigator.push(
            providerContext!,
            MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(currentUserId: firebaseUser.uid)));
      } else {
        Fluttertoast.showToast(msg: "Sign in fail");
        loadingFalse();
      }
    } else {
      Fluttertoast.showToast(msg: "Can not init google sign in");
      loadingFalse();
    }
  }

  void loadingTrue() {
    isLoading = true;

    //notifyListeners();
  }

  void loadingFalse() {
    isLoading = false;

    //notifyListeners();
  }
}
