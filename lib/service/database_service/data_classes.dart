class PendingData {
  String name, key;
  int transection;
  double amount;

  PendingData({this.name, this.transection, this.amount, this.key});
}

class PersonAllData {
  int totalDay;
  double rate,
      ammount,
      cuttentInterest,
      lastPaymentInterast,
      actualAmount,
      payedAmount,
      payedIntrest,
      remainingAmount,
      totalAmount;
  DateTime fromDate, toDate, lastPaymentDate;
  String key;

  PersonAllData(
      {this.ammount,
      this.rate,
      this.fromDate,
      this.toDate,
      this.actualAmount,
      this.lastPaymentDate,
      this.lastPaymentInterast,
      this.payedAmount,
      this.payedIntrest,
      this.key}) {
    totalDay = DateTime.now().difference(fromDate).inDays;

    int day = DateTime.now().difference(lastPaymentDate).inDays;

    cuttentInterest = lastPaymentInterast +
        (((actualAmount * rate * day) / (100 * 356) * 100).toInt()) / 100;

    totalAmount = ammount + cuttentInterest;

    remainingAmount = totalAmount - payedAmount;
  }
}

class PersonCompleteData {
  int totalDay;
  double rate,
      ammount,
      cuttentInterest,
      lastPaymentInterast,
      actualAmount,
      payedAmount,
      payedIntrest,
      remainingAmount,
      totalAmount;
  DateTime fromDate, toDate, lastPaymentDate;
  String key;

  PersonCompleteData(
      {this.ammount,
        this.rate,
        this.fromDate,
        this.toDate,
        this.actualAmount,
        this.lastPaymentDate,
        this.lastPaymentInterast,
        this.payedAmount,
        this.payedIntrest,
        this.key}) {
    totalDay = toDate.difference(fromDate).inDays;

    int day = toDate.difference(lastPaymentDate).inDays;

    cuttentInterest = lastPaymentInterast +
        (((actualAmount * rate * day) / (100 * 356) * 100).toInt()) / 100;

    totalAmount = ammount + cuttentInterest;

    remainingAmount = totalAmount - payedAmount;
  }
}

class History{
  DateTime date;
  double amount;
  History({this.amount,this.date});
}