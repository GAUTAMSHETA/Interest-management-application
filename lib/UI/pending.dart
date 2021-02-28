import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:interest_cal/UI/display_transactions.dart';
import 'package:interest_cal/UI/add_transaction.dart';
import 'package:interest_cal/service/SizeConfig.dart';
import 'package:interest_cal/service/database_service/data_classes.dart';

class PendingPage extends StatefulWidget {
  @override
  _PendingPageState createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage> {
  User user = FirebaseAuth.instance.currentUser;
  final fb = FirebaseDatabase.instance.reference().child("My Data");
  List<PendingData> list = List();

  @override
  void initState() {
    super.initState();
    fb.child("${user.uid}/Pending").once().then((DataSnapshot snap) {
      var data = snap.value;
      list.clear();
      data.forEach((key, value) {
        PendingData pendingData = new PendingData(
          transection: int.parse(value["Transactions"]),
          amount: double.parse(value["Total Ammount"]),
          name: value["Customer Name"],
          key: key,
        );
        list.add(pendingData);
      });
      setState(() {});
    });
  }

  Widget _card(int index) {
    return Card(
      elevation: 20,
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal * 2,
          vertical: SizeConfig.safeBlockVertical * 1),
      shadowColor: Colors.white54,
      color: Colors.white,
      child: ListTile(
        leading: Icon(
          Icons.account_circle,
          color: Colors.black12,
          size: 60,
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            list[index].name,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            "${list[index].transection} TRANSACTION",
            style: TextStyle(color: Colors.black54, fontSize: 10),
          ),
        ),
        trailing: Text(
          "₹ ${list[index].amount}",
          style: TextStyle(color: Colors.cyan),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: list.length == 0
          ? Center(
              child: Opacity(
                opacity: 0.3,
                child: Text(
                  "NO DATA",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2
                      ..color = Colors.white54,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => DisplayPendingTransactions(
                                name: list[index].name,
                              )),
                    );
                  },
                  child: _card(index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // final snackBar = SnackBar(
          //   content: Text('Email is not Register'),
          //   // action: SnackBarAction(
          //   //   label: " ",
          //   //   onPressed: () {
          //   //     // Some code to undo the change.
          //   //   },
          //   // ),
          // );
          // Scaffold.of(context).showSnackBar(snackBar);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
                builder: (_) => AddTransactionForDifferentPerson()),
          );
        },
        child: Icon(
          Icons.add,
          size: 40,
        ),
      ),
    );
  }
}
