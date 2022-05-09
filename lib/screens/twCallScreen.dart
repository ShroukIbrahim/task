import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/setting.dart';
import 'package:grocery_store/models/timeHelper.dart';
import 'package:grocery_store/models/user.dart';
import 'package:twilio_voice/twilio_voice.dart';
import 'package:uuid/uuid.dart';

class VoiceCallScreen extends StatefulWidget {
  final GroceryUser? loggedUser;
  final AppAppointments? appointment ;
  final String? from ;
  const VoiceCallScreen({ this.loggedUser, this.appointment,this.from});
  @override
  _VoiceCallScreenState createState() => _VoiceCallScreenState();
}
//creete push notification
//https://githubmemory.com/repo/diegogarciar/twilio_voice/issues/39
//https://console.twilio.com/us1/develop/notify/try-it-out?frameUrl=%2Fconsole%2Fnotify%2Fcredentials%2FCR864c85133906feaf674f16b7e7a38b0b%3F__override_layout__%3Dembed%26bifrost%3Dtrue%26x-target-region%3Dus1
class _VoiceCallScreenState extends State<VoiceCallScreen> {
  var speaker = false;
  var mute = false;

  var isEnded = false;bool ending=false;
  bool endingCall=false;
  late AccountBloc accountBloc;
  String? message = "Connecting...";
  bool firstStateEnabled = false;
  bool showTimer=true;
  late StreamSubscription<CallEvent> callStateListener;
  final Dependencies dependencies = new Dependencies();
   bool logFound=false;
  void listenCall() {
    callStateListener = TwilioVoice.instance.callEventsListener.listen((event) async {
      print("voip-onCallStateChanged $event");
      switch (event) {

        case CallEvent.callEnded:
          if (!isEnded) {
            isEnded = true;
            Navigator.of(context).pop();

          }

          break;
        case CallEvent.log:
          print("lolololololololololo");
          print(CallEvent.log);
          if(widget.loggedUser!=null&&widget.loggedUser!.userType=="CONSULTANT"&&widget.appointment!=null)
          {
            showNoNotifSnack(getTranslated(context, "notAvalaible"));
          }

          break;
        case CallEvent.mute:
          print("received mute");
          if(mounted)
          setState(() {
            mute = true;
          });
          break;
        case CallEvent.unmute:
          print("received unmute");
          if(mounted)setState(() {
            mute = false;
          });
          break;
        case CallEvent.speakerOn:
          print("received speakerOn");
         if(mounted) setState(() {
            speaker = true;
          });
          break;
        case CallEvent.speakerOff:
          print("received speakerOf");
          if(mounted)setState(() {
            speaker = false;
          });
          break;
        case CallEvent.ringing:
          print("twiliocallstatus ringing");
          if(mounted) setState(() {
            message = "Ringing...";
          });
          break;
        case CallEvent.answer:
          print("twiliocallstatus answer");

          if(mounted)setState(() {
            message = "Answer...";
          });
          break;
        case CallEvent.connected:
          if(mounted)setState(() {
            message = "Connected...";
          });
          break;

        case CallEvent.hold:
         //case CallEvent.log:
        case CallEvent.unhold:
          break;
        default:
          break;
      }
    });
  }

  late String caller;
  void showNoNotifSnack(String text) {
    print("mmm12333333");
   /* Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: 500),
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
    )..show(context);*/
  }
  String getCaller() {
    final activeCall = TwilioVoice.instance.call.activeCall;
    if(widget.loggedUser!=null&&widget.loggedUser!.userType=="CONSULTANT"&&widget.appointment!=null)
      return widget.appointment!.user.name;
    else if(widget.loggedUser!=null&&widget.loggedUser!.userType!="CONSULTANT"&&widget.appointment!=null)
    return widget.appointment!.consult.name;
   /*if (activeCall != null) {
      print("optionssss");
      print(activeCall.customParams);
      Map<String, dynamic>? customParams=activeCall.customParams;
      String userName=customParams!['user']==null?"UnKnown Number":customParams['user'];
      String consultName=customParams['consult']==null?"UnKnown Number":customParams['consult'];
      return activeCall.callDirection == CallDirection.outgoing
          ?userName// activeCall.toFormatted
          :consultName;//activeCall.fromFormatted;
    }*/
    else
    return "Jeras App";
  }
  Future<void> callDone() async {
    try{
    //update appointment
    setState(() {
      ending=true;
    });
    await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment!.appointmentId).set({
      'appointmentStatus': "closed",
    }, SetOptions(merge: true));


    if(widget.appointment!.type!="fake"&&widget.loggedUser!=null&&widget.loggedUser!.userType=="CONSULTANT"&&widget.appointment!=null)
      {
        //update order
        DocumentReference orderRef = FirebaseFirestore.instance.collection(Paths.ordersPath).doc(widget.appointment!.orderId);
        final DocumentSnapshot orderSnapshot = await orderRef.get();
        var answeredCallNum= Orders.fromFirestore(orderSnapshot).answeredCallNum+1;
        var packageCallNum= Orders.fromFirestore(orderSnapshot).packageCallNum;

        await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(widget.appointment!.orderId).set({
          'answeredCallNum': answeredCallNum,
          'orderStatus':packageCallNum==answeredCallNum?"closed":Orders.fromFirestore(orderSnapshot).orderStatus
        }, SetOptions(merge: true));

        //update consultbalance
        DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.settingPath).doc("pzBqiphy5o2kkzJgWUT7");
        final DocumentSnapshot taxDocumentSnapshot = await docRef.get();
        var taxes= Setting.fromFirestore(taxDocumentSnapshot).taxes;

        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.loggedUser!.uid).get();
        GroceryUser currentUser = GroceryUser.fromFirestore(documentSnapshot);
        dynamic taxesvalue=(widget.appointment!.callPrice*taxes)/100;
        dynamic consultBalance=widget.appointment!.callPrice-taxesvalue;
        dynamic payedBalance=consultBalance;
        if(currentUser.payedBalance!=null)
          payedBalance=payedBalance+currentUser.payedBalance;
        
