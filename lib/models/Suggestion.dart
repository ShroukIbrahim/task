// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

import 'order.dart';

class Suggestions {
  String suggestionId;
  String userUid;
  String title;
  String desc;
  bool status;
  Timestamp sendTime;
  UserDetails userData;

  Suggestions({
    this.suggestionId,
    this.userUid,
    this.title,
    this.desc,
    this.sendTime,
    this.status,
    this.userData,
  });

  factory Suggestions.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return Suggestions(
        suggestionId:data['suggestionId'],
        userUid: data['userUid'],
        title: data['title'],
        desc: data['desc'],
        status: data['status'],
        sendTime: data['sendTime'],
        userData: UserDetails.fromHashmap(data['userData'])
    );
  }
}


