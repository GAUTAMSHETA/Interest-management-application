import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:interest_cal/UI/display_transactions.dart';
import 'package:interest_cal/UI/home_page.dart';
import 'package:interest_cal/service/SizeConfig.dart';
import 'package:interest_cal/service/widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class AddTransactionForDifferentPerson extends StatefulWidget {
  AddTransactionForDifferentPerson({this.app});
  final FirebaseApp app;

  @override
  _AddTransactionForDifferentPersonState createState() =>
      _AddTransactionForDifferentPersonState();
}

class _AddTransactionForDifferentPersonState
    extends State<AddTransactionForDifferentPerson> {
  final formKey = GlobalKey<FormState>();

  final referenceDatase = FirebaseDatabase.instance;

  TextEditingController nameTextEdittingController =
      new TextEditingController();
  TextEditingController ammountTextEdittingController =
      new TextEditingController();
  TextEditingController interestTextEdittingController =
      new TextEditingController();

  final pendingName = "Pending";

  DateTime todayDate = DateTime.now();
  DateTime fromDate = null;
  DateTime toDate = null;
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

  Future<Null> _fromDatePicker(BuildContext context) async {
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
        fromDate = picked;
      });
    }
  }

  Future<Null> _toDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: todayDate,
      firstDate: todayDate,
      lastDate: DateTime(2300, 8, 19),
      fieldHintText: "DD/MM/YYYY",
      errorFormatText: "Invalid Format",
      errorInvalidText: "Invalid Text",
      fieldLabelText: "Enter Date",
      helpText: "to",
    );
    if (picked != null) {
      setState(() {
        toDate = picked;
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
      final ref = referenceDatase.reference().child("My Data");

      ref.child("${user.uid}/Pending/${nameTextEdittingController.text}").set({
        "Customer Name": nameTextEdittingController.text,
        "Transactions": "1",
        "Transaction": "1",
        "Total Ammount": ammountTextEdittingController.text
      });
      ref
          .child("${user.uid}/Pending/${nameTextEdittingController.text}/1")
          .set({
        "Ammount": ammountTextEdittingController.text,
        "Interest": interestTextEdittingController.text,
        "From": fromDate.toString(),
        "To": toDate.toString(),
        "Actual Amount" : ammountTextEdittingController.text,
        "Current Intrest" : "0",
        "Last Payment Date" : fromDate.toString(),
        "Payed Amount" : "0",
        "Payed Intrest" : "0",
      }).then((_) {
        nameTextEdittingController.clear();
        ammountTextEdittingController.clear();
        interestTextEdittingController.clear();
        setState(() {
          toDate = null;
          fromDate = null;
          processs = !processs;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => HomePage(),
          ),
        );
      }).catchError((onError) {
        final snackBar = SnackBar(
          content: Text('Error'),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
        setState(() {
          processs = !processs;
        });
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("ADD TRANSACTION"),
        actions: [
          GestureDetector(
            onTap: () {
              if (formKey.currentState.validate() &&
                  nameTextEdittingController.text != "" &&
                  ammountTextEdittingController.text != "" &&
                  interestTextEdittingController.text != "" &&
                  fromDate != null &&
                  toDate != null) {
                setState(() {
                  processs = !processs;
                });
                _saveData();
              } else {
                final snackBar = SnackBar(
                  content: Text('Feel all values curectly'),
                );
                _scaffoldKey.currentState.showSnackBar(snackBar);
              }
            },
            child: Center(
              child: Text(
                "SAVE",
                style: simpleTextStyle(),
              ),
              widthFactor: 2,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          children: [
            Opacity(
              opacity: processs ? 0.5 : 1.0,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameTextEdittingController,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDacorationWithIcon(
                          "Enter Name", MaterialCommunityIcons.account_group),
                    ),
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
                    TextFormField(
                      controller: interestTextEdittingController,
                      validator: (val) {
                        return val.isNotEmpty && isNumeric(val)
                            ? null
                            : "Please Enter Correct Value";
                      },
                      keyboardType: TextInputType.number,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDacorationWithIcon(
                          "Enter Interest Rate",
                          MaterialCommunityIcons.percent),
                    ),
                    GestureDetector(
                      onTap: () {
                        _fromDatePicker(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical * 3,
                            horizontal: SizeConfig.safeBlockHorizontal * 3),
                        child: Row(
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AutoSizeText("From"),
                            Spacer(),
                            AutoSizeText(
                              fromDate != null
                                  ? "${fromDate.day} ${_months[fromDate.month]} ${fromDate.year}"
                                  : "DD - MM - YYYY",
                              style: fromDate == null
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
                    GestureDetector(
                      onTap: () {
                        _toDatePicker(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.safeBlockHorizontal * 3),
                        child: Row(
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AutoSizeText("To"),
                            Spacer(),
                            AutoSizeText(
                              toDate != null
                                  ? "${toDate.day} ${_months[toDate.month]} ${toDate.year}"
                                  : "DD - MM - YYYY",
                              style: toDate == null
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

class AddTransactionForSamePerson extends StatefulWidget {
  final String name;
  AddTransactionForSamePerson({this.name});

  @override
  _AddTransactionForSamePersonState createState() =>
      _AddTransactionForSamePersonState();
}

class _AddTransactionForSamePersonState
    extends State<AddTransactionForSamePerson> {
  final formKey = GlobalKey<FormState>();

  final referenceDatase = FirebaseDatabase.instance;

  TextEditingController ammountTextEdittingController =
      new TextEditingController();
  TextEditingController interestTextEdittingController =
      new TextEditingController();

  final pendingName = "Pending";

  DateTime todayDate = DateTime.now();
  DateTime fromDate = null;
  DateTime toDate = null;

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

  Future<Null> _fromDatePicker(BuildContext context) async {
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
        fromDate = picked;
      });
    }
  }

  Future<Null> _toDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: todayDate,
      firstDate: todayDate,
      lastDate: DateTime(2300, 8, 19),
      fieldHintText: "DD/MM/YYYY",
      errorFormatText: "Invalid Format",
      errorInvalidText: "Invalid Text",
      fieldLabelText: "Enter Date",
      helpText: "to",
    );
    if (picked != null) {
      setState(() {
        toDate = picked;
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
      final ref = referenceDatase.reference().child("My Data");
      final fb = FirebaseDatabase.instance.reference().child("My Data");

      fb
          .child("${user.uid}/Pending/${widget.name}")
          .once()
          .then((DataSnapshot snap) {
        var data = snap.value;
        setState(() {
          transactions = int.parse(data["Transactions"]);
          transaction = int.parse(data["Transaction"]);
          totalAmmount = double.parse(data["Total Ammount"]);
        });
      }).then((value) {
        ref.child("${user.uid}/Pending/${widget.name}").update({
          "Transactions": "${transactions + 1}",
          "Transaction": "${transaction + 1}",
          "Total Ammount":
              "${totalAmmount + double.parse(ammountTextEdittingController.text)}"
        }).then((value) {
          ref
              .child(
                  "${user.uid}/Pending/${widget.name}/${(transaction + 1).toString()}")
              .set({
            "Ammount": ammountTextEdittingController.text,
            "Interest": interestTextEdittingController.text,
            "From": fromDate.toString(),
            "To": toDate.toString(),
            "Actual Amount" : ammountTextEdittingController.text,
            "Current Intrest" : "0",
            "Last Payment Date" : fromDate.toString(),
            "Payed Amount" : "0",
            "Payed Intrest" : "0",
          }).then((value) {
            ammountTextEdittingController.clear();
            interestTextEdittingController.clear();
            setState(() {
              toDate = null;
              fromDate = null;
              processs = !processs;
            });

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => DisplayPendingTransactions(
                        name: widget.name,
                      )),
            );
          }).catchError((onError) {
            final snackBar = SnackBar(
              content: Text('Error 1'),
            );
            _scaffoldKey.currentState.showSnackBar(snackBar);
          });
        }).catchError((onError) {
          final snackBar = SnackBar(
            content: Text('Error 2'),
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);
        });
      }).catchError((onError) {
        print(onError);
        final snackBar = SnackBar(
          content: Text('Error 3'),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("ADD TRANSACTION"),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              if (formKey.currentState.validate() &&
                  ammountTextEdittingController.text != "" &&
                  interestTextEdittingController.text != "" &&
                  fromDate != null &&
                  toDate != null) {
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
                "SAVE",
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
                    TextFormField(
                      controller: interestTextEdittingController,
                      validator: (val) {
                        return val.isNotEmpty && isNumeric(val)
                            ? null
                            : "Please Enter Correct Value";
                      },
                      keyboardType: TextInputType.number,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDacorationWithIcon(
                          "Enter Interest Rate",
                          MaterialCommunityIcons.percent),
                    ),
                    GestureDetector(
                      onTap: () {
                        _fromDatePicker(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical * 3,
                            horizontal: SizeConfig.safeBlockHorizontal * 3),
                        child: Row(
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AutoSizeText("From"),
                            Spacer(),
                            AutoSizeText(
                              fromDate != null
                                  ? "${fromDate.day} ${_months[fromDate.month]} ${fromDate.year}"
                                  : "DD - MM - YYYY",
                              style: fromDate == null
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
                    GestureDetector(
                      onTap: () {
                        _toDatePicker(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.safeBlockHorizontal * 3),
                        child: Row(
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AutoSizeText("To"),
                            Spacer(),
                            AutoSizeText(
                              toDate != null
                                  ? "${toDate.day} ${_months[toDate.month]} ${toDate.year}"
                                  : "DD - MM - YYYY",
                              style: toDate == null
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

class EditTransaction extends StatefulWidget {
  double ammount, rate;
  DateTime from, to;
  String name, key0;
  EditTransaction(
      {this.ammount, this.rate, this.from, this.to, this.name, this.key0});
  @override
  _EditTransactionState createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  final formKey = GlobalKey<FormState>();

  final referenceDatase = FirebaseDatabase.instance;

  TextEditingController ammountTextEdittingController =
      new TextEditingController();
  TextEditingController interestTextEdittingController =
      new TextEditingController();

  DateTime todayDate = DateTime.now();
  DateTime fromDate = null;
  DateTime toDate = null;

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

  Future<Null> _fromDatePicker(BuildContext context) async {
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
        fromDate = picked;
      });
    }
  }

  Future<Null> _toDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: todayDate,
      firstDate: todayDate,
      lastDate: DateTime(2300, 8, 19),
      fieldHintText: "DD/MM/YYYY",
      errorFormatText: "Invalid Format",
      errorInvalidText: "Invalid Text",
      fieldLabelText: "Enter Date",
      helpText: "to",
    );
    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fromDate = widget.from;
    toDate = widget.to;
    ammountTextEdittingController.text = "${widget.ammount}";
    interestTextEdittingController.text = "${widget.rate}";
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
      double tam,am;

      fb.child("${user.uid}/Pending/${widget.name}/${widget.key0}").update({
        "Ammount": ammountTextEdittingController.text,
        "Interest": interestTextEdittingController.text,
        "From": fromDate.toString(),
        "To": toDate.toString(),
      }).then((value) {
        fb
            .child("${user.uid}/Pending/${widget.name}")
            .once()
            .then((DataSnapshot value) {
          tam = double.parse(value.value["Total Ammount"]);
          am = double.parse(value.value["Actual Amount"]);
        }).then((value) {
          fb.child("${user.uid}/Pending/${widget.name}").update({
            "Total Ammount":
                "${tam - widget.ammount + double.parse(ammountTextEdittingController.text)}",
            "Actual Amount" : "${am - widget.ammount + double.parse(ammountTextEdittingController.text)}",
          });
        }).then((value) {
          setState(() {
            processs = false;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                  builder: (_) =>
                      DisplayPendingTransactions(name: widget.name)),
            );
          });
        });
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: FlatButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) =>
                      DisplayPendingTransactions(name: widget.name)),
            );
          },
          child: Icon(
            Icons.clear,
            color: Colors.white,
          ),
        ),
        title: Text("EDIT TRANSACTION"),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              if (formKey.currentState.validate() &&
                  ammountTextEdittingController.text != "" &&
                  interestTextEdittingController.text != "" &&
                  fromDate != null &&
                  toDate != null) {
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
                "SAVE",
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
                    TextFormField(
                      controller: interestTextEdittingController,
                      validator: (val) {
                        return val.isNotEmpty && isNumeric(val)
                            ? null
                            : "Please Enter Correct Value";
                      },
                      keyboardType: TextInputType.number,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDacorationWithIcon(
                          "Enter Interest Rate",
                          MaterialCommunityIcons.percent),
                    ),
                    GestureDetector(
                      onTap: () {
                        _fromDatePicker(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical * 3,
                            horizontal: SizeConfig.safeBlockHorizontal * 3),
                        child: Row(
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AutoSizeText("From"),
                            Spacer(),
                            AutoSizeText(
                              fromDate != null
                                  ? "${fromDate.day} ${_months[fromDate.month]} ${fromDate.year}"
                                  : "DD - MM - YYYY",
                              style: fromDate == null
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
                    GestureDetector(
                      onTap: () {
                        _toDatePicker(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.safeBlockHorizontal * 3),
                        child: Row(
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AutoSizeText("To"),
                            Spacer(),
                            AutoSizeText(
                              toDate != null
                                  ? "${toDate.day} ${_months[toDate.month]} ${toDate.year}"
                                  : "DD - MM - YYYY",
                              style: toDate == null
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
