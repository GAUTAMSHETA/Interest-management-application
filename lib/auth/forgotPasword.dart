import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'file:///D:/Study/Flutter/interest_cal/lib/service/SizeConfig.dart';
import 'file:///D:/Study/Flutter/interest_cal/lib/service/widget.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();

  TextEditingController emailTextEdittingController =
      new TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          height: SizeConfig.screenHeight,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (val) {
                        return RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~}+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val)
                            ? null
                            : "Please Enter Correct Email";
                      },
                      controller: emailTextEdittingController,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDacoration("Email ID"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 4),
              RaisedButton(
                onPressed: () {
                  try {
                    resetPassword(emailTextEdittingController.text);
                    final snackBar = SnackBar(
                      content: Text('Link Send Successfully'),
                    );
                    _scaffoldKey.currentState.showSnackBar(snackBar);
                  } catch (e) {
                    final snackBar = SnackBar(
                      content: Text('Email is not Register'),
                    );
                    _scaffoldKey.currentState.showSnackBar(snackBar);
                  }
                },
                child: Text(
                  "SEND LINK",
                  style: mediumTextStyle(),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> resetPassword(String email) async {
    var user = await FirebaseAuth.instance
      ..sendPasswordResetEmail(email: email);
    if (user != null) {
      print("Yesssssssssssssssssssssssssss");
    } else {
      print("NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
    }
  }
}
