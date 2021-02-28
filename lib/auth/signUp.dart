import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:interest_cal/UI/home_page.dart';
import 'file:///D:/Study/Flutter/interest_cal/lib/service/SizeConfig.dart';
import 'package:interest_cal/auth/logIn.dart';
import 'file:///D:/Study/Flutter/interest_cal/lib/service/widget.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  bool passwordError = false;
  bool emailExist = false;

  bool prosses = false;

  final referenceDatase = FirebaseDatabase.instance;

  TextEditingController userNameTextEdittingController =
      new TextEditingController();
  TextEditingController emailTextEdittingController =
      new TextEditingController();
  TextEditingController passwordTextEdittingController =
      new TextEditingController();
  TextEditingController confirmPasswordTextEdittingController =
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      "Create Account",
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
                            validator: (val) {
                              return val.isEmpty || val.length < 2
                                  ? "Please provide a valid username"
                                  : null;
                            },
                            controller: userNameTextEdittingController,
                            style: simpleTextStyle(),
                            decoration: textFieldInputDacoration("Your Name"),
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
                          TextFormField(
                            validator: (val) {
                              return val == passwordTextEdittingController.text
                                  ? null
                                  : "Password is not same";
                            },
                            controller: confirmPasswordTextEdittingController,
                            style: simpleTextStyle(),
                            decoration:
                                textFieldInputDacoration("Confirm Password"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 4),
                    RaisedButton(
                      onPressed: () {
                        if (formKey.currentState.validate()) {
                          signUpwithEmailAndPassword(
                              emailTextEdittingController.text,
                              passwordTextEdittingController.text);
                        }
                      },
                      child: Text(
                        "SIGN UP",
                        style: mediumTextStyle(),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    GestureDetector(
                      onTap: () {
                        linkGoogleAndTwitter(context);
                      },
                      child: Text(
                        "SingIn with google !!!",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already Have An Account? ",
                          style: TextStyle(fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                  builder: (_) => LogInPage()),
                            );
                          },
                          child: Text(
                            "LogIn",
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

  Future signUpwithEmailAndPassword(String email, String password) async {
    final ref = referenceDatase.reference().child("My Data");
    setState(() {
      prosses = true;
    });
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("your Sing Up done");
      if (userCredential != null) {
        User user = await FirebaseAuth.instance.currentUser;
        ref.child(user.uid).child("Personal Data").set({
          "name": userNameTextEdittingController.text,
          "email": emailTextEdittingController.text,
          "password": passwordTextEdittingController.text,
        }).then((value) {
          setState(() {
            prosses = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => HomePage()),
          );
        }).catchError((onError) {
          setState(() {
            prosses = false;
          });
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        setState(() {
          passwordError = true;
        });
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for email.');
        setState(() {
          emailExist = true;
        });
      } else if (e.code == "invalid-email") {
        print("invalid Email ID");
        setState(() {
          emailExist = true;
        });
      }
    } catch (e) {
      print("invalid Email ID333");
      setState(() {
        emailExist = true;
      });
    }
  }

  Future<void> linkGoogleAndTwitter(BuildContext context) async {
    final ref = referenceDatase.reference().child("My Data");
    setState(() {
      prosses = true;
    });
    // Trigger the Google Authentication flow.
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request.
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    // Create a new credential.
    final GoogleAuthCredential googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Sign in to Firebase with the Google [UserCredential].
    final UserCredential googleUserCredential = await FirebaseAuth.instance
        .signInWithCredential(googleCredential)
        .catchError((onError) {
      setState(() {
        prosses = false;
      });
    });
    if (googleUserCredential != null) {
      User user = await FirebaseAuth.instance.currentUser;
      ref.child(user.uid).child("Personal Data").set({
        "name": googleUser.displayName,
        "email": googleUser.email,
        "photo": googleUser.photoUrl,
      }).then((value) {
        setState(() {
          prosses = false;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => HomePage()),
        );
      }).catchError((onError) {
        setState(() {
          prosses = false;
        });
      });
    }
  }
}
