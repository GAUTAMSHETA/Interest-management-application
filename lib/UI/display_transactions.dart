import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:interest_cal/UI/add_transaction.dart';
import 'package:interest_cal/UI/home_page.dart';
import 'package:interest_cal/UI/payment.dart';
import 'package:interest_cal/service/SizeConfig.dart';
import 'package:interest_cal/service/database_service/data_classes.dart';

class DisplayPendingTransactions extends StatefulWidget {
  final String name;
  DisplayPendingTransactions({this.name});
  @override
  _DisplayPendingTransactionsState createState() =>
      _DisplayPendingTransactionsState();
}

class _DisplayPendingTransactionsState
    extends State<DisplayPendingTransactions> {
  User user = FirebaseAuth.instance.currentUser;
  final fb = FirebaseDatabase.instance.reference().child("My Data");
  List<PersonAllData> list = List();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool process = false;

  @override
  void initState() {
    super.initState();
    fb
        .child("${user.uid}/Pending/${widget.name}")
        .orderByKey()
        .once()
        .then((DataSnapshot snap) {
      var data = snap.value;
      list.clear();
      data.forEach((key, value) {
        if (key.toString().length <= 7) {
          String from = value["From"];
          String to = value["To"];
          String lastPaymentDate = value["Last Payment Date"];

          String dateWithFrom =
              from.substring(0, 10) + 'T' + from.substring(11);
          String dateWithTo = to.substring(0, 10) + 'T' + to.substring(11);
          String dateWithlastPaymentDate = lastPaymentDate.substring(0, 10) +
              'T' +
              lastPaymentDate.substring(11);

          DateTime dateTimeFrom = DateTime.parse(dateWithFrom);
          DateTime dateTimeTo = DateTime.parse(dateWithTo);
          DateTime dateTimeLastPaymentDate =
              DateTime.parse(dateWithlastPaymentDate);

          PersonAllData personAllData = new PersonAllData(
            ammount: double.parse(value["Ammount"]),
            rate: double.parse(value["Interest"]),
            fromDate: dateTimeFrom,
            toDate: dateTimeTo,
            actualAmount: double.parse(value["Actual Amount"]),
            lastPaymentInterast: double.parse(value["Current Intrest"]),
            lastPaymentDate: dateTimeLastPaymentDate,
            payedAmount: double.parse(value["Payed Amount"]),
            payedIntrest: double.parse(value["Payed Intrest"]),
            key: key,
          );
          list.add(personAllData);
        }
      });
      setState(() {});
    });
  }

  void _delete(int index) {
    int test;
    double am, tm;

    fb
        .child("${user.uid}/Pending/${widget.name}")
        .once()
        .then((DataSnapshot snap) {
      var data = snap.value;
      test = int.parse(data["Transactions"]);
      tm = double.parse(data["Total Ammount"]);
      am = double.parse(data[list[index].key]["Ammount"]);
    }).then((value) {
      fb
          .child("${user.uid}/Pending/${widget.name}/${list[index].key}")
          .remove()
          .then((value) {
        fb.child("${user.uid}/Pending/${widget.name}").update({
          "Transactions": "${test - 1}",
          "Total Ammount": "${tm - am}",
        }).then((value) {
          setState(() {
            list.removeAt(index);
            process = false;
          });
          if (test - 1 == 0) {
            fb
                .child("${user.uid}/Pending/${widget.name}")
                .remove()
                .then((value) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => HomePage()),
              );
            });
          }
        }).catchError((onError) {
          final snackBar = SnackBar(
            content: Text('Error 2'),
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
      final snackBar = SnackBar(
        content: Text('Error 2'),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    });
  }

  void _done(int index) {
    int t;
    var data;

    fb
        .child("${user.uid}/Pending/${widget.name}/${list[index].key}")
        .once()
        .then((value) {
      fb.child("${user.uid}/Complete/${widget.name}").once().then((valueName) {
        print(valueName.value);
        if (valueName.value == null) {
          fb
              .child("${user.uid}/Complete/${widget.name}/1")
              .set(value.value)
              .then((value7) {
            fb
                .child("${user.uid}/Complete/${widget.name}/1")
                .update({"To": DateTime.now().toString()});
          }).then((value6) {
            fb.child("${user.uid}/Complete/${widget.name}").update({
              "Total Ammount": value.value["Ammount"],
              "Transactions": "1",
              "Transaction": "1",
              "Customer Name": widget.name
            }).then((value) => _delete(index));
          });
        } else {
          fb
              .child("${user.uid}/Complete/${widget.name}")
              .once()
              .then((valueTra) {
            data = valueTra.value;
            t = int.parse(valueTra.value["Transaction"]);
          }).then((value3) {
            fb
                .child("${user.uid}/Complete/${widget.name}/${t + 1}")
                .set(value.value);
          }).then((value7) {
            fb
                .child("${user.uid}/Complete/${widget.name}/1")
                .update({"To": DateTime.now().toString()});
          }).then((value7) {
            fb.child("${user.uid}/Complete/${widget.name}").update({
              "Total Ammount":
                  "${double.parse(data["Total Ammount"]) + double.parse(value.value["Ammount"])}",
              "Transactions": "${int.parse(data["Transactions"]) + 1}",
              "Transaction": "${int.parse(data["Transaction"]) + 1}",
            }).then((value) => _delete(index));
          });
        }
      });
    });
  }

  Widget _card(int index) {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal * 2,
          vertical: SizeConfig.safeBlockVertical * 1),
      shadowColor: Colors.white54,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => Payment(
                          name: widget.name,
                          key0: list[index].key,
                          intrest: list[index].cuttentInterest,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      SizedBox(width: SizeConfig.safeBlockHorizontal * 4),
                      Icon(Icons.payment, color: Colors.cyan),
                      SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
                      AutoSizeText(
                        "Pay",
                        style: TextStyle(color: Colors.cyan),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EditTransaction(
                          name: widget.name,
                          ammount: list[index].ammount,
                          rate: list[index].rate,
                          from: list[index].fromDate,
                          to: list[index].toDate,
                          key0: list[index].key,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Octicons.pencil,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      process = true;
                    });
                    _delete(index);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      process = true;
                    });
                    _done(index);
                  },
                  icon: Icon(
                    Icons.done_outline_sharp,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => DisplayHistory(
                                amount: list[index].ammount,
                                rate: list[index].rate,
                                givenDate: list[index].fromDate,
                                lastDate: list[index].toDate,
                                payedAmount: list[index].payedAmount,
                                payedInteret: list[index].payedIntrest,
                                currentInterest: list[index].cuttentInterest,
                                name: widget.name,
                                key0: list[index].key,
                              )),
                    );
                  },
                  icon: Icon(
                    Icons.history,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: SizeConfig.safeBlockHorizontal * 4),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _listTail("Amount", "${list[index].ammount}",
                        MaterialCommunityIcons.currency_inr, null),
                    _listTail(
                        "Given Date",
                        "${list[index].fromDate.day}/${list[index].fromDate.month}/${list[index].fromDate.year}",
                        Octicons.calendar,
                        null),
                    _listTail(
                        "Current Interest",
                        "₹ ${list[index].cuttentInterest}",
                        MaterialCommunityIcons.percent,
                        null),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _listTail("Rate", "${list[index].rate} %",
                        MaterialCommunityIcons.percent, null),
                    _listTail(
                        "Last Date",
                        "${list[index].toDate.day}/${list[index].toDate.month}/${list[index].toDate.year}",
                        Octicons.calendar,
                        null),
                    _listTail("Total Day", "${list[index].totalDay} Day",
                        MaterialCommunityIcons.alarm, null),
                  ],
                ),
              ],
            ),
            Divider(
              color: Colors.black54,
              endIndent: SizeConfig.safeBlockHorizontal * 4,
              indent: SizeConfig.safeBlockHorizontal * 4,
              height: SizeConfig.safeBlockHorizontal * 1,
            ),
            Column(
              children: [
                _listTail("Remaining Amount",
                    "${list[index].remainingAmount} ₹", null, Colors.redAccent),
                _listTail("Payed Amount", "${list[index].payedAmount}0 ₹", null,
                    Colors.green),
                _listTail("Total Amount", "${list[index].totalAmount} ₹", null,
                    Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listTail(String tital, String subTital, IconData icon, Color color) {
    if (icon == null) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal * 7,
          vertical: SizeConfig.safeBlockVertical * 0.6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              tital,
              style: TextStyle(color: color),
            ),
            Spacer(),
            Text(
              subTital,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: SizeConfig.safeBlockVertical * 1.3,
          horizontal: SizeConfig.safeBlockHorizontal * 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.black,
          ),
          SizedBox(width: SizeConfig.safeBlockHorizontal * 1.5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tital,
                style: TextStyle(color: Colors.black),
              ),
              Text(
                subTital,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        leading: FlatButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => HomePage(),
              ),
            );
          },
          child: Icon(Icons.clear),
        ),
        shadowColor: Colors.white54,
        title: AutoSizeText(
          "ALL TRANSACTION",
          overflow: TextOverflow.visible,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AddTransactionForSamePerson(
                name: widget.name,
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
        mini: true,
        isExtended: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: list.length == 0
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                process
                    ? Center(child: CircularProgressIndicator())
                    : Container(),
                Opacity(
                  opacity: process ? 0.5 : 1.0,
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, index) {
                      return _card(index);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class DisplayCompleteTransactions extends StatefulWidget {
  final String name;
  DisplayCompleteTransactions({this.name});
  @override
  _DisplayCompleteTransactionsState createState() =>
      _DisplayCompleteTransactionsState();
}

class _DisplayCompleteTransactionsState
    extends State<DisplayCompleteTransactions> {
  User user = FirebaseAuth.instance.currentUser;
  final fb = FirebaseDatabase.instance.reference().child("My Data");
  List<PersonCompleteData> list = List();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool process = false;

  @override
  void initState() {
    super.initState();
    fb
        .child("${user.uid}/Complete/${widget.name}")
        .orderByKey()
        .once()
        .then((DataSnapshot snap) {
      var data = snap.value;
      list.clear();
      data.forEach((key, value) {
        if (key.toString().length <= 7) {
          String from = value["From"];
          String to = value["To"];
          String lastPaymentDate = value["Last Payment Date"];

          String dateWithFrom =
              from.substring(0, 10) + 'T' + from.substring(11);
          String dateWithTo = to.substring(0, 10) + 'T' + to.substring(11);
          String dateWithlastPaymentDate = lastPaymentDate.substring(0, 10) +
              'T' +
              lastPaymentDate.substring(11);

          DateTime dateTimeFrom = DateTime.parse(dateWithFrom);
          DateTime dateTimeTo = DateTime.parse(dateWithTo);
          DateTime dateTimeLastPaymentDate =
              DateTime.parse(dateWithlastPaymentDate);

          PersonCompleteData personCompleteData = new PersonCompleteData(
            ammount: double.parse(value["Ammount"]),
            rate: double.parse(value["Interest"]),
            fromDate: dateTimeFrom,
            toDate: dateTimeTo,
            actualAmount: double.parse(value["Actual Amount"]),
            lastPaymentInterast: double.parse(value["Current Intrest"]),
            lastPaymentDate: dateTimeLastPaymentDate,
            payedAmount: double.parse(value["Payed Amount"]),
            payedIntrest: double.parse(value["Payed Intrest"]),
            key: key,
          );
          list.add(personCompleteData);
        }
      });
      setState(() {});
    });
  }

  void _delete(int index) {
    int test;
    double am, tm;

    fb
        .child("${user.uid}/Complete/${widget.name}")
        .once()
        .then((DataSnapshot snap) {
      var data = snap.value;
      test = int.parse(data["Transactions"]);
      tm = double.parse(data["Total Ammount"]);
      am = double.parse(data[list[index].key]["Ammount"]);
    }).then((value) {
      fb
          .child("${user.uid}/Complete/${widget.name}/${list[index].key}")
          .remove()
          .then((value) {
        fb.child("${user.uid}/Complete/${widget.name}").update({
          "Transactions": "${test - 1}",
          "Total Ammount": "${tm - am}",
        }).then((value) {
          setState(() {
            list.removeAt(index);
            process = false;
          });
          if (test - 1 == 0) {
            fb
                .child("${user.uid}/Complete/${widget.name}")
                .remove()
                .then((value) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => HomePage(index: 1)),
              );
            });
          }
        }).catchError((onError) {
          final snackBar = SnackBar(
            content: Text('Error 2'),
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
      final snackBar = SnackBar(
        content: Text('Error 2'),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    });
  }

  Widget _card(int index) {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal * 2,
          vertical: SizeConfig.safeBlockVertical * 1),
      shadowColor: Colors.white54,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      process = true;
                    });
                    _delete(index);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DisplayHistory(
                          amount: list[index].ammount,
                          rate: list[index].rate,
                          givenDate: list[index].fromDate,
                          lastDate: list[index].toDate,
                          payedAmount: list[index].payedAmount,
                          payedInteret: list[index].payedIntrest,
                          currentInterest: list[index].cuttentInterest,
                          name: widget.name,
                          key0: list[index].key,
                          flag: "History",
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.history,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: SizeConfig.safeBlockHorizontal * 4),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _listTail("Amount", "${list[index].ammount}",
                        MaterialCommunityIcons.currency_inr, null),
                    _listTail(
                        "Given Date",
                        "${list[index].fromDate.day}/${list[index].fromDate.month}/${list[index].fromDate.year}",
                        Octicons.calendar,
                        null),
                    _listTail(
                        "Current Interest",
                        "₹ ${list[index].cuttentInterest}",
                        MaterialCommunityIcons.percent,
                        null),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _listTail("Rate", "${list[index].rate} %",
                        MaterialCommunityIcons.percent, null),
                    _listTail(
                        "Last Date",
                        "${list[index].toDate.day}/${list[index].toDate.month}/${list[index].toDate.year}",
                        Octicons.calendar,
                        null),
                    _listTail("Total Day", "${list[index].totalDay} Day",
                        MaterialCommunityIcons.alarm, null),
                  ],
                ),
              ],
            ),
            Divider(
              color: Colors.black54,
              endIndent: SizeConfig.safeBlockHorizontal * 4,
              indent: SizeConfig.safeBlockHorizontal * 4,
              height: SizeConfig.safeBlockHorizontal * 1,
            ),
            Column(
              children: [
                _listTail("Remaining Amount",
                    "${list[index].remainingAmount} ₹", null, Colors.redAccent),
                _listTail("Payed Amount", "${list[index].payedAmount}0 ₹", null,
                    Colors.green),
                _listTail("Total Amount", "${list[index].totalAmount} ₹", null,
                    Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listTail(String tital, String subTital, IconData icon, Color color) {
    if (icon == null) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal * 7,
          vertical: SizeConfig.safeBlockVertical * 0.6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              tital,
              style: TextStyle(color: color),
            ),
            Spacer(),
            Text(
              subTital,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: SizeConfig.safeBlockVertical * 1.3,
          horizontal: SizeConfig.safeBlockHorizontal * 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.black,
          ),
          SizedBox(width: SizeConfig.safeBlockHorizontal * 1.5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tital,
                style: TextStyle(color: Colors.black),
              ),
              Text(
                subTital,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        leading: FlatButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => HomePage(index: 1),
              ),
            );
          },
          child: Icon(Icons.clear),
        ),
        shadowColor: Colors.white54,
        title: AutoSizeText(
          "ALL TRANSACTION",
          overflow: TextOverflow.visible,
        ),
      ),
      body: list.length == 0
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                process
                    ? Center(child: CircularProgressIndicator())
                    : Container(),
                Opacity(
                  opacity: process ? 0.5 : 1.0,
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, index) {
                      return _card(index);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class DisplayHistory extends StatefulWidget {
  String name, key0, flag;
  double amount, rate, currentInterest, payedInteret, payedAmount, rIntrest;
  DateTime givenDate, lastDate;
  DisplayHistory(
      {this.amount,
      this.rate,
      this.currentInterest,
      this.payedAmount,
      this.givenDate,
      this.lastDate,
      this.payedInteret,
      this.name,
      this.flag,
      this.key0}) {
    rIntrest = ((currentInterest - payedInteret) * 100).toInt() / 100;
  }
  @override
  _DisplayHistoryState createState() => _DisplayHistoryState();
}

class _DisplayHistoryState extends State<DisplayHistory> {
  User user = FirebaseAuth.instance.currentUser;
  final fb = FirebaseDatabase.instance.reference().child("My Data");
  List<History> list = List();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    if (widget.flag != "History") {
      fb
          .child("${user.uid}/Pending/${widget.name}/${widget.key0}/History")
          .orderByKey()
          .once()
          .then((DataSnapshot snap) {
        var data = snap.value;
        list.clear();
        print(data);
        data.forEach((key, value) {
          if (key.toString().length <= 6) {
            String from = value["Date"];

            String dateWithFrom =
                from.substring(0, 10) + 'T' + from.substring(11);

            DateTime dateTimeFrom = DateTime.parse(dateWithFrom);

            History history = new History(
              date: dateTimeFrom,
              amount: double.parse(value["Payed Amount"]),
            );
            list.add(history);
          }
        });
        setState(() {});
      });
    } else {
      fb
          .child("${user.uid}/Complete/${widget.name}/${widget.key0}/History")
          .orderByKey()
          .once()
          .then((DataSnapshot snap) {
        var data = snap.value;
        list.clear();
        print(data);
        data.forEach((key, value) {
          if (key.toString().length <= 6) {
            String from = value["Date"];

            String dateWithFrom =
                from.substring(0, 10) + 'T' + from.substring(11);

            DateTime dateTimeFrom = DateTime.parse(dateWithFrom);

            History history = new History(
              date: dateTimeFrom,
              amount: double.parse(value["Payed Amount"]),
            );
            list.add(history);
          }
        });
        setState(() {});
      });
    }
  }

  Widget _card2(int index) {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal * 2,
          vertical: SizeConfig.safeBlockVertical * 0.5),
      shadowColor: Colors.white54,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _listTail("Payed Amount", "${list[index].amount}",
                MaterialCommunityIcons.currency_inr, null),
            _listTail(
                "Given Date",
                "${list[index].date.day}/${list[index].date.month}/${list[index].date.year}",
                Octicons.calendar,
                null),
          ],
        ),
      ),
    );
  }

  Widget _card() {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal * 2,
          vertical: SizeConfig.safeBlockVertical * 1),
      shadowColor: Colors.white54,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _listTail("Amount", "${widget.amount}",
                        MaterialCommunityIcons.currency_inr, null),
                    _listTail(
                        "Given Date",
                        "${widget.givenDate.day}/${widget.givenDate.month}/${widget.givenDate.year}",
                        Octicons.calendar,
                        null),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _listTail("Rate", "${widget.rate} %",
                        MaterialCommunityIcons.percent, null),
                    _listTail(
                        "Last Date",
                        "${widget.lastDate.day}/${widget.lastDate.month}/${widget.lastDate.year}",
                        Octicons.calendar,
                        null),
                  ],
                ),
              ],
            ),
            Divider(
              color: Colors.black54,
              endIndent: SizeConfig.safeBlockHorizontal * 4,
              indent: SizeConfig.safeBlockHorizontal * 4,
              height: SizeConfig.safeBlockHorizontal * 1,
            ),
            Column(
              children: [
                _listTail("Remaining Intrest", "${widget.rIntrest} ₹", null,
                    Colors.redAccent),
                _listTail("Payed Intrest", "${widget.payedInteret} ₹", null,
                    Colors.green),
                _listTail("Total Intrest", "${widget.currentInterest} ₹", null,
                    Colors.black),
              ],
            ),
            Divider(
              color: Colors.black54,
              endIndent: SizeConfig.safeBlockHorizontal * 4,
              indent: SizeConfig.safeBlockHorizontal * 4,
              height: SizeConfig.safeBlockHorizontal * 1,
            ),
            Column(
              children: [
                _listTail(
                    "Remaining Amount",
                    "${widget.amount + widget.currentInterest - widget.payedAmount} ₹",
                    null,
                    Colors.redAccent),
                _listTail("Payed Amount", "${widget.payedAmount}0 ₹", null,
                    Colors.green),
                _listTail(
                    "Total Amount",
                    "${widget.amount + widget.currentInterest} ₹",
                    null,
                    Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listTail(String tital, String subTital, IconData icon, Color color) {
    if (icon == null) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal * 7,
          vertical: SizeConfig.safeBlockVertical * 0.6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              tital,
              style: TextStyle(color: color),
            ),
            Spacer(),
            Text(
              subTital,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: SizeConfig.safeBlockVertical * 1.3,
          horizontal: SizeConfig.safeBlockHorizontal * 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.black,
          ),
          SizedBox(width: SizeConfig.safeBlockHorizontal * 1.5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tital,
                style: TextStyle(color: Colors.black),
              ),
              Text(
                subTital,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white54,
        title: AutoSizeText(
          "HISTORY",
          overflow: TextOverflow.visible,
        ),
      ),
      body: Column(
        children: [
          _card(),
          list.length == 0
              ? Center(
                  heightFactor: SizeConfig.safeBlockVertical * 0.5,
                  child: Opacity(
                    opacity: 0.5,
                    child: Text(
                      "NO HISTORY",
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
              : Expanded(
                  child: Container(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        return _card2(index);
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
