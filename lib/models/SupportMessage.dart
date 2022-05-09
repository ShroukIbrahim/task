// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

class SupportMessage {
  String supportId;
  Timestamp messageTime;
  String messageTimeUtc;
  String userUid;
  String message;
  dynamic type;
  dynamic owner;
  String ownerName;

  SupportMessage({
    this.message,
    this.supportId,
    this.messageTime,
    this.messageTimeUtc,
    this.userUid,
    this.type,
    this.owner,
    this.ownerName,


  });

  factory SupportMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return SupportMessage(
      supportId: data['supportId'],
      message: data['message'],
      messageTimeUtc:data['messageTimeUtc'],
      type: data['type'],
      owner: data['owner'],
      userUid: data['userUid'],
      messageTime: data['messageTime'],
      ownerName: data['ownerName'],

    );
  }
}