        if(currentUser.balance!=null)
          consultBalance=consultBalance+currentUser.balance;
        await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.loggedUser!.uid).set({
          'balance':consultBalance,
          'payedBalance':payedBalance,
        }, SetOptions(merge: true));
        accountBloc.add(GetAccountDetailsEvent(widget.loggedUser!.uid));
      }
    setState(() {
      ending=false;
    });
    Navigator.pop(context);
    Navigator.pop(context);
    }catch(e)
    {
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath)
          .doc(id)
          .set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.loggedUser == null ? " " : widget.loggedUser?.phoneNumber,
        'screen': "twCallScreen",
        'function': "callDone",
      });
    }
  }
  @override
  void initState() {
    accountBloc = BlocProvider.of<AccountBloc>(context);
    speaker=false;
    mute=false;
    listenCall();
    dependencies.stopwatch.start();
    super.initState();
    caller = getCaller();
  }

  @override
  void dispose() {
    super.dispose();
    callStateListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF7b6c94),//Colors.lightBlueAccent,//Theme.of(context).accentColor,
        body: Container(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        caller,
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      if (message != null)
                        Text(
                         message!,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: Colors.white),
                        )
                    ],
                  ),
                 SizedBox(),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Material(
                          type: MaterialType
                              .transparency, //Makes it usable on any background color, thanks @IanSmith
                          child: Ink(
                            decoration: BoxDecoration(
                              border:
                              Border.all(color: Colors.white, width: 1.0),
                              color: speaker
                                  ?AppColors.brown// Theme.of(context).primaryColor
                                  : Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(
                                  1000.0), //Something large to ensure a circle
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.volume_up,
                                  size: 40.0,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                 setState(() {
                                   speaker = !speaker;
                                 });

                                   TwilioVoice.instance.call.toggleSpeaker(speaker);

                              },
                            ),
                          ),
                        ),
                        Material(
                          type: MaterialType
                              .transparency, //Makes it usable on any background color, thanks @IanSmith
                          child: Ink(
                            decoration: BoxDecoration(
                              border:
                              Border.all(color: Colors.white, width: 1.0),
                              color: mute
                                  ? AppColors.brown//Theme.of(context).accentColor
                                  : Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(
                                  1000.0), //Something large to ensure a circle
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.mic_off,
                                  size: 40.0,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                print("mute!");
                                setState(() {
                                  mute = !mute;
                                });
                                TwilioVoice.instance.call.toggleMute(mute);
                                // setState(() {
                                //   mute = !mute;
                                // });
                              },
                            ),
                          ),
                        )
                      ]),
                  RawMaterialButton(
                    elevation: 2.0,
                    fillColor: Colors.red,
                    child: Icon(
                      Icons.call_end,
                      size: 40.0,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(20.0),
                    shape: CircleBorder(),
                    onPressed: () async {
                      TwilioVoice.instance.call.hangUp();
                     /* final isOnCall = await TwilioVoice.instance.call.isOnCall();
                      if (widget.loggedUser!=null&&widget.loggedUser!.userType=="CONSULTANT") {
                        TwilioVoice.instance.call.hangUp();
                      }
                      else
                        Navigator.of(context).pop();*/
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }
  endCallDialog(Size size) {
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
        content: StatefulBuilder(builder: (context, setState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              SizedBox(
                height: 15.0,
              ),
              Text(
                getTranslated(context, "doesCallEndWithClient"),
                style: GoogleFonts.cairo(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: Colors.black87,
                ),
              ),

              SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: 50.0,
                    child: FlatButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        getTranslated(context, 'no'),
                        style: GoogleFonts.cairo(
                          color: Colors.black87,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  endingCall?Center(child: CircularProgressIndicator()): Container(
                    width: 50.0,
                    child: FlatButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        //Navigator.pop(context);
                       setState(() {
                         endingCall=true;
                       });
                       if(widget.loggedUser!=null&&widget.loggedUser!.userType=="CONSULTANT"&&widget.appointment!=null)
                         callDone();
                      },
                      child: Text(
                        getTranslated(context, 'yes'),
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
          );},
        ),
      ), barrierDismissible: false,
      context: context,
    );
  }
  endUserCallDialog(Size size) {

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

            SizedBox(
              height: 15.0,
            ),
            Text(
              getTranslated(context, "callTimeEnd"),
              style: GoogleFonts.cairo(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),

            SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: 50.0,
                  child: FlatButton(
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () {
                      Navigator.pop(context);
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

              ],
            ),
          ],
        ),
      ), barrierDismissible: false,
      context: context,
    );
  }

}
