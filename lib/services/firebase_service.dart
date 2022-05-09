// @dart=2.9

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/AppointmentChatScreen.dart';
import 'package:grocery_store/screens/addReviewScreen.dart';
import 'package:grocery_store/screens/agoraScreen.dart';
import 'package:grocery_store/screens/generalNotificationScreen.dart';
import 'package:grocery_store/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:store_redirect/store_redirect.dart';

import '../screens/agoraVideoCall.dart';
import '../screens/payInfoScreen.dart';
import '../screens/videoScreen.dart';

dynamic notificationData;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
RemoteNotification value;
BuildContext _context;
class FirebaseService {
  static init(context, uid, User currentUser) {
    _context=context;
    initDynamicLinks(context);
    updateFirebaseToken(currentUser);
    initFCM(uid, context, currentUser);
    configureFirebaseListeners(context, currentUser);
  }
}

initDynamicLinks(context) async {
  print("aaa initDynamicLinks");
  PendingDynamicLinkData data =
  await FirebaseDynamicLinks.instance.getInitialLink();
  Uri deepLink = data?.link;
  print("aaa deepLink");
  print(data);
  if (deepLink != null) {
    print('LAUNCH');
    print('DEEP LINK URL ::: $deepLink ');
    print(deepLink.toString());
    // print(deepLink.queryParameters['link']);

    // print(
    //     deepLink.queryParameters['link'].split('${Config().urlPrefix}/')[1]);

    // var tempLink = deepLink.queryParameters['${Config().urlPrefix}/'];
    String pid = deepLink.toString().split('${Config().urlPrefix}/')[1];

    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(
          productId: pid,
        ),
      ),
    );*/
  }

  FirebaseDynamicLinks.instance.onLink;
  /* FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        Uri deepLink = dynamicLink?.link;

        if (deepLink != null) {
          print('ON_LINK');
          print('DEEP LINK URL ::: $deepLink ');
          // print(deepLink.queryParametersAll);
          // print(deepLink.queryParameters['link']);

          // print(deepLink.queryParameters['link']
          //     .split('${Config().urlPrefix}/')[1]);

          // var tempLink = deepLink.queryParameters['${Config().urlPrefix}/'];
          String pid = deepLink.toString().split('${Config().urlPrefix}/')[1];

          *//* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(
                productId: pid,
              ),
            ),
          );*//*
        }
      }, onError: (OnLinkErrorException e) async {
    print('onLinkError');
    print(e.message);
  });*/
}

//FCM
updateFirebaseToken(User currentUser) {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  firebaseMessaging.getToken().then((token) {
    print(token);
    FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).update({
      'tokenId': token,
    });
  });
}

