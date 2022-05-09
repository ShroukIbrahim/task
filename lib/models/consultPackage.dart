// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

class consultPackage {
  String Id;
  dynamic price;
  dynamic discount;
  String consultUid;
  bool active;
  dynamic callNum;


  consultPackage({
    this.Id,
    this.price,
    this.consultUid,
    this.discount,
    this.active,
    this.callNum,
  });
  factory consultPackage.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();
    return consultPackage(
        Id: data['Id'],
        price: data['price'],
        discount: data['discount'],
        consultUid: data['consultUid'],
        active: data['active'],
        callNum: data['callNum']
    );
  }
  factory consultPackage.fromHashMap(Map<String, dynamic> review) {
    return consultPackage(
        Id: review['Id'],
        discount: review['discount'],
        price: review['price'],
        consultUid: review['consultUid'],
        active: review['active'],
        callNum: review['callNum']
    );
  }
}