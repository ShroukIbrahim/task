// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryUser {
  String accountStatus;
  String link;
  bool isBlocked;
  bool isDeveloper;
  String uid;
  String name;
  String email;
  String userType;
  String phoneNumber;
  String photoUrl;
  dynamic rating;
  int reviewsCount;
  String tokenId;
  String defaultAddress;
  List<Address> address;
  List<dynamic> wishlist;
  List<dynamic> languages;
  List<dynamic> consultOpenAppointmentDates;
  List<dynamic> searchIndex;
  bool voice;
  bool chat;
  String bio;
  String country;
  List<WorkTimes>workTimes;
  List<dynamic> workDays;
  String userConsultIds;
  String price;
  dynamic balance;
  dynamic payedBalance;
  int ordersNumbers;
  Map<String, dynamic> cart;
  String loggedInVia;
  String supportListId;
  String customerId;
  dynamic order;
  dynamic answeredSupportNum;
  String countryCode;
  String countryISOCode;
  String userLang;
  String preferredPaymentMethod;
  bool profileCompleted=false;
  Timestamp createdDate;
  int createdDateValue;
  String fullName;
  String bankName;
  String bankAccountNumber;
  String fullAddress;
  String personalIdUrl;
  String fromUtc;
  String toUtc;
  String age;
  String education;
  String location;
  String consultType;
  bool allowEditPayinfo;
  bool sendGrant;
  GroceryUser({
    this.sendGrant,
    this.link,
    this.allowEditPayinfo,
    this.consultType,
    this.accountStatus,
    this.age,
    this.consultOpenAppointmentDates,
    this.location,
    this.education,
    this.userLang,
    this.isDeveloper,
    this.fullName,
    this.fullAddress,
    this.bankName,
    this.answeredSupportNum,
    this.bankAccountNumber,
    this.personalIdUrl,
    this.countryCode,
    this.countryISOCode,
    this.order,
    this.customerId,
    this.isBlocked,
    this.uid,
    this.searchIndex,
    this.email,
    this.userType,
    this.phoneNumber,
    this.rating,
    this.reviewsCount,
    this.name,
    this.photoUrl,
    this.languages,
    this.ordersNumbers,
    this.chat,
    this.voice,
    this.bio,
    this.workDays,
    this.workTimes,
    this.country,
    this.userConsultIds,
    this.price,
    this.balance,
    this.payedBalance,
    this.defaultAddress,
    this.address,
    this.tokenId,
    this.wishlist,
    this.cart,
    this.loggedInVia,
    this.supportListId,
    this.profileCompleted,
    this.createdDate,
    this.createdDateValue,
    this.preferredPaymentMethod,
    this.fromUtc,
    this.toUtc,
  });

  factory GroceryUser.fromFirestore(DocumentSnapshot doc) {

    Map data = doc.data();
    return GroceryUser(
      link:data['link'],
      sendGrant:data['sendGrant']==null?false:data['sendGrant'],
      allowEditPayinfo:data['allowEditPayinfo']==null?false:data['allowEditPayinfo'],
      consultType:data["consultType"]==null?"":data["consultType"],
      consultOpenAppointmentDates:data['consultOpenAppointmentDates']==null?[]:data['consultOpenAppointmentDates'],
      accountStatus: data['accountStatus']==null?"NotActive":data['accountStatus'],
      preferredPaymentMethod:data['preferredPaymentMethod']==null?"tapCompany":data['preferredPaymentMethod'],
      profileCompleted: data['profileCompleted']==null?false:data['profileCompleted'],
      userLang:data['userLang']==null?"ar":data['userLang'],
      countryCode:data['countryCode'],
      location:data['location'],
      countryISOCode:data['countryISOCode'],
      order:data['order']==null?0:data['order'],
      answeredSupportNum:data['answeredSupportNum']==null?0:data['answeredSupportNum'],
      isBlocked: data['isBlocked'],
      uid: data['uid'],
      email: data['email'],
      age: data['age'],
      education: data['education']==null?"..":data['education'],
      customerId:data['customerId'],
      supportListId:data['supportListId'],
      userType: data['userType'],
      phoneNumber: data['phoneNumber'],
      name: data['name']==null?" ":data['name'],
      bio: data['bio'],
      country: data['country'],
      workTimes: data['workTimes']==null?[]:List<WorkTimes>.from(
        data['workTimes'].map(
              (workTimes) {
            return WorkTimes.fromHashmap(workTimes);
          },
        ),
      ),
      userConsultIds:data['userConsultIds'],
      workDays: data['workDays']==null?[]:data['workDays'],
      reviewsCount:data['reviewsCount']==null?0:data['reviewsCount'],
      rating: data['rating']==null?0.0:data['rating'],
      languages: data['languages']==null?[]:data['languages'],
      ordersNumbers: data['ordersNumbers']==null?0:data['ordersNumbers'],
      price: data['price']==null?"0":data['price'],
      balance: data['balance']==null?0.0:data['balance'],
      payedBalance: data['payedBalance']==null?0.0:data['payedBalance'],
      voice: data['voice']==null?false:data['voice'],
      chat: data['chat']==null?false:data['chat'],
      isDeveloper: data['isDeveloper']==null?false:data['isDeveloper'],
      photoUrl: data['photoUrl'],
      /* defaultAddress: data['defaultAddress'],
      address: List<Address>.from(
        data['address'].map(
          (address) {
            return Address.fromHashmap(address);
          },
        ),
      ),*/
      tokenId: data['tokenId'],
      //wishlist: data['wishlist'],
      searchIndex: data['searchIndex'],
      // cart: data['cart'],
      loggedInVia: data['loggedInVia'],
      createdDate: data['createdDate'],
      createdDateValue: data['createdDateValue'],
      fullName: data['fullName'],
      fullAddress: data['fullAddress'],
      bankName: data['bankName'],
      bankAccountNumber: data['bankAccountNumber'],
      personalIdUrl: data['personalIdUrl'],
      fromUtc: data['fromUtc'],
      toUtc: data['toUtc'],
    );
  }
  factory GroceryUser.fromMap(Map data) {
    return GroceryUser(
      link:data['link'],
      sendGrant:data['sendGrant']==null?false:data['sendGrant'],
      allowEditPayinfo:data['allowEditPayinfo']==null?false:data['allowEditPayinfo'],
      consultType:data["consultType"]==null?"":data["consultType"],
      consultOpenAppointmentDates:data['consultOpenAppointmentDates']==null?[]:data['consultOpenAppointmentDates'],
      accountStatus: data['accountStatus']==null?"NotActive":data['accountStatus'],
      preferredPaymentMethod:data['preferredPaymentMethod']==null?"tapCompany":data['preferredPaymentMethod'],
      profileCompleted: data['profileCompleted']==null?false:data['profileCompleted'],
      userLang:data['userLang']==null?"ar":data['userLang'],
      countryCode:data['countryCode'],
      location:data['location'],
      countryISOCode:data['countryISOCode'],
      order:data['order']==null?0:data['order'],
      answeredSupportNum:data['answeredSupportNum']==null?0:data['answeredSupportNum'],
      isBlocked: data['isBlocked'],
      uid: data['uid'],
      email: data['email'],
      age: data['age'],
      education: data['education']==null?"..":data['education'],
      customerId:data['customerId'],
      supportListId:data['supportListId'],
      userType: data['userType'],
      phoneNumber: data['phoneNumber'],
      name: data['name']==null?" ":data['name'],
      bio: data['bio'],
      country: data['country'],
      workTimes: data['workTimes']==null?[]:List<WorkTimes>.from(
        data['workTimes'].map(
              (workTimes) {
            return WorkTimes.fromHashmap(workTimes);
          },
        ),
      ),
      userConsultIds:data['userConsultIds'],
      workDays: data['workDays']==null?[]:data['workDays'],
      reviewsCount:data['reviewsCount']==null?0:data['reviewsCount'],
      rating: data['rating']==null?0.0:data['rating'],
      languages: data['languages']==null?[]:data['languages'],
      ordersNumbers: data['ordersNumbers']==null?0:data['ordersNumbers'],
      price: data['price']==null?"0":data['price'],
      balance: data['balance']==null?0.0:data['balance'],
      payedBalance: data['payedBalance']==null?0.0:data['payedBalance'],
      voice: data['voice']==null?false:data['voice'],
      chat: data['chat']==null?false:data['chat'],
      isDeveloper: data['isDeveloper']==null?false:data['isDeveloper'],
      photoUrl: data['photoUrl'],
      tokenId: data['tokenId'],
      searchIndex: data['searchIndex'],
      loggedInVia: data['loggedInVia'],
      createdDate: data['createdDate'],
      createdDateValue: data['createdDateValue'],
      fullName: data['fullName'],
      fullAddress: data['fullAddress'],
      bankName: data['bankName'],
      bankAccountNumber: data['bankAccountNumber'],
      personalIdUrl: data['personalIdUrl'],
      fromUtc: data['fromUtc'],
      toUtc: data['toUtc'],
    );
  }
}

class Address {
  String city;
  String state;
  String pincode;
  String landmark;
  String addressLine1;
  String addressLine2;
  String country;
  String houseNo;

  Address({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.country,
    this.houseNo,
    this.landmark,
    this.pincode,
    this.state,
  });

  factory Address.fromHashmap(Map<String, dynamic> address) {
    return Address(
      addressLine1: address['addressLine1'],
      addressLine2: address['addressLine2'],
      city: address['city'],
      country: address['country'],
      houseNo: address['houseNo'],
      landmark: address['landmark'],
      pincode: address['pincode'],
      state: address['state'],
    );
  }
}
class KeyValueModel {
  dynamic key;
  String value;

  KeyValueModel({this.key, this.value});
}
class WorkTimes {
  String from;
  String to;
  WorkTimes({
    this.from,
    this.to,
  });

  factory WorkTimes.fromHashmap(Map<String, dynamic> ranges) {
    return WorkTimes(
      from: ranges['from'],
      to: ranges['to'],

    );
  }
}