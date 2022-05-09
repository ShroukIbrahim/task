// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';


class AppointmentChat {
  String appointmentId;
  String message;
  Timestamp messageTime;
  String messageTimeUtc;
  dynamic type;
  String userUid;


  AppointmentChat({
    this.message,
    this.appointmentId,
    this.messageTimeUtc,
    this.messageTime,
    this.userUid,
    this.type,


  });

  factory AppointmentChat.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return AppointmentChat(
      appointmentId: data['appointmentId'],
      messageTimeUtc:data['messageTimeUtc'],
      message: data['message'],
      type: data['type'],
      userUid: data['userUid'],
      messageTime: data['messageTime'],

    );
  }
}

