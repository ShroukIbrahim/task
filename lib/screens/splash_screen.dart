// @dart=2.9
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/models/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'completeUserProfile.dart';
import 'consultRules.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  String  userType;
  dynamic androidVersion,iosVersion;
  bool loading=true;

  @override
  void initState() {
    super.initState();
    checkUserAccount();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
          child:Image.asset('assets/applicationIcons/splach.png')


      ),
    );
  }
  Future<void> checkUserAccount() async {
    FirebaseFirestore.instance.collection(Paths.settingPath).doc("pzBqiphy5o2kkzJgWUT7").get().then((value) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        androidVersion= Setting.fromFirestore(value).androidVersion;
        iosVersion=Setting.fromFirestore(value).iosVersion;
      });

     if(Platform.isAndroid&&androidVersion!=packageInfo.version)
        Navigator.popAndPushNamed(context, '/ForceUpdateScreen');
      else if(Platform.isIOS&&iosVersion!=packageInfo.version) {
        Navigator.popAndPushNamed(context, '/ForceUpdateScreen');
      }
     else
     {
      if(FirebaseAuth.instance.currentUser!=null){
        await FirebaseFirestore.instance.collection(Paths.usersPath).doc(FirebaseAuth.instance.currentUser.uid).get().then((value) async {
          GroceryUser currentUser = GroceryUser.fromFirestore(value);
          if(currentUser.isBlocked){
            await FirebaseAuth.instance.signOut();
            Navigator.popAndPushNamed(context, '/home',arguments: {
              'userType': userType,
            },);
          }
          if(currentUser.userType=="CONSULTANT"&&currentUser.profileCompleted==false)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => consultRuleScreen(user:currentUser),),);
          else if(currentUser.userType!="CONSULTANT"&&currentUser.profileCompleted==false)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompleteUserProfileScreen(user:currentUser), ),);
          else
            Navigator.popAndPushNamed(context, '/home',arguments: {
              'userType': userType,
            },);
        }).catchError((err) {
          print("error123"+err.toString());
          errorLog("checkUserAccount", err.toString());
        });
      }
      else
        Navigator.popAndPushNamed(context, '/home',arguments: {
          'userType': userType,
        },);

      }

    }).catchError((err) {
      print("error333"+err.toString());
      errorLog("checkUserAccount", err.toString());
    });
  }
  errorLog(String function,String error)async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance.collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': error,
      'phone': "phone",
      'uid':"uid",
      'screen': "splash",
      'function': "checkUserAccount",
    });
  }
}
