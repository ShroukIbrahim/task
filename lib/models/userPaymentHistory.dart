// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

import 'order.dart';

class UserPaymentHistory {
  String userUid;
  String payType;
  String amount;
  Timestamp payDate;
  dynamic payDateValue;
  UserDetails otherData;

  UserPaymentHistory({
    this.userUid,
    this.payType,
    this.amount,
    this.payDate,
    this.payDateValue,
    this.otherData,
  });

  factory UserPaymentHistory.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return UserPaymentHistory(
        userUid: data['userUid'],
        payType: data['payType'],
        amount: data['amount'],
        payDate: data['payDate'],
        payDateValue: data['payDateValue'],
        otherData: UserDetails.fromHashmap(data['otherData'])
    );
  }
}


