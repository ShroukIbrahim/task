// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

class UserAnalysis {
  dynamic time;
  String type;

  UserAnalysis({
    this.time,
    this.type,


  });

  factory UserAnalysis.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return UserAnalysis(
      time: data['time'],
      type: data['type'],
    );
  }
}


