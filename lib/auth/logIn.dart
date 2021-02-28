import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:interest_cal/UI/home_page.dart';
import 'file:///D:/Study/Flutter/interest_cal/lib/service/SizeConfig.dart';
import 'package:interest_cal/auth/forgotPasword.dart';
import 'package:interest_cal/auth/signUp.dart';
import 'file:///D:/Study/Flutter/interest_cal/lib/service/widget.dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final formKey = GlobalKey<FormState>();

  bool passwordCorection = true;
  bool emailExist = true;

  bool prosses = false;

  TextEditingController emailTextEdittingController =
  new TextEditingController();
  TextEditingController passwordTextEdittingController =
  new TextEditingController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        children: [
          prosses ? Center(child: CircularProgressIndicator()) : Container(),
          SingleChildScrollView(
            child: Opacity(
              opacity: prosses ? 0.5 : 1.0,
              child: Container(
                height: SizeConfig.screenHeight,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      "Welcome Back",
                      style: largeTextStyle(),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 3),
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
                          TextFormField(
                            obscureText: true,
                            validator: (val) {
                              return val.length > 6
                                  ? null
                                  : "Please provide password 6+ charater";
                            },
                            controller: passwordTextEdittingController,
                            style: simpleTextStyle(),
                            decoration: textFieldInputDacoration("Password"),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => ForgotPasswordPage()),
                        );
                      },
                      child: Align(
                        alignment: Alignment.bottomRight,
                        heightFactor: 1.5,
                        child: Text(
                          "Forgot Password  ",
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 3),
                    RaisedButton(
                      onPressed: () {
                        if (formKey.currentState.validate()) {
                          signInWithEmailAndPassword(emailTextEdittingController.text, passwordTextEdittingController.text);
                        }
                      },
                      child: Text(
                        "LOG IN",
                        style: mediumTextStyle(),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't Have An Account? ",
                          style: TextStyle(fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(builder: (_) => SignUpPage()),
                            );
                          },
                          child: Text(
                            "SignUp",
                            style: TextStyle(color: Colors.red, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    setState(() {
      prosses = true;
    });
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).catchError((value) {
        setState(() {
          prosses = false;
        });
      });
      print("sign in done");
      if (userCredential != null) {
        setState(() {
          prosses = false;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        setState(() {
          emailExist = false;
        });
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        setState(() {
          passwordCorection = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        emailExist = false;
      });
    }
  }
}
