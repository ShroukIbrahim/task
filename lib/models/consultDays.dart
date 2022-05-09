// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultDays {
  String day;
  dynamic date;
  List<dynamic> todayAppointmentList;
  String consultUid;

  ConsultDays({
    this.day,
    this.date,
    this.consultUid,
    this.todayAppointmentList,
  });
  factory ConsultDays.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();
    return ConsultDays(
      day: data['day'],
      date: data['date'],
      consultUid: data['consultUid'],
      todayAppointmentList: data['todayAppointmentList']==null?[]:data['todayAppointmentList'],
    );
  }
  factory ConsultDays.fromHashMap(Map<String, dynamic> data) {
    return ConsultDays(
      day: data['day'],
      date: data['date'],
      consultUid: data['consultUid'],
      todayAppointmentList: data['todayAppointmentList']==null?[]:data['todayAppointmentList'],
    );
  }
}