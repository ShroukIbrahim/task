// @dart=2.9
import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/AppointmentChatScreen.dart';
import 'package:grocery_store/screens/videoScreen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
class AppointmentWiget extends StatefulWidget {
  final GroceryUser loggedUser;
  final AppAppointments appointment;
  final String theme;
  AppointmentWiget({this.appointment,this.loggedUser, this.theme});

  @override
  _AppointmentWigetState createState() => _AppointmentWigetState();
}
class _AppointmentWigetState extends State<AppointmentWiget>with SingleTickerProviderStateMixin {
  AccountBloc accountBloc;

  bool acceptLoad=false,loadingCall=false;
  @override
  void initState() {
    super.initState();

    accountBloc = BlocProvider.of<AccountBloc>(context);
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String time;
    DateFormat dateFormat = DateFormat('MM/dd/yy');
    DateTime localDate;
    if(widget.appointment.utcTime!=null)
      localDate=DateTime.parse(widget.appointment.utcTime).toLocal();
    else
      localDate=DateTime.parse(widget.appointment.appointmentTimestamp.toDate().toString()).toLocal();
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
                  widget.appointment.user.name!=null?widget.appointment.user.name:widget.appointment.user.phone,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.cairo(
                    color: widget.theme=="light"?Colors.white:Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2,),
                Text(
                  ((widget.appointment.consultType=="perfect"||widget.appointment.consultType=="jeras")&&widget.appointment.appointmentStatus=="open")?getTranslated(context, "remainingCalls"):getTranslated(context, "callStatus"),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.cairo(
                    color: widget.theme=="light"?Colors.white:Colors.black,
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2,),
                Container(height: 40,width: size.width*.3,
                  decoration: BoxDecoration(
                    color: AppColors.brown,
                    borderRadius: BorderRadius.circular(20.0),
                  ),child:Center(
                    child: Text(
                      ((widget.appointment.consultType=="perfect"||widget.appointment.consultType=="jeras")&&widget.appointment.appointmentStatus=="open")? widget.appointment.remainingCallNum.toString():
                      widget.appointment.appointmentStatus=="new"?getTranslated(context, "new"): widget.appointment.appointmentStatus=="open"?getTranslated(context, "open"):
                     widget.appointment.appointmentStatus=="closed"?getTranslated(context, "closed"):getTranslated(context, "canceled"),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: AppColors.white,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),),
                SizedBox(height: 6,),
                Row(mainAxisAlignment:MainAxisAlignment.center,children: [
                  Container(child:
                   Row(mainAxisAlignment: MainAxisAlignment.start,children: [
                     Image.asset(widget.theme=="light"?'assets/applicationIcons/Iconly-Two-tone-Calendar.png':'assets/applicationIcons/Iconly-Two-tone-CalendarCons.png',
                       width: 25,
                       height: 25,
                     ),
                    SizedBox(width: 5,),
                    Text(
                      '${dateFormat.format(localDate)}',
                      //'${dateFormat.format(widget.appointment.appointmentTimestamp.toDate())}',
                      //DateFormat.yMMMd().format(DateTime.parse(widget.appointment.appointmentTimestamp.toDate().toString())).toString(), // Apr
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.cairo(
                        color: widget.theme=="light"?Colors.white:Colors.black,
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
                    Image.asset(widget.theme=="light"?'assets/applicationIcons/whiteTime.png':'assets/applicationIcons/hourGray.png',
                      width: 25,
                      height: 25,
                    ),
                    SizedBox(width: 5,),
                    Text(
                      time,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.cairo(
                        color: widget.theme=="light"?Colors.white:Colors.black,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],)

                  )
                ],),
                SizedBox(height: 6,),
                ( widget.appointment.appointmentStatus=="open"&&widget.loggedUser.chat&&widget.loggedUser.voice)?
                Container(decoration: BoxDecoration(
                    color: widget.theme=="light"?Colors.white:Colors.black,
                    borderRadius: new BorderRadius.only(
                      bottomRight: const Radius.circular(25.0),
                      bottomLeft: const Radius.circular(25.0),
                    )
                ),width: size.width,height: 50,
                  child: Row(children: [
                    Expanded(flex:1,child:loadingCall?Center(child: CircularProgressIndicator()):InkWell(
                      splashColor: Colors.green.withOpacity(0.5),
                      onTap: () async {
                       agoraCall();
                      },
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                        Image.asset(widget.theme=="light"?
                        'assets/applicationIcons/Iconly-Two-tone-Calling.png':'assets/applicationIcons/Iconly-Two-tone-Calling1.png',
                          width: 25,
                          height: 25,
                        ),
                        Text(
                          getTranslated(context, "calling"),
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
                    Container(height: 50,width: 1,color: AppColors.grey,),
                    Expanded(flex:1,child:  InkWell(
                    splashColor: Colors.green.withOpacity(0.5),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentChatScreen(
                              appointment: widget.appointment,
                              user:widget.loggedUser
                          ),
                        ),
                      );
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                      Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                           Image.asset(widget.theme=="light"?
                            'assets/applicationIcons/Iconly-Two-tone-Chat.png':'assets/applicationIcons/Iconly-Two-tone-Chat1.png',
                              width: 25,
                              height: 25,
                            ),
                            widget.appointment.userChat>0?Positioned(
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
                ):SizedBox(),
                ( widget.appointment.appointmentStatus=="open"&&widget.loggedUser.chat==false&&widget.loggedUser.voice)? Container(decoration: BoxDecoration(
                    color: widget.theme=="light"?Colors.white:Colors.black,
                    borderRadius: new BorderRadius.only(
                      bottomRight: const Radius.circular(25.0),
                      bottomLeft: const Radius.circular(25.0),
                    )
                ),width: size.width,height: 50,
                  child: Row(mainAxisAlignment:MainAxisAlignment.center,children: [
                    Expanded(flex:1,child: loadingCall?Center(child: CircularProgressIndicator()): InkWell(
                      splashColor: Colors.green.withOpacity(0.5),
                      onTap: () async {agoraCall();},
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                        Image.asset(widget.theme=="light"?
                        'assets/applicationIcons/Iconly-Two-tone-Calling.png':'assets/applicationIcons/Iconly-Two-tone-Calling1.png',
                          width: 25,
                          height: 25,
                        ),
                        Text(
                          getTranslated(context, "calling"),
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
                ):SizedBox(),
                ( widget.appointment.appointmentStatus=="open"&&widget.loggedUser.chat&&widget.loggedUser.voice==false)? Container(decoration: BoxDecoration(
                    color: widget.theme=="light"?Colors.white:Colors.black,
                    borderRadius: new BorderRadius.only(
                      bottomRight: const Radius.circular(25.0),
                      bottomLeft: const Radius.circular(25.0),
                    )
                ),width: size.width,height: 50,
                  child: Row(mainAxisAlignment:MainAxisAlignment.center,children: [
                    Expanded(flex:1,child:  InkWell(
                      splashColor: Colors.green.withOpacity(0.5),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentChatScreen(
                                appointment: widget.appointment,
                                user:widget.loggedUser
                            ),
                          ),
                        );
                      },
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                        Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Image.asset(widget.theme=="light"?
                              'assets/applicationIcons/Iconly-Two-tone-Chat.png':'assets/applicationIcons/Iconly-Two-tone-Chat1.png',
                                width: 25,
                                height: 25,
                              ),
                              widget.appointment.userChat>0?Positioned(
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
                          getTranslated(context, "message"),//+"."+widget.appointment.consultChat.toString(),
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
                ):SizedBox(),
                widget.appointment.appointmentStatus=="new"?Container(decoration: BoxDecoration(
                    color: widget.theme=="light"?Colors.white:Colors.black,
                     borderRadius: new BorderRadius.only(
                     bottomRight: const Radius.circular(25.0),
                     bottomLeft: const Radius.circular(25.0),
                   )
                   ),width: size.width,height: 50,  child:
                Row(children: [
                   Expanded(flex:1,child:   acceptLoad?Center(child: CircularProgressIndicator(),):InkWell(
                     splashColor: Colors.green.withOpacity(0.5),
                     onTap: () async {
                       setState(() {
                         acceptLoad=true;
                       });
                       await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
                         'appointmentStatus': "open",
                       }, SetOptions(merge: true));
                       setState(() {
                         acceptLoad=false;
                       });
                     },
                     child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                       Text(
                         getTranslated(context, "accept1"),
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
                   Container(height: 50,width: 1,color: AppColors.grey,),
                   Expanded(flex:1,child:  InkWell(
                     splashColor: Colors.green.withOpacity(0.5),
                     onTap: () async {
                        await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
                        'appointmentStatus': "cancel",
                        }, SetOptions(merge: true));
                     },
                     child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                     /*  Image.asset(widget.theme=="light"?
                       'assets/applicationIcons/Iconly-Two-tone-Chat.png':'assets/applicationIcons/Iconly-Two-tone-Chat.png',
                         width: 25,
                         height: 25,
                       ),*/
                       Text(
                         getTranslated(context, "refuse1"),
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
                  Container(height: 50,width: 1,color: AppColors.grey,),
                  Expanded(flex:1,child:  InkWell(
                    splashColor: Colors.green.withOpacity(0.5),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentChatScreen(
                              appointment: widget.appointment,
                              user:widget.loggedUser
                          ),
                        ),
                      );
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                      Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Image.asset(widget.theme=="light"?
                            'assets/applicationIcons/Iconly-Two-tone-Chat.png':'assets/applicationIcons/Iconly-Two-tone-Chat1.png',
                              width: 25,
                              height: 25,
                            ),
                            widget.appointment.userChat>0?Positioned(
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
               ):SizedBox(),
                ( widget.appointment.appointmentStatus=="closed")?
                Container(decoration: BoxDecoration(
                    color: widget.theme=="light"?Colors.white:Colors.black,
                    borderRadius: new BorderRadius.only(
                      bottomRight: const Radius.circular(25.0),
                      bottomLeft: const Radius.circular(25.0),
                    )
                ),width: size.width,height: 50,
                  child: Row(mainAxisAlignment:MainAxisAlignment.center,children: [ InkWell(
                      splashColor: Colors.green.withOpacity(0.5),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentChatScreen(
                                appointment: widget.appointment,
                                user:widget.loggedUser
                            ),
                          ),
                        );
                      },
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                        Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Image.asset(widget.theme=="light"?
                              'assets/applicationIcons/Iconly-Two-tone-Chat.png':'assets/applicationIcons/Iconly-Two-tone-Chat1.png',
                                width: 25,
                                height: 25,
                              ),
                              widget.appointment.userChat>0?Positioned(
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
                    )
                  ],),
                ):SizedBox(),
              ],
            )),

          SizedBox(height: 20,)
        ],
      ),
    );
  }

  agoraCall() async {
    try{
      print("yarb11");
      setState(() {
        loadingCall=true;
      });
      Map notifMap = Map();
      notifMap.putIfAbsent('consultName', () => widget.appointment.consult.name);
      notifMap.putIfAbsent('userId', () => widget.appointment.user.uid);
      notifMap.putIfAbsent('appointmentId', () => widget.appointment.appointmentId);
      var refundRes= await http.post( Uri.parse('https://us-central1-app-jeras.cloudfunctions.net/sendCallNotification'),
        body: notifMap,
      );
     // var refund = jsonDecode(refundRes.body);
      print(refundRes.body.toString());
      if (refundRes.body.toString().contains("Error")) {
        print("sendnotification111222  error");
        showSnack(getTranslated(context, "error"), context);
      }
      await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
        'allowCall':true,
      }, SetOptions(merge: true));
      Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(
          fullscreenDialog: true, builder: (context) =>
         // AgoraVideoCall(user:widget.loggedUser,appointment:widget.appointment,appointmentId: widget.appointment.appointmentId,)));

    VideoCallScreen(user:widget.loggedUser,appointment:widget.appointment,appointmentId: widget.appointment.appointmentId,)));
      setState(() {
        loadingCall=false;
      });
     /* var refund = jsonDecode(refundRes.body);
      print(refund.toString());
      if (refund['message'] != 'Success') {
        print("sendnotification111222  error");
        print(refund['data']);
        showSnack(getTranslated(context, "error"),context);
        setState(() {
          loadingCall=false;
        });
      }
      else
      {
        print("sendnotification1111 success");
        await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
        'allowCall':true,
      }, SetOptions(merge: true));
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(
            fullscreenDialog: true, builder: (context) =>
            VideoCallScreen(user:widget.loggedUser,appointment:widget.appointment,appointmentId: widget.appointment.appointmentId,)));
        setState(() {
          loadingCall=false;
        });
      }*/
    }catch(e){
      print("sendnotification111  "+e.toString());
      showSnack(getTranslated(context, "error"),context);
      setState(() {
        loadingCall=false;
      });
    }


  }
  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.red.shade500,
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
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.error,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }
}
