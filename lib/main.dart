import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jmm_quiz_app/UI/login.dart';
import 'package:jmm_quiz_app/services/auth_service.dart';
import 'package:jmm_quiz_app/services/user_service.dart';
import 'package:provider/provider.dart';

import 'const.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthService()),
        ChangeNotifierProvider.value(value: UserServices()),
      ],
      child: MaterialApp(
        title: 'Chat Demo',
        theme: ThemeData(
          primaryColor: themeColor,
        ),
        home: LoginScreen(title: 'CHAT DEMO'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
