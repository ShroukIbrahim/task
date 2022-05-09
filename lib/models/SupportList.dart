// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

class SupportList {
  String supportListId;
  bool supportListStatus;
  bool openingStatus;
  Timestamp messageTime;
  String userUid;
  String userName;
  String lastMessage;
  dynamic image;
  dynamic userMessageNum;
  dynamic supportMessageNum;

  SupportList({
    this.supportListId,
    this.supportListStatus,
    this.openingStatus,
    this.messageTime,
    this.userUid,
    this.userName,
    this.lastMessage,
    this.image,
    this.userMessageNum,
    this.supportMessageNum,


  });

  factory SupportList.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return SupportList(
      supportListId: data['supportListId'],
      supportListStatus: data['supportListStatus']==null?false:data['supportListStatus'],
      openingStatus:data['openingStatus']==null?false:data['openingStatus'],
      messageTime: data['messageTime'],
      userUid: data['userUid'],
      userName: data['userName'],
      lastMessage: data['lastMessage'],
      image: data['image'],
      userMessageNum: data['userMessageNum'],
      supportMessageNum: data['supportMessageNum'],


    );
  }
}

