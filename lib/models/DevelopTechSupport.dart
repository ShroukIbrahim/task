// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

import 'order.dart';

class DevelopTechSupport {
  String developTechSupportId;
  String userUid;
  String userName;
  String title;
  String status;
  Timestamp sendTime;


  DevelopTechSupport({
    this.developTechSupportId,
    this.userUid,
    this.userName,
    this.title,
    this.sendTime,
    this.status,
  });

  factory DevelopTechSupport.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return DevelopTechSupport(
        developTechSupportId:data['developTechSupportId'],
        userUid: data['userUid'],
        title: data['title'],
        userName: data['userName'],
        status: data['status'],
        sendTime: data['sendTime'],
    );
  }
}


