// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

class DevelopMessage {
  String developMessageId;
  Timestamp messageTime;
  String messageTimeUtc;
  String userUid;
  String message;
  dynamic type;
  dynamic owner;
  String ownerName;

  DevelopMessage({
    this.message,
    this.developMessageId,
    this.messageTime,
    this.messageTimeUtc,
    this.userUid,
    this.type,
    this.owner,
    this.ownerName,


  });

  factory DevelopMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return DevelopMessage(
      developMessageId: data['developMessageId'],
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

