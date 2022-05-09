// @dart=2.9

import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String lang="اللغة",langValue="",done="حفظ",title="من فضلك قم بتحديد لغة التطبيق",dropdownValue;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<KeyValueModel> _datas = [
    KeyValueModel(key: 0, value: "العربية"),
    KeyValueModel(key: 1, value: "English"),
  ];

  @override
  void initState() {
    super.initState();
    lang="العربية";
    dropdownValue = "0";
    title="من فضلك قم باختيار اللغة المفضلة";
    langValue="ar";
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
    return Scaffold(
      key: _scaffoldKey,
      body:  Column(
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
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(width:size.width*0.8,height: 45.0,decoration:
                    BoxDecoration(color:Colors.grey[200] ,
                      border: Border.all(
                        color: Colors.grey[200],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(40))
                     ),
                      child:Padding(
                        padding: const EdgeInsets.only(left: 10,right: 10),
                        child: DropdownButton<String>(
                          hint: Text(lang,textAlign:TextAlign.center,style: GoogleFonts.cairo(
                            color: Colors.black,
                            fontSize: 15.0,
                            letterSpacing: 0.5,
                          ),),
                          underline:Container(),
                          isExpanded: true,
                          value: dropdownValue,
                          icon: Icon(Icons.keyboard_arrow_down,color: Colors.black),
                          iconSize: 24,
                          elevation: 16,
                          style: GoogleFonts.cairo(
                            color: Color(0xFF3b98e1),
                            fontSize: 13.0,
                            letterSpacing: 0.5,
                          ),
                          items: _datas
                              .map((data) => DropdownMenuItem<String>(
                              child: Text(data.value,style: GoogleFonts.cairo(
                                color: Colors.black,
                                fontSize: 15.0,
                                letterSpacing: 0.5,
                              ),),
                              value: data.key.toString()//data.key,
                          ))
                              .toList(),
                          onChanged: (String value) {
                            if(value=="0")
                            {
                              setState(() {
                                lang="العربية";
                                dropdownValue = value;
                                title="من فضلك قم باختيار اللغة المفضلة";
                                langValue="ar";
                                done="حفظ";
                              });
                            }
                            else if(value=="1") {
                              setState(() {
                                lang = "English";
                                dropdownValue = value;
                                title="Please select language";
                                langValue="en";
                                done="Save";
                              });
                            }

                          },

                        ),
                      )
                  ),

                  SizedBox(height: 40,),
                  Container(
                    width: size.width*.8,
                    height: 45.0,
                    child: FlatButton(
                      onPressed: () async {
                        if(langValue=="")
                          {showFailedSnakbar(getTranslated(context, "chooseLang"));}
                        else{
                          _changeLanguage(langValue);
                          Navigator.popAndPushNamed(context, '/home');
                        }

                      },
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Text(
                        done,
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
  void _changeLanguage(String lang) async {
    Locale _temp;
    switch (lang) {
      case 'en':
        _temp = Locale(lang, 'US');
        break;
      case 'ar':
        _temp = Locale(lang, 'AR');
        break;
      case 'fr':
        _temp = Locale(lang, 'FR');
        break;
      default:
        _temp = Locale('en', 'US');
        break;
    }
    Locale _locale = await setLocale(lang);
    MyApp.setLocale(context, _temp);
  }
}
