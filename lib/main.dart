import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:interest_cal/auth/signUp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Interest Calcy",
      theme: ThemeData.dark(),
      color: Colors.white,
      // home: LogInPage(),
      home: SignUpPage(),
      // home: AddTransactionForDifferentPerson(),
    );
  }
}
