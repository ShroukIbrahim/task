// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
class AppAnalysis {
  var allUsers;
  var consultNum;
  var usersNum;
  var supportNum;
  var orderNum;
  var totalEarn;
  var activePromoCodes;
  var notActivePromoCodes;
  var notActiveConsult;
  var activeConsult;
  var admin;
  AppAnalysis({
    this.allUsers,
    this.consultNum,
    this.usersNum,
    this.supportNum,
    this.orderNum,
    this.totalEarn,
    this.activePromoCodes,
    this.notActivePromoCodes,
    this.notActiveConsult,
    this.activeConsult,
    this.admin,
  });

  factory AppAnalysis.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data();
    return AppAnalysis(
      allUsers: data['allUsers'],
      consultNum: data['consultNum'],
      usersNum: data['usersNum'],
      supportNum: data['supportNum'],
      orderNum: data['orderNum'],
      totalEarn: data['totalEarn'],
      activePromoCodes: data['activePromoCodes'],
      notActivePromoCodes: data['notActivePromoCodes'],
      notActiveConsult: data['notActiveConsult'],
      activeConsult: data['activeConsult'],
      admin: data['admin'],
    );
  }
}
