// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

class Grants {
  String grantId;
  String userUid;
  String name;
  String status;
  String country;
  String age;
  String education;
  String phone;
  String school;
  String personalPhoto;
  String personalIdPhoto;
  String referance;
  String scienceLevel;
  String langLevel;
  String quranLevel;
  String quranPhoto;
  List<dynamic> futureWork;
  Timestamp grantDate;


  Grants({
    this.grantId,
    this.userUid,
    this.status,
    this.name,
    this.country,
    this.phone,
    this.school,
    this.education,
    this.age,
    this.futureWork,
    this.grantDate,
    this.langLevel,
    this.personalIdPhoto,
    this.personalPhoto,
    this.quranLevel,
    this.quranPhoto,
    this.referance,
    this.scienceLevel,

  });
  factory Grants.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();
    return Grants(
        grantId: data['grantId'],
        userUid: data['userUid'],
        status:data['status'],
        scienceLevel: data['scienceLevel'],
        referance: data['referance'],
        quranPhoto: data['quranPhoto'],
        quranLevel: data['quranLevel'],
        personalPhoto: data['personalPhoto'],
        personalIdPhoto: data['personalIdPhoto'],
        langLevel:data['langLevel'],
        grantDate: data['grantDate'],
        futureWork: data['futureWork'],
        age: data['age'],
        education: data['education'],
        school: data['school'],
        phone: data['phone'],
        name:data['name'],
        country:data['country']

    );
  }
  factory Grants.fromHashMap(Map<String, dynamic> data) {
    return Grants(
        grantId: data['grantId'],
        userUid: data['userUid'],
        status: data['status'],
        scienceLevel: data['scienceLevel'],
        referance: data['referance'],
        quranPhoto: data['quranPhoto'],
        quranLevel: data['quranLevel'],
        personalPhoto: data['personalPhoto'],
        personalIdPhoto: data['personalIdPhoto'],
        langLevel:data['langLevel'],
        grantDate: data['grantDate'],
        futureWork: data['futureWork'],
        age: data['age'],
        education: data['education'],
        school: data['school'],
        phone: data['phone'],
        name:data['name'],
        country:data['country']
    );
  }
}