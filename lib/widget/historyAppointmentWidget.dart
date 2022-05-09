// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/twCallScreen.dart';
import 'package:intl/intl.dart';
import 'package:twilio_voice/twilio_voice.dart';

import '../screens/AppointmentChatScreen.dart';



class HistoryAppointmentWiget extends StatelessWidget {
  final GroceryUser loggedUser;
  final AppAppointments appointment;
  final String theme;
  HistoryAppointmentWiget({this.appointment,this.loggedUser, this.theme});
  @override
  Widget build(BuildContext context) {
    String lang=getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    String time;
    DateFormat dateFormat = DateFormat('MM/dd/yy');
    DateTime localDate=DateTime.parse(appointment.appointmentTimestamp.toDate().toString()).toLocal();
    if(localDate.hour==12)
      time="12 Pm";
    else if(localDate.hour==0)
      time="12 Am";
    else if(localDate.hour>12)
      time=(localDate.hour-12).toString()+":"+localDate.minute.toString()+"Pm";
    else
      time=(localDate.hour).toString()+":"+localDate.minute.toString()+"Am";
    /*if(appointment.time.hour>12)
      time=(appointment.time.hour-12).toString()+":"+appointment.time.minute.toString()+" Pm";
    else
      time=(appointment.time.hour).toString()+":"+appointment.time.minute.toString()+" Am";*/
    return GestureDetector(
      onTap: () {

      },
      child:Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30,right: 30),
            child: Row(mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 35,
                  width: size.width*.4,
                  // padding:const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
                  decoration: BoxDecoration(
                      color: AppColors.brown,
                      borderRadius: new BorderRadius.only(
                        topLeft:lang!="ar"? Radius.circular(20.0): Radius.circular(40.0),
                        topRight:lang!="ar"? Radius.circular(40.0): Radius.circular(20.0),
                      )
                  ),child :Center(
                  child: Text(
                    time,
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                ),),
              ],
            ),
          ),
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
                      SizedBox(height: 5,),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appointment.user.name!=null?appointment.user.name:appointment.user.phone,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.cairo(
                                color: theme=="light"?Colors.white:Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Container(height: 30,width: size.width*.2,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(15.0),
                              ),child:Center(
                                child: Text(
                                double.parse(appointment.callPrice.toString()).toStringAsFixed(3)+"\$",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),),
                          ],
                        ),
                      ),
                      SizedBox(height: 5,),
                      Container(decoration: BoxDecoration(
                          color: theme=="light"?Colors.white:Colors.black,
                          borderRadius: new BorderRadius.only(
                            bottomRight: const Radius.circular(25.0),
                            bottomLeft: const Radius.circular(25.0),
                          )
                      ),width: size.width,height: 50,  child:
                      Row(children: [
                        Expanded(flex:1,child:  InkWell(
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
                                    width: 25,
                                    height: 25,
                                  ),
                                  appointment.userChat>0?Positioned(
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
                                color: Theme.of(context).primaryColor,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],),
                        )),
                      ],),
                      )
                    ],
                  )),

          SizedBox(height: 20,)
        ],
      ),
    );
  }

}
