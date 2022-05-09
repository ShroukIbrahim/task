// @dart=2.9
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/AppointmentChatScreen.dart';
import 'package:grocery_store/screens/consultantDetailsScreen.dart';
import 'package:grocery_store/screens/twCallScreen.dart';
import 'package:intl/intl.dart';
import 'package:twilio_voice/twilio_voice.dart';



class UserAppointmentWiget extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GroceryUser loggedUser;
  final AppAppointments appointment;
  final String theme;
  UserAppointmentWiget({this.appointment,this.loggedUser, this.theme});
  @override
  Widget build(BuildContext context) {
    String lang=getTranslated(context, "lang");
    var size = MediaQuery.of(context).size;
    String time;
    DateFormat dateFormat = DateFormat('MM/dd/yy');
    DateTime localDate;
    if(appointment.utcTime!=null)
      localDate=DateTime.parse(appointment.utcTime).toLocal();
    else
      localDate=DateTime.parse(appointment.appointmentTimestamp.toDate().toString()).toLocal();

    if(localDate.hour==12)
      time="12 Pm";
    else if(localDate.hour==0)
      time="12 Am";
    else if(localDate.hour>12)
      time=(localDate.hour-12).toString()+":"+localDate.minute.toString()+"Pm";
    else
      time=(localDate.hour).toString()+":"+localDate.minute.toString()+"Am";
    return GestureDetector(
      onTap: () {

      },
      child:Column(
        children: [
          Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 0.0),
                    blurRadius: 15.0,
                    spreadRadius: 2.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),child:Column(
                children: [
                  Text(
                    appointment.consult.name!=null?appointment.consult.name:appointment.consult.phone,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.cairo(
                      color: theme=="light"? Colors.white:Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 2,),
                  Text(
                    getTranslated(context, "callStatus"),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.cairo(
                      color: theme=="light"? Colors.white:Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2,),
                  InkWell(
                    splashColor: Colors.green.withOpacity(0.5),
                    onTap: () async {
                    },
                    child: Container(height: 40,width: size.width*.3,
                      decoration: BoxDecoration(
                        color: AppColors.brown,
                        borderRadius: BorderRadius.circular(20.0),
                      ),child:Center(
                        child: Text(
                          appointment.appointmentStatus=="new"?getTranslated(context, "new"): appointment.appointmentStatus=="open"?getTranslated(context, "open"):
                          appointment.appointmentStatus=="closed"?getTranslated(context, "closed"):getTranslated(context, "canceled"),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: AppColors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),),
                  ),
                  SizedBox(height: 6,),
                  Row(mainAxisAlignment:MainAxisAlignment.center,children: [
                    Container(child:
                    Row(mainAxisAlignment: MainAxisAlignment.start,children: [
                      Image.asset(theme=="light"?'assets/applicationIcons/Iconly-Two-tone-Calendar.png':'assets/applicationIcons/Iconly-Two-tone-CalendarCons.png',
                        width: 25,
                        height: 25,
                      ),
                      SizedBox(width: 5,),
                      Text(
                       '${dateFormat.format(localDate)}',
                        //DateFormat.yMMMd().format(DateTime.parse(appointment.appointmentTimestamp.toDate().toString())).toString(), // Apr
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.cairo(
                          color: theme=="light"?Colors.white:Colors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],)
                    ),
                    SizedBox(width: 30,),
                    Container(child:
                    Row(mainAxisAlignment: MainAxisAlignment.start,children: [
                      Image.asset(theme=="light"?'assets/applicationIcons/whiteTime.png':'assets/applicationIcons/hourGray.png',
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 5,),
                      Text(
                        time,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.cairo(
                          color: theme=="light"?Colors.white:Colors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],)

                    )
                  ],),
                  SizedBox(height: 6,),
                  //theme=="light"?
                  Container(height: 1,width: size.width,color: AppColors.grey,),
                  Container(decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                        bottomRight: const Radius.circular(25.0),
                        bottomLeft: const Radius.circular(25.0),
                      )
                  ),width: size.width,height: 50,
                    child: appointment.appointmentStatus!="open"?
                     InkWell(
                      splashColor: Colors.green.withOpacity(0.5),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentChatScreen(
                                appointment: appointment,
                                user:loggedUser
                            ),
                          ),
                        );
                      },
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                        Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Image.asset(theme=="light"?
                              'assets/applicationIcons/Iconly-Two-tone-Chat.png':'assets/applicationIcons/Iconly-Two-tone-Chat1.png',
                                width: 20,
                                height: 20,
                              ),
                              appointment.consultChat>0?Positioned(
                                left: 1.0,
                                top: 1.0,
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber,
                                  ),
                                ),
                              ):SizedBox()
                            ]),
                        Text(
                          getTranslated(context, "message"),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.cairo(
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],),
                    )
                        :Row(children: [
                          Expanded(flex:1,child:  InkWell(
                            splashColor: Colors.green.withOpacity(0.5),
                            onTap: () async {
                             showNoNotifSnack(context,getTranslated(context, "callOnTime"));
                            },
                            child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                              Image.asset(theme=="light"?
                              'assets/applicationIcons/Iconly-Two-tone-Calling.png':'assets/applicationIcons/Iconly-Two-tone-Calling1.png',
                                width: 20,
                                height: 20,
                              ),
                              Text(
                                getTranslated(context, "calling"),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],),
                          )),
                          Container(height: 50,width: 1,color: AppColors.grey,),
                          Expanded(flex:1,child:InkWell(
                            splashColor: Colors.green.withOpacity(0.5),
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppointmentChatScreen(
                                      appointment: appointment,
                                      user:loggedUser
                                  ),
                                ),
                              );
                            },
                            child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                              Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Image.asset(theme=="light"?
                                    'assets/applicationIcons/Iconly-Two-tone-Chat.png':'assets/applicationIcons/Iconly-Two-tone-Chat1.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    appointment.consultChat>0?Positioned(
                                      left: 1.0,
                                      top: 1.0,
                                      child: Container(
                                        height: 10,
                                        width: 10,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ):SizedBox()
                                  ]),
                              Text(
                                getTranslated(context, "message"),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],),
                          ))
                        ],),
                  )
                ],
              )),

          SizedBox(height: 20,)
        ],
      ),
    );
  }
  void showNoNotifSnack(BuildContext context,String text) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1.0,
          blurRadius: 5.0,
          offset: Offset(0.0, 2.0),
        )
      ],
      shouldIconPulse: false,
      duration: Duration(milliseconds: 1500),
      icon: Icon(
        Icons.notification_important,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.cairo(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }
}
