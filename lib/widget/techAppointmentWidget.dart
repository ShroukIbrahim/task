// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/SupportList.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/supportMessagesScreen.dart';
import 'package:intl/intl.dart';

class TechAppointmentWiget extends StatefulWidget {
  final AppAppointments appointment;
  final String theme;
  final GroceryUser loggedUser;
  TechAppointmentWiget({this.appointment, this.theme, this.loggedUser});

  @override
  _TechAppointmentWigetState createState() => _TechAppointmentWigetState();
}
class _TechAppointmentWigetState extends State<TechAppointmentWiget>with SingleTickerProviderStateMixin {
  bool userChating=false,consultChating=false;
  @override
  void initState() {
    super.initState();

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
    //String time=(widget.appointment.time.hour).toString()+":"+widget.appointment.time.minute.toString();

   /* if(widget.appointment.time.hour>12)
      time=(widget.appointment.time.hour-12).toString()+":"+widget.appointment.time.minute.toString()+"Pm";
    else
      time=(widget.appointment.time.hour).toString()+":"+widget.appointment.time.minute.toString()+"Am";*/
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
              Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    getTranslated(context, "client")+widget.appointment.user.name,
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
                  userChating?CircularProgressIndicator():ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.white.withOpacity(0.5),
                        onTap: () {
                          startUserChating();
                        },
                        child: Icon(
                          Icons.chat_outlined,
                          color: widget.theme=="light"?Colors.white:Colors.black,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2,),
              Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    getTranslated(context, "const")+widget.appointment.consult.name,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.cairo(
                      color: widget.theme=="light"?Colors.white:Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  consultChating?CircularProgressIndicator():ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.white.withOpacity(0.5),
                        onTap: () {
                          startConsultChating();
                        },
                        child: Icon(
                          Icons.chat_outlined,
                          color: widget.theme=="light"?Colors.white:Colors.black,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2,),
              Text(
                getTranslated(context, "callStatus"),
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
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 40,width: size.width*.3,
                    decoration: BoxDecoration(
                      color: AppColors.brown,
                      borderRadius: BorderRadius.circular(20.0),
                    ),child:Center(
                      child: Text(
                        widget.appointment.appointmentStatus=="new"?getTranslated(context, "new"):widget.appointment.appointmentStatus=="open"?
                        getTranslated(context, "open"):widget.appointment.appointmentStatus=="closed"?getTranslated(context, "closed"):getTranslated(context, "canceled"),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: AppColors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),),
                  SizedBox(width: 5,),
                  widget.appointment.type==null?SizedBox():Container(height: 40,width: size.width*.3,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),child:Center(
                      child: Text(
                        widget.appointment.type,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: AppColors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),),
                ],
              ),
              SizedBox(height: 6,),
              Row(mainAxisAlignment:MainAxisAlignment.center,children: [
                Container(child:
                Row(mainAxisAlignment: MainAxisAlignment.start,children: [
                  Image.asset('assets/applicationIcons/Iconly-Two-tone-Calendar.png',
                    width: 25,
                    height: 25,
                  ),
                  SizedBox(width: 5,),
                  Text(
                    '${dateFormat.format(localDate)}',
                    //'${dateFormat.format(widget.appointment.appointmentTimestamp.toDate())}',
                   // DateFormat.yMMMd().format(DateTime.parse(widget.appointment.appointmentTimestamp.toDate().toString())).toString(), // Apr
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
                  Image.asset('assets/applicationIcons/whiteTime.png',
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
            ],
          )),

          SizedBox(height: 20,)
        ],
      ),
    );
  }
  startUserChating() async{
    setState(() {
      userChating=true;
    });
    QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection("SupportList")
        .where( 'userUid', isEqualTo: widget.appointment.user.uid, ).limit(1).get();
    if(querySnapshot!=null&&querySnapshot.docs.length!=0)
    {
      var item=SupportList.fromFirestore(querySnapshot.docs[0]);
      item.userName=widget.appointment.user.name;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportMessageScreen(
              item: item,
              user:widget.loggedUser), ),);
      setState(() {
        userChating=false;
      });

    }
    else
    {
      setState(() {
        userChating=false;
      });
    }
  }
  startConsultChating() async{
    setState(() {
      consultChating=true;
    });
    QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection("SupportList")
        .where( 'userUid', isEqualTo: widget.appointment.consult.uid, ).limit(1).get();
    if(querySnapshot!=null&&querySnapshot.docs.length!=0)
    {
      var item=SupportList.fromFirestore(querySnapshot.docs[0]);
      item.userName=widget.appointment.consult.name;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportMessageScreen(
              item: item,
              user:widget.loggedUser), ),);
      setState(() {
        consultChating=false;
      });

    }
    else
    {
      setState(() {
        consultChating=false;
      });
    }
  }
}
