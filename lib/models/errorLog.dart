// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

class ErrorLogModel {
  Timestamp timestamp;
  bool seen;
  String id;
  String desc;
  String screen;
  String function;
  String phone;
  ErrorLogModel({
    this.id,
    this.seen,
    this.timestamp,
    this.desc,
    this.screen,
    this.function,
    this.phone,

  });

  factory ErrorLogModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return ErrorLogModel(
      id: data['id'],
      seen: data['seen'],
      timestamp: data['timestamp'],
      desc: data['desc'],
      screen: data['screen'],
      function: data['function'],
      phone: data['phone'],
    );
  }
}


