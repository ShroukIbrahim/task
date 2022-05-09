// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

class SupportAnalysis {
  dynamic time;
  dynamic techSupportUser;

  SupportAnalysis({
    this.time,
    this.techSupportUser,


  });

  factory SupportAnalysis.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return SupportAnalysis(
      time: data['time'],
      techSupportUser: data['price'],
    );
  }
}


