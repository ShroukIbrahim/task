// @dart=2.9

import 'dart:io';

import 'package:grocery_store/localization/localization_methods.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'appStoreScreen.dart';

class ForceUpdateScreen extends StatefulWidget {

  const ForceUpdateScreen({Key key}) : super(key: key);
  @override
  _ForceUpdateScreenState createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  String lang;
  @override
  void initState() {
    super.initState();
  }

  void showFailedSnakbar(String s) {
    SnackBar snackbar = SnackBar(
      content: Text(
        s,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.red,
      action: SnackBarAction(
          label: 'OK', textColor: Colors.white, onPressed: () {}),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang=getTranslated(context, "lang");
    return Scaffold(
      key: _scaffoldKey,
      body:  ListView(
        children: <Widget>[
          Container(
            height: size.height*.5,
            width: size.width,
            color: Colors.white,
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
              SizedBox(height: 70,),
              Center(
                  child:  Image.asset('assets/applicationIcons/whiteLogo.png',width: 100,height: 100,)
              ),
              SizedBox(height: 10,),
              Text(
                'لتعليم  القرآن الكريم',
                style: GoogleFonts.almarai(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0,
                ),
              ),
            ],)),
          ),
          Container(
            height: size.height*.5,
            width: size.width,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children:  [

                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: Center(
                    child: Text(
                      getTranslated(context, "lastVersion"),
                      maxLines: 3,
                      textAlign:TextAlign.center ,
                      style: GoogleFonts.cairo(
                        color: Theme.of(context).primaryColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40,),
                Container(
                  width: size.width*.8,
                  height: 45.0,
                  child: FlatButton(
                    onPressed: () async {

                      String url = Platform.isIOS ?"https://apps.apple.com/us/app/1612021922": "https://play.google.com/store/apps/details?id=com.app.jerasUI";
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                   /* Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AppStoreScreen(
                            ),
                      ),
                    );*/
                    },
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      getTranslated(context, "install"),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],),
          ),
        ],
      ),
    );
  }
 
}
