import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:interest_cal/UI/complete.dart';
import 'package:interest_cal/UI/pending.dart';
import 'package:interest_cal/auth/logIn.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  int index;
  HomePage({this.index});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.index == null ? 0 : widget.index,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Home"),
          actions: [
            FlatButton(
              onPressed: (){
                if(signOut() != null){
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(builder: (_) => LogInPage()),
                      );
                }
              },
              child: Icon(Icons.logout),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "PENDING",),
              Tab(text: "COMPLETE",),
            ],
          ),
        ),

        body: TabBarView(
          children: <Widget>[
            PendingPage(),
            CompletePage(),
          ],
        ),

      ),
    );
  }

  Future signOut() async{
    try{
      print("Log Out");
      return await FirebaseAuth.instance.signOut();
    }catch(e){
      print(e.toString());
    }
  }

}
