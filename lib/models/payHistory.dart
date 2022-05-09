// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

class PayHistory {
  dynamic balance;
  Timestamp payTime;
  dynamic payDate;
  String consultUid;
  String consultName;
  String consultImage;
  String invoiceNumber;
  PayHistory({
    this.balance,
    this.payTime,
    this.payDate,
    this.consultUid,
    this.consultImage,
    this.consultName,
    this.invoiceNumber,
    
  });
  factory PayHistory.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();
    return PayHistory(
      payTime: data['payTime'],
      balance: data['balance'],
      payDate: data['payDate'],
      consultUid: data['consultUid'],
      consultName: data['consultName'],
      consultImage: data['consultImage'],
        invoiceNumber:data['invoiceNumber']

    );
  }
  factory PayHistory.fromHashMap(Map<String, dynamic> pay) {
    return PayHistory(
      balance: pay['balance'],
      payTime: pay['payTime'],
      consultUid: pay['consultUid'],
      consultName: pay['consultName'],
      consultImage: pay['consultImage'],
        invoiceNumber:pay['invoiceNumber']
    );
  }
}