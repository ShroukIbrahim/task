// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/DevelopTechSupport.dart';
import 'package:grocery_store/models/promoCode.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/addFakeAppointment.dart';
import 'package:grocery_store/widget/appointmentWidget.dart';
import 'package:grocery_store/widget/developListItem.dart';
import 'package:grocery_store/widget/promoListItem.dart';
import 'package:grocery_store/widget/techAppointmentWidget.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:uuid/uuid.dart';

import 'developMessageScreen.dart';


class AllDevelopTechScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const AllDevelopTechScreen({Key key, this.loggedUser}) : super(key: key);
  @override
  _AllDevelopTechScreenState createState() => _AllDevelopTechScreenState();
}

class _AllDevelopTechScreenState extends State<AllDevelopTechScreen>with SingleTickerProviderStateMixin {
  bool load=false,_new=true,_open=false,_done=false,_closed=false,saving=false,showText=false;
  final TextEditingController titleController = new TextEditingController();

  String theme;
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
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
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
                child: Container(height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Text(
                        getTranslated(context, "development"),
                        style: GoogleFonts.poppins(
                          color:theme=="light"?Colors.white:Colors.black,
                          fontSize: 19.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.white.withOpacity(0.5),
                            onTap: () {
                              addDialog(size);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              width: 38.0,
                              height: 35.0,
                              child: Icon(
                                Icons.add_circle_outline,
                                color:theme=="light"?Colors.white:Colors.black,
                                size: 24.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 1,),
          Center(
            child:  Container(height: 60,width: size.width,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.0),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 0.0),
                      blurRadius: 15.0,
                      spreadRadius: 2.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            _new=true;
                            _open=false;
                            _done=false;
                            _closed=false;
                          });
                        },
                        child: Container(height: 40,width: size.width*.20,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _new?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),child:Center(
                            child: Text(
                              "New",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: _new?theme=="light"?Colors.white:Colors.white:theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),),
                      ),
                      SizedBox(width: 5,),
                      InkWell(
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            _new=false;
                            _open=true;
                            _done=false;
                            _closed=false;
                          });
                        },
                        child: Container(height: 40,width: size.width*.20,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _open?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),child:Center(
                            child: Text(
                              "Open",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: _open?theme=="light"?Colors.white:Colors.white:theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),),
                      ),
                      SizedBox(width: 5,),
                      InkWell(
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            _new=false;
                            _open=false;
                            _done=true;
                            _closed=false;
                          });
                        },
                        child: Container(height: 40,width: size.width*.20,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _done?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),child:Center(
                            child: Text(
                            "Done",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: _done?theme=="light"?Colors.white:Colors.white:theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),),
                      ),
                      SizedBox(width: 5,),
                      InkWell(
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            _new=false;
                            _open=false;
                            _done=false;
                            _closed=true;
                          });
                        },
                        child: Container(height: 40,width: size.width*.20,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _closed?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),child:Center(
                            child: Text(
                             "Closed",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: _closed?theme=="light"?Colors.white:Colors.white:theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),),
                      ),
                    ])
            ),
          ),
          SizedBox(height: 10,),
          _new?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  DevelopListItem(
                    size:size,
                    item: DevelopTechSupport.fromFirestore(documentSnapshot[index]),
                    theme:theme,
                    user:widget.loggedUser
                );
              },
              query: FirebaseFirestore.instance.collection(Paths.developTechSupportPath)
                  .where('status', isEqualTo:"new")
                  .orderBy('sendTime', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(),
          _open?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  DevelopListItem(
                    size:size,
                    item: DevelopTechSupport.fromFirestore(documentSnapshot[index]),
                    theme:theme,
                    user:widget.loggedUser
                );
              },
              query: FirebaseFirestore.instance.collection(Paths.developTechSupportPath)
                  .where('status', isEqualTo:"open")
                  .orderBy('sendTime', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(),
          _done?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  DevelopListItem(
                    size:size,
                    item: DevelopTechSupport.fromFirestore(documentSnapshot[index]),
                    theme:theme,
                    user:widget.loggedUser
                );
              },
              query: FirebaseFirestore.instance.collection(Paths.developTechSupportPath)
                  .where('status', isEqualTo:"done")
                  .orderBy('sendTime', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(),
          _closed?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  DevelopListItem(
                    size:size,
                    item: DevelopTechSupport.fromFirestore(documentSnapshot[index]),
                    theme:theme,
                    user:widget.loggedUser
                );
              },
              query: FirebaseFirestore.instance.collection(Paths.developTechSupportPath)
                  .where('status', isEqualTo:"closed")
                  .orderBy('sendTime', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(),
        ],
      ),

    );
  }

  addDialog(Size size) {

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
          content:StatefulBuilder(builder: (context, setState) {
            return
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[

                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    getTranslated(context, "developNotes"),
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(width: size.width * .6,
                    height: 55,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextFormField(
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      enableInteractiveSelection: false,
                      style: GoogleFonts.cairo(
                        fontSize: 14.0,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                        border: InputBorder.none,
                        hintText: getTranslated(context, "title"),
                        hintStyle: GoogleFonts.cairo(
                          fontSize: 14.0,
                          color: Colors.black54,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w400,
                        ),
                        counterStyle: GoogleFonts.cairo(
                          fontSize: 12.5,
                          color: Colors.black54,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),

                  showText?Text(
                    getTranslated(context, "required"),
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ):SizedBox(),
                  SizedBox(height: 10.0,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        child: FlatButton(
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () {
                            setState(() {
                              load = false;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            getTranslated(context, 'cancel'),
                            style: GoogleFonts.cairo(
                              color: Colors.black87,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      saving ? CircularProgressIndicator() : Container(
                        width: 50.0,
                        child: FlatButton(
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () async {
                            if(titleController.text==null||titleController.text=="")
                              setState(() {
                                showText = true;
                              });
                            else
                              {
                                setState(() {
                                  showText=false;
                                  saving = true;
                                });
                                String developListId=Uuid().v4();
                                await FirebaseFirestore.instance.collection(Paths.developTechSupportPath).doc(developListId).set({
                                  'developTechSupportId': developListId,
                                  'status': "new",
                                  'sendTime': FieldValue.serverTimestamp(),
                                  'owner': widget.loggedUser.userType,
                                  'userUid': widget.loggedUser.uid,
                                  'userName':widget.loggedUser.name,
                                  'title': titleController.text,
                                });
                                setState(() {
                                  saving = false;
                                });
                                Navigator.pop(context);
                              }

                          },
                          child: Text(
                            getTranslated(context, 'save'),
                            style: GoogleFonts.cairo(
                              color: Colors.red.shade700,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
          })
      ), barrierDismissible: false,
      context: context,
    );
  }

}