initFCM(String uid, context, User currentUser) async {
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  var android = new AndroidInitializationSettings('ic_stat_name');//('grocery');
  var ios = new IOSInitializationSettings();
  var initSetting = new InitializationSettings(iOS: ios, android: android);
  flutterLocalNotificationsPlugin.initialize(
      initSetting,
      onSelectNotification:onSelectNotification

  );
}
Future<void> onSelectNotification(String payload) async {
  if(value!=null){
    if((value.title=="المواعيد"||value.title=="Appointment")&&value.titleLocKey=="user"){
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(notificationPage: 1,),
        ),
      );
    }
    else if((value.title=="المواعيد"||value.title=="Appointment")&&value.titleLocKey=="consult"){
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(notificationPage: 0,),
        ),
      );
    }
    else if(value.title=="التقيم"||value.title=="Review"){
      // StoreRedirect.redirect(androidAppId: 'com.abdulazizahmed.dream',iOSAppId: '1515745954');
      List<String> dateParts = value.bodyLocKey.split(",");
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) =>
              AddReviewScreen(consultId: dateParts[0],userId:value.titleLocKey,appointmentId: dateParts[1],),
        ),
      );
    }
    else if(value.title=="الدعم الفني"||value.title=="Technical Support"){
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(notificationPage: 2,),
        ),
      );
    }
    else if(value.title=="رسائل المحادثات"||value.title=="Chat messages"){
      DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(value.titleLocKey);
      final DocumentSnapshot documentSnapshot = await docRef.get();
      var user= GroceryUser.fromFirestore(documentSnapshot);

      DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(value.bodyLocKey);
      final DocumentSnapshot documentSnapshot2 = await docRef2.get();
      var appointment = AppAppointments.fromFirestore(documentSnapshot2);
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) => AppointmentChatScreen(
              appointment: appointment,
              user:user
          ),
        ),
      );

    }
    else if(value.title=="اتصال"||value.title=="Calling"){
      /* DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(value.titleLocKey);
      final DocumentSnapshot documentSnapshot = await docRef.get();
      var user= GroceryUser.fromFirestore(documentSnapshot);

      DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(value.bodyLocKey);
      final DocumentSnapshot documentSnapshot2 = await docRef2.get();
      var appointment = AppAppointments.fromFirestore(documentSnapshot2);*/
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            appointment: null,
            user:null,
            appointmentId:value.bodyLocKey ,
            consultName: value.titleLocKey,
          ),
        ),
      );

    }
    else if(value.title=="الحساب"||value.title=="Account"){
      /* DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(value.titleLocKey);
      final DocumentSnapshot documentSnapshot = await docRef.get();
      var user= GroceryUser.fromFirestore(documentSnapshot);

      DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(value.bodyLocKey);
      final DocumentSnapshot documentSnapshot2 = await docRef2.get();
      var appointment = AppAppointments.fromFirestore(documentSnapshot2);*/
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) => payInfoScreen(
            consultUid: value.titleLocKey,
          ),
        ),
      );

    }
    else{
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) =>
              GeneralNotificationScreen(
                  title:value.title,
                  body:value.body,
                  image:value.titleLocKey,
                  link:value.bodyLocKey
              ),
        ),
      );
    }
  }


}
configureFirebaseListeners(context, User currentUser) async {
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) {
    print('INITIAL MESSAGE :: $message');
    if(message!=null)
    {
      value=message.notification;
    }

    //onSelectNotification("");
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('ON MESSAGE :: $message');

    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    if (notification != null && android != null) {
      showNotification(
        notification,
      );
    }
    else
      print("aaa noshowNotification");
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print('A new onMessageOpenedApp event was published!');
    print("message11111");
    print(message);
    print(message.data);
    print(message.notification.title);
    print(message.notification.body);
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );*/
    if((message.notification.title=="المواعيد"||message.notification.title=="Appointment")&&message.notification.titleLocKey=="user"){
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(notificationPage: 1,),
        ),
      );
    }
    else if((message.notification.title=="المواعيد"||message.notification.title=="Appointment")&&message.notification.titleLocKey=="consult"){
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(notificationPage: 0,),
        ),
      );
    }
    else if(message.notification.title=="التقيم"||message.notification.title=="Review"){
      //StoreRedirect.redirect(androidAppId: 'com.abdulazizahmed.dream',iOSAppId: '1515745954');
      List<String> dateParts = message.notification.bodyLocKey.split(",");
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) =>
              AddReviewScreen(consultId: dateParts[0],userId:message.notification.titleLocKey,appointmentId: dateParts[1],),
        ),
      );

    }
    else if(message.notification.title=="الدعم الفني"||message.notification.title=="Technical Support"){
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(notificationPage: 2,),
        ),
      );
    }
    else if(message.notification.title=="رسائل المحادثات"||message.notification.title=="Chat messages"){
      DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(message.notification.titleLocKey);
      final DocumentSnapshot documentSnapshot = await docRef.get();
      var user= GroceryUser.fromFirestore(documentSnapshot);

      DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(message.notification.bodyLocKey);
      final DocumentSnapshot documentSnapshot2 = await docRef2.get();
      var appointment = AppAppointments.fromFirestore(documentSnapshot2);
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) => AppointmentChatScreen(
              appointment: appointment,
              user:user
          ),
        ),
      );

    }
    else if(message.notification.title=="اتصال"||message.notification.title=="Calling"){
      /* DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(message.notification.titleLocKey);
      final DocumentSnapshot documentSnapshot = await docRef.get();
      var user= GroceryUser.fromFirestore(documentSnapshot);

      DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(message.notification.bodyLocKey);
      final DocumentSnapshot documentSnapshot2 = await docRef2.get();
      var appointment = AppAppointments.fromFirestore(documentSnapshot2);*/
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            appointment: null,
            user:null,
            appointmentId: message.notification.bodyLocKey,
            consultName:message.notification.titleLocKey ,
          ),
        ),
      );

    }
    else if(message.notification.title=="الحساب"||message.notification.title=="Account"){
      /* DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(message.notification.titleLocKey);
      final DocumentSnapshot documentSnapshot = await docRef.get();
      var user= GroceryUser.fromFirestore(documentSnapshot);

      DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(message.notification.bodyLocKey);
      final DocumentSnapshot documentSnapshot2 = await docRef2.get();
      var appointment = AppAppointments.fromFirestore(documentSnapshot2);*/
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) => payInfoScreen(
            consultUid:message.notification.titleLocKey ,
          ),
        ),
      );

    }
    else{
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) =>
              GeneralNotificationScreen(
                  title:message.notification.title,
                  body:message.notification.body,
                  image:message.notification.titleLocKey,
                  link:message.notification.bodyLocKey
              ),
        ),
      );
    }
  });
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    //'This channel is used for important notifications.', // description
    importance: Importance.max,playSound: true,sound:  RawResourceAndroidNotificationSound('soundandroid'),
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);


}

