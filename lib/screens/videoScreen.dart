// @dart=2.9
import 'dart:async';
import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pip_view/pip_view.dart';
import 'package:uuid/uuid.dart';

import '../Utils/utils.dart';
import '../blocs/account_bloc/account_bloc.dart';
import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../models/AppAppointments.dart';
import '../models/order.dart';
import '../models/setting.dart';
import '../models/timeHelper.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'package:wakelock/wakelock.dart';

class VideoCallScreen extends StatefulWidget {
  AppAppointments appointment ;
  final GroceryUser user;
  final String appointmentId;
  final String consultName;

   VideoCallScreen({Key key, this.appointment, this.user, this.appointmentId, this.consultName}) : super(key: key);


  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false,endingCall=false,join=false,done=true,camera=false,firstTime=false;
  RtcEngine _engine;
  AccountBloc accountBloc;
  AppAppointments _appointment;
  Size size;
  int minutes =0,  seconds=0;
  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    getAppointment();
    initialize();
  }

  getAppointment()async {
     DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointmentId).get();
     setState(() {
       _appointment = AppAppointments.fromFirestore(documentSnapshot);
     });
}
  Future<void> initialize() async {
    try{
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    Wakelock.enable();
    await _engine.joinChannel(null, widget.appointmentId, null, 0);
    }catch(e){print("agoraError"+e.toString());}
  }

  Future<void> _initAgoraRtcEngine() async {
    await [Permission.microphone].request();
    await [Permission.camera].request();
    _engine = await RtcEngine.create(appID);
    await _engine.enableVideo();
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        print("onJoinChannel");
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        print("ddddd1111111leave");
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        print("ddddd1111111userJoined");
        setState(() {
          final info = 'userJoined: $uid';

          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          final info = 'userOffline: $uid , reason: $reason';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideoFrame: $uid';
          _infoStrings.add(info);
        });
      },
    ));
  }
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: _onToggleMute,
                child: Icon(
                  muted ?Icons.mic: Icons.mic_off ,
                  color: muted ? Colors.white : Colors.blueAccent,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: muted ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              endingCall?Center(child: CircularProgressIndicator()):RawMaterialButton(
                onPressed: () => _onCallEnd(),
                child: Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
              ),
              RawMaterialButton(
                onPressed: _onSwitchCamera,
                child: Icon(
                  Icons.switch_camera,
                  color: Colors.blueAccent,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(12.0),
              )
            ], ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return  Scaffold(
      appBar:AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        color:Colors.white,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
              ),
              Text(widget.user==null?widget.consultName:widget.appointment.user.name),
              _appointment==null?CircularProgressIndicator():(join&&_appointment!=null)?TweenAnimationBuilder<Duration>(
                  duration: Duration(minutes: _appointment.lessonTime),
                  tween: Tween(begin: Duration(minutes: _appointment.lessonTime), end: Duration.zero),
                  onEnd: () {
                    _onCallEnd();
                  },
                  builder: (BuildContext context, Duration value, Widget child) {
                    minutes = value.inMinutes;
                    seconds = value.inSeconds % 60;
                    if(minutes==5&&seconds==0)
                        firstTime=true;
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text('$minutes:$seconds',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: minutes<5?Colors.red:Colors.white,
                                fontSize: 15)));
                  }):Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text('0:0',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15))),
            ],
          )),
        backgroundColor: Colors.black,
        body:  Center(child:
              Stack(
                children: <Widget>[
                    _viewRows(),
                    Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                            child: Column(mainAxisAlignment: MainAxisAlignment.end,crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _toolbar(),
                                firstTime? Container(color: Colors.red,width: size.width,child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                                    Expanded(flex:2,
                                      child: Text( getTranslated(context, "fiveMinutes")+minutes.toString()+getTranslated(context, "minutes"),
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap:true,
                                        style: GoogleFonts.cairo(
                                          fontSize: 14.0,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: SizedBox(
                                        height: 25,
                                        child: FlatButton(
                                          onPressed: () {
                                            setState(() {
                                              firstTime=false;
                                            });
                                          },
                                          color: Colors.black.withOpacity(0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                          ),
                                          child: Text(
                                            getTranslated(context, "Ok"),
                                            style: GoogleFonts.cairo(
                                              color: AppColors.white,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],),
                                ),):SizedBox()
                              ],
                            ),
                          ),
                      ),
                ],
              ),
          ),
      );
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }
  Widget _viewRows() {
    final views = _getRenderViews();
    if(views.length>1)
      setState(() {
        join=true;
      });
    else
      setState(() {
        join=false;
      });

    return views.length==1?Container(
        child: Column(
          children: <Widget>[_videoView(views[0])],
        )):Container(
         child: Stack( 
          children: <Widget>[
            //_expandedVideoRow([views[0]]),
            Positioned.fill(child: views[1]),
            Positioned(top:0,left: 0,child: Container(height:size.width*.35,width:size.width*.35,child: views[0]))
          ],
        ));

  }



  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });

    _engine.muteLocalAudioStream(muted);
   _engine.setEnableSpeakerphone(muted);

  }
  void _onSwitchCamera() {
    setState(() {
      camera = !camera;
    });
    _engine.switchCamera();
  }
  void _onCallEnd() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    /*if(timer!=null)
      timer.cancel();*/
    Wakelock.disable();
   if(widget.user!=null&&widget.user.userType=="CONSULTANT")
      endCallDialog(MediaQuery.of(context).size);
    else {
     endUserCallDialog(MediaQuery.of(context).size);
   }
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
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
                          'allowCall':false,
                        }, SetOptions(merge: true));
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
                      onPressed: ()  {
                        setState(() {
                          endingCall=true;
                        });
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
                getTranslated(context, "lessonFinish"),
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
              Center(
                child: Container(
                  width: 50.0,
                  child: FlatButton(
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () async {
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
              ),
            ],
          );},
        ),
      ), barrierDismissible: false,
      context: context,
    );
  }
  remaningTimeDialog(Size size) {
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
                getTranslated(context, "fiveMinutes"),
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
              Center(
                child: Container(
                  width: 50.0,
                  child: FlatButton(
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () async {
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
          );},
        ),
      ), barrierDismissible: false,
      context: context,
    );
  }
  Future<void> callDone() async {
    try{
      //update appointment
      var  answeredCallNum=0,packageCallNum=0,remainingCall=0;
      if(done&&widget.appointment.type!="fake"&&widget.user!=null&&widget.user.userType=="CONSULTANT"&&widget.appointment!=null)
      {
          done=false;
        await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
          'appointmentStatus':(widget.appointment.consultType=="glorified"||widget.appointment.consultType=="vocal")? "closed":"open",
          'allowCall':false
        }, SetOptions(merge: true));

        if(widget.appointment.consultType!=null&&(widget.appointment.consultType=="perfect"||widget.appointment.consultType=="jeras"))
          await FirebaseFirestore.instance.collection(Paths.forEverAppointmentsPath).doc(
              Uuid().v4()).set({
            'appointmentId': widget.appointment.appointmentId,
            'appointmentStatus': 'closed',
            'timestamp':DateTime.now().toUtc().toString(),
            "consultType":widget.appointment.consultType,
            'orderId': widget.appointment.orderId,
            'callPrice': widget.appointment.callPrice,
            'consult': {
              'uid': widget.appointment.consult.uid,
              'name': widget.appointment.consult.name,
              'image': widget.appointment.consult.image,
              'phone': widget.appointment.consult.phone,
              'countryCode': widget.appointment.consult.countryCode,
              'countryISOCode': widget.appointment.consult.countryISOCode,
            },
            'user': {
              'uid': widget.appointment.user.uid,
              'name': widget.appointment.user.name,
              'image': widget.appointment.user.image,
              'phone': widget.appointment.user.phone,
              'countryCode': widget.appointment.user.countryCode,
              'countryISOCode': widget.appointment.user.countryISOCode,

            },
            'date': {
              'day': DateTime.now().toUtc().day,
              'month': DateTime.now().toUtc().month,
              'year': DateTime.now().toUtc().year,
            },
            'time': {
              'hour': DateTime.now().toUtc().hour,
              'minute': DateTime.now().toUtc().minute,
            },
          });
        //update order
        //final DocumentSnapshot orderSnapshot =
        await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(widget.appointment.orderId).get().then((value) async {
            packageCallNum= Orders.fromFirestore(value).packageCallNum;

          //======
          if(widget.appointment.consultType=="glorified"||widget.appointment.consultType=="vocal") {
            await FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .where( 'orderId', isEqualTo: widget.appointment.orderId,)
                .get().then((value) async {
              if(value.docs.length>0){
                  remainingCall=packageCallNum-value.docs.length;
                for (var doc in value.docs) {
                  if(doc['appointmentStatus']!=null&&doc['appointmentStatus']=='closed')
                      answeredCallNum++;
                }
              }
              else {
                    remainingCall=packageCallNum;
                    answeredCallNum=0;
                  }

              await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(widget.appointment.orderId).set({
                'answeredCallNum': answeredCallNum,
                'orderStatus':packageCallNum==answeredCallNum?"closed":'open',
                'remainingCallNum':remainingCall
              }, SetOptions(merge: true));
            }).catchError((err) {
              errorLog("callDone",err.toString());
            });
          }
          else{
            await FirebaseFirestore.instance
                .collection(Paths.forEverAppointmentsPath)
                .where( 'orderId', isEqualTo: widget.appointment.orderId,)
                .get().then((value) async {
                if(value.docs.length>0) {
                  remainingCall = packageCallNum - value.docs.length;
                  answeredCallNum = value.docs.length;
                }
                else{ remainingCall=packageCallNum;
                answeredCallNum=0;}

              await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(widget.appointment.orderId).set({
                'answeredCallNum': answeredCallNum,
                'orderStatus':packageCallNum==answeredCallNum?"closed":'completed',
                'remainingCallNum':remainingCall
              }, SetOptions(merge: true));
            }).catchError((err) {
              errorLog("callDone",err.toString());
            });
          }

          if(widget.appointment.consultType!=null&&packageCallNum==answeredCallNum&&(widget.appointment.consultType=="perfect"||widget.appointment.consultType=="jeras"))
            await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
              'appointmentStatus': "closed",
              'allowCall':false
            }, SetOptions(merge: true));
          if(widget.appointment.consultType!=null&&(widget.appointment.consultType=="perfect"||widget.appointment.consultType=="jeras"))
          {
            DateTime newDate=DateTime.parse(widget.appointment.utcTime);//.add(Duration( days: 1));
            for(int x=1;x<15; x++)
            {
              var _now2 = newDate.add(Duration(days: x));

              if(widget.user.workDays.contains(_now2.weekday.toString()))
              {
                await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
                  'utcTime': _now2.toString(),
                  'remainingCallNum':(packageCallNum-answeredCallNum),
                }, SetOptions(merge: true));
                break;
              }
              else
              {}
            }
          }
          //update consultbalance
          DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.settingPath).doc("pzBqiphy5o2kkzJgWUT7");
          final DocumentSnapshot taxDocumentSnapshot = await docRef.get();
          var taxes= Setting.fromFirestore(taxDocumentSnapshot).taxes;

          DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.user.uid).get();
          GroceryUser currentUser = GroceryUser.fromFirestore(documentSnapshot);
          dynamic taxesvalue=(widget.appointment.callPrice*taxes)/100;
          dynamic consultBalance=widget.appointment.callPrice-taxesvalue;
          dynamic payedBalance=consultBalance;
          if(currentUser.payedBalance!=null)
            payedBalance=payedBalance+currentUser.payedBalance;

          if(currentUser.balance!=null)
            consultBalance=consultBalance+currentUser.balance;
          //update consult order numbers
          int consultOrdersNumbers=1;
          if(widget.user.ordersNumbers!=null)
            consultOrdersNumbers=1+widget.user.ordersNumbers;

          if(widget.user.consultOpenAppointmentDates!=null&&packageCallNum==answeredCallNum)
           widget.user.consultOpenAppointmentDates.removeWhere((element) => element==(widget.appointment.time.hour.toString()+":"+widget.appointment.time.minute.toString()));
          await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.user.uid).set({
            'balance':consultBalance,
            'payedBalance':payedBalance,
            'ordersNumbers':consultOrdersNumbers,
            'consultOpenAppointmentDates':widget.user.consultOpenAppointmentDates
          }, SetOptions(merge: true));
          if(answeredCallNum==packageCallNum||answeredCallNum==packageCallNum/2)
          {
            sendReviewNotification(widget.appointment.consult.name,widget.appointment.consult.uid,widget.appointment.user.uid,widget.appointment.appointmentId);

          }
          accountBloc.add(GetAccountDetailsEvent(widget.user.uid));
        }).catchError((err) {
          errorLog("callDone",err.toString());
        });

      }
      setState(() {
        endingCall=false;
      });
      Navigator.pop(context);
      Navigator.pop(context);
    }catch(e)
    {
      print("eeeeee"+e.toString());
      errorLog("callDone",e.toString());
    }
  }
  Future<void> sendReviewNotification(String consultName,String consultUid,String userId,String appointmentId) async {
    try{
      print("sendReviewNotificationss");
      Map notifMap = Map();//sendReviewNotification
      notifMap.putIfAbsent('consultName', () => widget.appointment.consult.name);
      notifMap.putIfAbsent('consultUid', () => widget.appointment.consult.uid);
      notifMap.putIfAbsent('userId', () => widget.appointment.user.uid);
      notifMap.putIfAbsent('appointmentId', () => widget.appointment.appointmentId);
      var refundRes= await http.post( Uri.parse('https://us-central1-app-jeras.cloudfunctions.net/sendReviewNotification'),
        body: notifMap,
      );
      var refund = jsonDecode(refundRes.body);
      if (refund['message'] != 'Success') {
        print("sendnotification111  error");
        print(refund);
        print(refund['message']);
      }
      else
      { print("sendnotification1111 success");}
    }catch(e){
      print("sendnotification111  "+e.toString());
    }


  }
  //==========
  errorLog(String function,String error)async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance.collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': error,
      'phone': widget.user == null ? " " : widget.user.phoneNumber,
      'screen': "videoScreen",
      'function': function,
    });
  }
}