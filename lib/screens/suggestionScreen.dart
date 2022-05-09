// @dart=2.9
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import 'package:webview_flutter/webview_flutter.dart';

class SuggestionScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const SuggestionScreen({Key key, this.loggedUser}) : super(key: key);

  @override
  _SuggestionScreenState createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen>with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving=false;
  GroceryUser user;
  List<GroceryUser> users = [];
  String title,des,theme;
  @override
  void initState() {
    super.initState();
  }
  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
      });
    });
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
              height:100,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.white.withOpacity(0.5),
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              width: 38.0,
                              height: 35.0,
                              child: Icon(
                                Icons.arrow_back,
                                color: theme=="light"?Colors.white:Colors.black,
                                size: 24.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Text(
                          getTranslated(context, "suggestions"),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 3,
                          style: GoogleFonts.cairo(
                            color: theme=="light"?Colors.white:Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(padding:const EdgeInsets.only(left: 10,right: 10),
                children: <Widget>[ Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 25.0,
                        ),
                        Text(
                          getTranslated(context, "suggestionText"),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 6,
                          style: GoogleFonts.cairo(
                            color: theme=="light"?Colors.black:Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "title"),
                              style: GoogleFonts.cairo(
                                color: theme=="light"?Colors.black:Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),),
                            Text(
                              "*", style: GoogleFonts.cairo(
                              color: Colors.red,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),),
                          ],
                        ),
                        SizedBox(height: 2,),
                        Container(height: 45,width: size.width,
                          padding: const EdgeInsets.only(left: 5,right: 5),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(35.0),

                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  height: 35,width:35,
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).primaryColor,

                                    shape: BoxShape.circle,
                                  ),child: Icon( Icons.title,size:25,
                                color: Colors.black,)),
                              SizedBox(width: 2,),
                              Expanded(flex:2,
                                child: Container(
                                  child:  TextFormField(
                                    enableInteractiveSelection:true,
                                    style: GoogleFonts.cairo(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                    cursorColor: Colors.black,
                                    keyboardType: TextInputType.name,
                                    onChanged: (value) {
                                      setState(() {
                                        title = value;
                                      });
                                    },
                                    decoration: new InputDecoration(
                                      hintStyle: GoogleFonts.cairo(
                                        color: Colors.grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                      hintText: getTranslated(context,'title'),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10,),

                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "description"),
                              style: GoogleFonts.cairo(
                                color: theme=="light"?Colors.black:Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),),
                            Text(
                              "*", style: GoogleFonts.cairo(
                              color: Colors.red,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),),
                          ],
                        ),
                        SizedBox(height: 2,),
                        Container(height: 150,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(35.0),

                          ),
                          child: Center(
                            child:Container(width: size.width*.7,
                              child: TextFormField(
                                maxLines: 5,
                                maxLength: 150,
                                style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),

                                cursorColor: Colors.black,
                                keyboardType: TextInputType.name,
                                onChanged: (value) {
                                  setState(() {
                                    des=value;
                                  });
                                },
                                decoration: new InputDecoration(
                                  hintStyle: GoogleFonts.cairo(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  hintText: getTranslated(context,'description'),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,

                                  //  hintText: sLabel
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),

                        SizedBox(
                          height: 25,
                        ),
                        Container(
                          height: 45.0,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: saving?Center(child: CircularProgressIndicator()):Center(
                            child: FlatButton(
                              onPressed: () {
                                save();
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Text(
                                getTranslated(context, "save"),
                                style: GoogleFonts.poppins(
                                  color: theme=="light"?Colors.white:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
        
    ]));
  }
 save() async {
   if (_formKey.currentState.validate()) {
     _formKey.currentState.save();
     try {
       setState(() {
         saving = true;
       });
       String suggestionId=Uuid().v4();
       await FirebaseFirestore.instance.collection(Paths.suggestionsPath)
           .doc(suggestionId)
           .set({
         "userUid":widget.loggedUser.uid,
         'suggestionId': suggestionId,
         'status': false,
         'sendTime': Timestamp.now(),
         'title': title,
         'desc':des,
         'userData': {
           'uid': widget.loggedUser.uid,
           'name': widget.loggedUser.name,
           'image': widget.loggedUser.photoUrl,
           'phone': widget.loggedUser.phoneNumber,
         },

       });
       setState(() {
         saving = false;
       });
       addingDialog(MediaQuery.of(context).size,true);
     } catch (e) {
       print("rrrrrrrrrr" + e.toString());
     }
   }
 }
  addingDialog(Size size,bool status) {

    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
           Text(
              getTranslated(context, "suggestions"),
              style: GoogleFonts.cairo(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 15.0,
            ),

            Text(
              getTranslated(context, "thanks"),
              style: GoogleFonts.cairo(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Center(
              child: Container(
                width: size.width*.5,
                child: FlatButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: GoogleFonts.cairo(
                      color: Colors.black87,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ), barrierDismissible: false,
      context: context,
    );
  }

  void showSnakbar(String s,bool status) {
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
      backgroundColor: status?Colors.lightGreen:Colors.red,
      action: SnackBarAction(
          label: 'OK', textColor: Colors.white, onPressed: () {}),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
