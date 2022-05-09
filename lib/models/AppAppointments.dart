// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

import 'order.dart';

class AppAppointments {
  String appointmentId;
  String appointmentStatus;
  Timestamp appointmentTimestamp;
  Timestamp timestamp;
  dynamic timeValue;
  dynamic secondValue;
  UserDetails consult;
  UserDetails user;
  AppointmentDate date;
  AppointmentTime time;
  String orderId;
  String type;
  dynamic callPrice;
  dynamic userChat;
  dynamic consultChat;
  dynamic lessonTime;
  String consultType;
  String utcTime;
  bool isUtc;
  bool allowCall;
  dynamic remainingCallNum;


  AppAppointments({
    this.appointmentId,
    this.appointmentStatus,
    this.lessonTime,
    this.consultType,
    this.isUtc,
    this.remainingCallNum,
    this.appointmentTimestamp,
    this.orderId,
    this.timestamp,
    this.secondValue,
    this.timeValue,
    this.utcTime,
    this.type,
    this.date,
    this.time,
    this.consult,
    this.user,
    this.callPrice,
    this.consultChat,
    this.userChat,
    this.allowCall,



  });

  factory AppAppointments.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return AppAppointments(
      appointmentId: data['appointmentId'],
      lessonTime:data['lessonTime'],
      consultType:data['consultType'],
      remainingCallNum:data['remainingCallNum']==null?0:data['remainingCallNum'],
      appointmentStatus: data['appointmentStatus'],
      appointmentTimestamp: data['appointmentTimestamp'],
      orderId: data['orderId'],
      isUtc: data['isUtc'],
      utcTime:data['utcTime'],
      timeValue: data['timeValue'],
      type:data['type'],
      date: AppointmentDate.fromHashmap(data['date']),
      time: AppointmentTime.fromHashmap(data['time']),
      consult: UserDetails.fromHashmap(data['consult']),
      user: UserDetails.fromHashmap(data['user']),
      timestamp: data['timestamp'],
      allowCall: data['allowCall'],
      secondValue: data['secondValue'],
      callPrice:data['callPrice'],
        consultChat:data['consultChat'],
        userChat:data['userChat']

    );
  }
}
class ForEverAppointments {
  String appointmentId;
  String appointmentStatus;
  String timestamp;
  UserDetails consult;
  UserDetails user;
  AppointmentDate date;
  AppointmentTime time;
  String orderId;
  dynamic callPrice;
  String consultType;


  ForEverAppointments({
    this.appointmentId,
    this.appointmentStatus,
    this.consultType,
    this.orderId,
    this.timestamp,
    this.date,
    this.time,
    this.consult,
    this.user,
    this.callPrice,



  });

  factory ForEverAppointments.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return ForEverAppointments(
        appointmentId: data['appointmentId'],
        consultType:data['consultType'],
        appointmentStatus: data['appointmentStatus'],
        orderId: data['orderId'],
        date: AppointmentDate.fromHashmap(data['date']),
        time: AppointmentTime.fromHashmap(data['time']),
        consult: UserDetails.fromHashmap(data['consult']),
        user: UserDetails.fromHashmap(data['user']),
        timestamp: data['timestamp'],

    );
  }
}
class AppointmentDate {
  int day;
  int month;
  int year;

  AppointmentDate({
    this.day,
    this.month,
    this.year,
  });

  factory AppointmentDate.fromHashmap(Map<String, dynamic> Details) {
    return AppointmentDate(
        day: Details['day'],
        month: Details['month'],
        year: Details['year'],
    );
  }
}
class AppointmentTime {
  int hour;
  int minute;

  AppointmentTime({
    this.hour,
    this.minute,
  });

  factory AppointmentTime.fromHashmap(Map<String, dynamic> Details) {
    return AppointmentTime(
      hour: Details['hour'],
      minute: Details['minute'],
    );
  }
}