showNotification( RemoteNotification data, ) async {
  flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();
  var aNdroid = new AndroidNotificationDetails(
    'channelId',
    'channel_name',
    //'desc',
    icon:'ic_stat_name',
    importance: Importance.high,  priority: Priority.max,playSound: true,sound:  RawResourceAndroidNotificationSound('soundandroid'),

  );
  var iOS = new IOSNotificationDetails( sound: 'soundios.m4r',
    presentAlert: true,
    presentBadge: true,
    presentSound: true,);
  var platform = new NotificationDetails(android: aNdroid, iOS: iOS);
  print("aaa1111111 channelId data.title");
  print( data.title);

  value=data;
  await flutterLocalNotificationsPlugin.show( Random().nextInt(100),
    data.title,
    data.body,
    platform,
  );
  //==========

  //==============

}

Future<dynamic> firebaseBackgroundMessageHandler( Map<String, dynamic> message) async {
  notificationData = message;
  return Future<void>.value();
}

Future<void> _firebaseMessagingBackgroundHandler( RemoteMessage message, ) async {
  print('ON MESSAGE :: $message');
  RemoteNotification notification = message.notification;
  AndroidNotification android = message.notification?.android;
  /*if (notification != null && android != null) {
    showNotification(
      notification,
    );
  }*/

}
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {

  if (message['data'] != null) {
    final data = message['data'];

    final title = data['title'];
    final body = data['message'];

    await _showNotificationWithDefaultSound(title, body);
  }
  return Future<void>.value();
}
Future _showNotificationWithDefaultSound(String title, String message) async {
  var aNdroid = new AndroidNotificationDetails(
    'channelId',
    'channel_name',
    channelDescription:'desc',icon:'ic_stat_name',
    importance: Importance.high,  priority: Priority.max,playSound: true,sound:  RawResourceAndroidNotificationSound('soundandroid'),

  );
  var iOS = new IOSNotificationDetails( sound: 'soundios.m4r',
    presentAlert: true,
    presentBadge: true,
    presentSound: true,);
  var platform = new NotificationDetails(android: aNdroid, iOS: iOS);
  await flutterLocalNotificationsPlugin.show(
    0,
    '$title',
    '$message',
    platform,
    payload: 'soundandroid',//'Default_Sound',
  );
}
