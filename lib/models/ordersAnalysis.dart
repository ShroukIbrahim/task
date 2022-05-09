// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

class OrdersAnalysis {
 dynamic time;
  dynamic price;

  OrdersAnalysis({
    this.time,
    this.price,


  });

  factory OrdersAnalysis.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return OrdersAnalysis(
      time: data['time'],
      price: data['price'],
    );
  }
}


