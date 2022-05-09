// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

class Setting {
  String settingId;
  String firstTitleAr;
  String firstTitleEn;
 dynamic androidVersion;
 dynamic androidBuildNumber;
  dynamic iosVersion;
  dynamic iosBuildNumber;
  dynamic taxes;

  Setting({
    this.settingId,
    this.firstTitleAr,
    this.firstTitleEn,
    this.androidVersion,
    this.androidBuildNumber,
    this.iosVersion,
    this.iosBuildNumber,
    this.taxes,


  });

  factory Setting.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return Setting(
      settingId: data['settingId'],
      firstTitleAr: data['firstTitleAr'],
      firstTitleEn: data['firstTitleEn'],
      androidVersion: data['androidVersion'],
      androidBuildNumber: data['androidBuildNumber'],
      iosVersion: data['iosVersion'],
      iosBuildNumber: data['iosBuildNumber'],
      taxes: data['taxes']

    );
  }
}


