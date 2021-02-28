import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:interest_cal/UI/display_transactions.dart';
import 'package:interest_cal/service/SizeConfig.dart';
import 'package:interest_cal/service/widget.dart';

class Payment extends StatefulWidget {
  String name, key0;
  double intrest;
  Payment({this.name, this.key0, this.intrest});
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final formKey = GlobalKey<FormState>();

  final referenceDatase = FirebaseDatabase.instance;

  TextEditingController ammountTextEdittingController =
      new TextEditingController();

  DateTime todayDate = DateTime.now();
  DateTime paymentDate = DateTime.now();

  int transactions, transaction;
  double totalAmmount;
  bool processs = false;

  List<String> _months = [
    "months",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  Future<Null> _paymentDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: todayDate,
      firstDate: DateTime(1800, 8, 19),
      lastDate: todayDate,
      fieldHintText: "DD/MM/YYYY",
      errorFormatText: "Invalid Format",
      errorInvalidText: "Invalid Text",
      fieldLabelText: "Enter Date",
      helpText: "From",
    );
    if (picked != null) {
      setState(() {
        paymentDate = picked;
      });
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    void _saveData() {
      User user = FirebaseAuth.instance.currentUser;
      final fb = FirebaseDatabase.instance.reference().child("My Data");

      fb
          .child("${user.uid}/Pending/${widget.name}/${widget.key0}")
          .once()
          .then((DataSnapshot value1) {
        var data3 = value1.value;

        if (data3["Payed Amount"] == "0") {
          fb
              .child(
                  "${user.uid}/Pending/${widget.name}/${widget.key0}/History")
              .set({
            "Counter": "1",
          }).then((value) {
            fb
                .child(
                    "${user.uid}/Pending/${widget.name}/${widget.key0}/History/1")
                .set({
              "Date": paymentDate.toString(),
              "Payed Amount": ammountTextEdittingController.text,
            });
          });
        } else {
          fb
              .child(
                  "${user.uid}/Pending/${widget.name}/${widget.key0}/History")
              .once()
              .then((DataSnapshot value2) {
            var data2 = value2.value;
            int temp = (int.parse(data2["Counter"]) + 1);

            fb
                .child(
                    "${user.uid}/Pending/${widget.name}/${widget.key0}/History")
                .update({
              "Counter": "${temp}",
            }).then((value) {
              fb
                  .child(
                      "${user.uid}/Pending/${widget.name}/${widget.key0}/History/${temp.toString()}")
                  .set({
                "Date": paymentDate.toString(),
                "Payed Amount":ammountTextEdittingController.text,
              });
            });
          });
        }
      }).then((value) {
        fb
            .child("${user.uid}/Pending/${widget.name}/${widget.key0}")
            .once()
            .then((DataSnapshot value1) {
          var data = value1.value;
          double temp = widget.intrest - double.parse(data["Payed Intrest"]);

          if (temp >= double.parse(ammountTextEdittingController.text)) {
            fb
                .child("${user.uid}/Pending/${widget.name}/${widget.key0}")
                .update({
              "Payed Amount":
                  "${double.parse(data["Payed Amount"]) + double.parse(ammountTextEdittingController.text)}",
              "Last Payment Date": paymentDate.toString(),
              "Current Intrest": widget.intrest.toString(),
              "Payed Intrest":
                  "${double.parse(data["Payed Intrest"]) + double.parse(ammountTextEdittingController.text)}"
            }).then((value) {
              setState(() {
                processs = false;
              });
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => DisplayPendingTransactions(
                    name: widget.name,
                  ),
                ),
              );
            }).catchError((onError) {
              print(onError);
            });
          } else {
            fb
                .child("${user.uid}/Pending/${widget.name}/${widget.key0}")
                .update({
              "Payed Amount":
                  "${double.parse(data["Payed Amount"]) + double.parse(ammountTextEdittingController.text)}",
              "Last Payment Date": paymentDate.toString(),
              "Current Intrest": widget.intrest.toString(),
              "Payed Intrest": "${double.parse(data["Payed Intrest"]) + temp}",
              "Actual Amount":
                  "${double.parse(data["Actual Amount"]) - double.parse(ammountTextEdittingController.text) + temp}",
            }).then((value) {
              setState(() {
                processs = false;
              });
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                    builder: (_) => DisplayPendingTransactions(
                          name: widget.name,
                        )),
              );
            }).catchError((onError) {
              print(onError);
            });
          }
        }).catchError((onError) {
          print(onError);
        });
      }).catchError((onError) {
        print(onError);
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: FlatButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => DisplayPendingTransactions(
                  name: widget.name,
                ),
              ),
            );
          },
          child: Icon(
            Icons.clear,
            color: Colors.white,
          ),
        ),
        title: Text("PAYMENT"),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              if (formKey.currentState.validate() &&
                  ammountTextEdittingController.text != "" &&
                  paymentDate != null) {
                setState(() {
                  processs = !processs;
                });
                _saveData();
              } else {
                final snackBar = SnackBar(
                  content: Text('Feel all values'),
                );
                _scaffoldKey.currentState.showSnackBar(snackBar);
              }
            },
            child: Center(
              child: Text(
                "DONE",
                style: simpleTextStyle(),
              ),
              widthFactor: 2,
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            Opacity(
              opacity: processs ? 0.5 : 1.0,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: ammountTextEdittingController,
                      validator: (val) {
                        return val.isNotEmpty && isNumeric(val)
                            ? null
                            : "Please Enter Correct Value";
                      },
                      keyboardType: TextInputType.number,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDacorationWithIcon(
                          "Enter Ammount", MaterialCommunityIcons.currency_inr),
                    ),
                    GestureDetector(
                      onTap: () {
                        _paymentDatePicker(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical * 3,
                            horizontal: SizeConfig.safeBlockHorizontal * 3),
                        child: Row(
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AutoSizeText("Payment Date"),
                            Spacer(),
                            AutoSizeText(
                              paymentDate != null
                                  ? "${paymentDate.day} ${_months[paymentDate.month]} ${paymentDate.year}"
                                  : "DD - MM - YYYY",
                              style: paymentDate == null
                                  ? TextStyle(color: Colors.white54)
                                  : null,
                              textAlign: TextAlign.center,
                            ),
                            Icon(
                              Octicons.calendar,
                              size: 35,
                              color: Colors.cyanAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            processs ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
    );
  }
}
