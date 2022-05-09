// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';
class Orders {
  String orderId;
  String orderStatus;
  Timestamp orderTimestamp;
  dynamic orderTimeValue;
  UserDetails consult;
  UserDetails user;
  String packageId;
  String promoCodeId;
  String payWith;
  String consultType;
  dynamic remainingCallNum;
  dynamic packageCallNum;
  dynamic answeredCallNum;
  dynamic callPrice;
  dynamic price;

  Orders({
    this.orderId,
    this.orderStatus,
    this.orderTimestamp,
    this.orderTimeValue,
    this.consult,
    this.consultType,
    this.user,
    this.payWith,
    this.remainingCallNum,
    this.packageCallNum,
    this.answeredCallNum,
    this.packageId,
    this.promoCodeId,
    this.callPrice,
    this.price,


  });

  factory Orders.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return Orders(
      orderId: data['orderId'],
      orderStatus: data['orderStatus'],
      payWith: data['payWith'],
      consultType:data['consultType']==null?"":data['consultType'],
      orderTimestamp: data['orderTimestamp'],
      orderTimeValue: data['orderTimeValue'],
      consult: UserDetails.fromHashmap(data['consult']),
      user: UserDetails.fromHashmap(data['user']),
      remainingCallNum: data['remainingCallNum'],
      packageCallNum: data['packageCallNum'],
      answeredCallNum: data['answeredCallNum'],
      packageId: data['packageId'],
      promoCodeId: data['promoCodeId'],
      callPrice: data['callPrice'],
      price: data['price'],

    );
  }
}
class UserDetails {
  String name;
  String image;
  String uid;
  String phone;
  String countryCode;
  String countryISOCode;

  UserDetails({
    this.name,
    this.image,
    this.uid,
    this.phone,
    this.countryCode,
    this.countryISOCode
  });

  factory UserDetails.fromHashmap(Map<String, dynamic> Details) {
    return UserDetails(
        name: Details['name'],
        uid: Details['uid'],
        image: Details['image'],
        phone:Details['phone'],
        countryCode: Details['countryCode'],
        countryISOCode:Details['countryISOCode']
    );
  }
}

