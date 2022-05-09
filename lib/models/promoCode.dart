// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

class PromoCode {
  String promoCodeId;
  bool promoCodeStatus;
  Timestamp promoCodeTimestamp;
  String ownerName;
  String code;
  dynamic usedNumber;
  dynamic discount;

  PromoCode({
    this.promoCodeId,
    this.promoCodeStatus,
    this.promoCodeTimestamp,
   
    this.ownerName,
    this.code,
    this.usedNumber,
    this.discount,



  });

  factory PromoCode.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return PromoCode(
      promoCodeId: data['promoCodeId'],
      promoCodeStatus: data['promoCodeStatus'],
      promoCodeTimestamp: data['promoCodeTimestamp'],

      ownerName: data['ownerName'],
      code: data['code'],
      usedNumber: data['usedNumber'],
      discount: data['discount'],

    );
  }
}


