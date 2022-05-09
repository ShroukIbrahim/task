// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'package:auto_direction/auto_direction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/SupportMessage.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/setting.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/twCallScreen.dart';
import 'package:grocery_store/widget/AppointChatMessageItem.dart';
import 'package:grocery_store/widget/messageItem.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:twilio_voice/twilio_voice.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'AgoraScreen.dart';
var image;
File selectedProfileImage;
typedef _Fn = void Function();

Future<String> _getTempPath(String path) async {
  var tempDir = await getTemporaryDirectory();
  var tempPath = tempDir.path;
  return tempPath + '/' + path;
}
class AppointmentChatScreen extends StatefulWidget {
  final AppAppointments appointment ;
  final GroceryUser user;

  const AppointmentChatScreen({this.appointment, this.user});

  @override
  _AppointmentChatScreenState createState() => _AppointmentChatScreenState();
}

class _AppointmentChatScreenState extends State<AppointmentChatScreen> {
  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading=false,checkAgora=false;
  bool isShowSticker,answered=false, closing=false,done=true;
  String imageUrl;
  var stCollection = 'messages',theme;
  String text = "";
  AccountBloc accountBloc;
  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  final FocusNode focusNode = new FocusNode();
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false,uploadingRecord=false;
  String _mPathAAC = '';
  String _mPathMP3 = '';
  @override
  void initState() {
    _mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
    loading=false;
    focusNode.addListener(onFocusChange);
    accountBloc = BlocProvider.of<AccountBloc>(context);
    userReadHisMessage(widget.user.userType);
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
  Future<void> userReadHisMessage( String type  ) async {
    try{
      if(type=="CONSULTANT")
        await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
          'userChat': 0,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
          'consultChat': 0,
        }, SetOptions(merge: true));

    }catch(e){
      print("cccccc"+e.toString());
    }

  }
  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key:_scaffoldKey,
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
                    Expanded(
                      child: Text(
                        widget.user.userType=="USER"?widget.appointment.consult.name:widget.appointment.user.name,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 1,
                        style: GoogleFonts.cairo(
                          color: theme=="light"?Colors.white:Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    (widget.user.userType=="CONSULTANT"&&widget.user.voice&&widget.appointment.appointmentStatus=="open")?ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: ()  {
                          twilioCall();

                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: 38.0,
                            height: 35.0,
                            child: Icon(
                              Icons.wifi_calling,
                              color: theme=="light"?Colors.white:Colors.black,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ):SizedBox(),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 10,),
          Expanded(
            child: RefreshIndicator(
              child: PaginateFirestore(
                scrollController: listScrollController,
                reverse: true,
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  AppointChatMessageItem(
                      message: SupportMessage.fromFirestore(documentSnapshot[index]),
                      user:widget.user
                  );

                },
                query: FirebaseFirestore.instance.collection(Paths.appointmentChat)
                    .where('appointmentId', isEqualTo: widget.appointment.appointmentId)
                    .orderBy('messageTime', descending: true),
                listeners: [
                  refreshChangeListener,
                ],
                isLive: true,
              ),
              onRefresh: () async {
                refreshChangeListener.refreshed = true;
              },
            ),
          ),
          widget.appointment.appointmentStatus!="closed"?buildInput(size):SizedBox(),
        ],
      ),
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
  twilioCall() async {
  if(!await (TwilioVoice.instance.hasMicAccess())) {
           print("request mic access");
           TwilioVoice.instance.requestMicAccess();
           return;
         }
         TwilioVoice.instance.call.place(to:widget.appointment.user.uid,from: widget.user.uid);
         Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
             fullscreenDialog: true, builder: (context) => VoiceCallScreen(loggedUser:widget.user,appointment:widget.appointment,from:'history')));
  }
  Widget buildInput(Size size) {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: () =>cropImage(context),
                color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
              ),
            ),
            color: Colors.white,
          ),
          uploadingRecord?Center(child: CircularProgressIndicator()):ElevatedButton(
            style: ButtonStyle(
              elevation:MaterialStateProperty.all<double>(0),
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
            ),
            onPressed: getRecorderFn(),
            child: _mRecorder.isRecording ? Icon(Icons.pause_outlined,color:Colors.red):Icon(Icons.mic,color: theme=="light"?Theme.of(context).primaryColor:Colors.black,),
          ),

          // Edit text
          Flexible(
            child: Container(
              child: AutoDirection(
                text: text,
                child: TextField( enableInteractiveSelection: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(color: theme=="light"?Theme.of(context).primaryColor:Colors.black, fontSize: 15.0),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: getTranslated(context, "typeMessage"),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  focusNode: focusNode,
                  onChanged: (str){
                    setState(() {
                      text = str;
                    });
                  },
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: loading?Center(child: CircularProgressIndicator()): Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                ),
                child: Center(
                  child: new IconButton(
                    icon: new Icon(Icons.send,color:Colors.white,size: 15,),
                    onPressed: () => onSendMessage(textEditingController.text, "text",size),
                    color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                  ),
                ),
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
          new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }
  Future<void> callDone() async {
    try{
      //update appointment
      setState(() {
        closing=true;
      });
      //update appointment
      var  answeredCallNum=0,packageCallNum=0,remainingCall=0;
      if(done&&widget.appointment!=null&&widget.appointment.appointmentStatus!="closed"&&widget.appointment.type!="fake"&&widget.user!=null&&widget.user.userType=="CONSULTANT")
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
                  'remainingCallNum':remainingCall,
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
        closing=false;
      });
      Navigator.pop(context);
    }catch(e)
    {
      print("eeeeee"+e.toString());
      errorLog("callDone",e.toString());
    }
  }
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
      'screen': "AppointmentChatScreen",
      'function': function,
    });
  }
  Future<void> sendReviewNotification(String consultName,String consultUid,String userId,String appointmentId) async {
    try{
      Map notifMap = Map();//sendReviewNotification
      notifMap.putIfAbsent('consultName', () => consultName);
      notifMap.putIfAbsent('consultUid', () => consultUid);
      notifMap.putIfAbsent('userId', () => userId);
      notifMap.putIfAbsent('appointmentId', () => appointmentId);
      var refundRes= await http.post( Uri.parse('https://us-central1-app-jeras.cloudfunctions.net/sendReviewNotification'),
        body: notifMap,
      );
      var refund = jsonDecode(refundRes.body);
      if (refund['message'] != 'Success') {
        print("sendnotification111  error");
      }
      else
      { print("sendnotification1111 success");}
    }catch(e){
      print("sendnotification111  "+e.toString());
    }


  }
  Future<void> onSendMessage(String content, String type,Size size) async {
    if (content.trim() != '') {
      textEditingController.clear();
      String messageId=Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.appointmentChat).doc(messageId).set({
        'type': type,
        'owner': widget.user.userType,
        'message': content,
        'messageTime': FieldValue.serverTimestamp(),
        'messageTimeUtc':DateTime.now().toUtc().toString(),
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'appointmentId': widget.appointment.appointmentId,

      });
      String data=getTranslated(context, "attatchment");
      if(type=="text")
        data=content;
      if(widget.user.userType=="CONSULTANT")
        {
          await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
            'consultChat': FieldValue.increment(1),
          }, SetOptions(merge: true));
          sendNotification(widget.appointment.user.uid, data);
        }
      else
      {
        await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
        'userChat': FieldValue.increment(1),
        }, SetOptions(merge: true));
        sendNotification(widget.appointment.consult.uid, data);
      }

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() {
        loading = false;
      });
      if(type=="voice")
        {
          setState(() {
            uploadingRecord=false;
          });
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentChatScreen(
                  appointment: widget.appointment,
                  user:widget.user
              ),
            ),
          );
        }

    } else {
      // Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }
  Future<void> sendNotification(String userId,String text) async {
    try{
      Map notifMap = Map();
      notifMap.putIfAbsent('title', () => "Chat");
      notifMap.putIfAbsent('body', () => text);
      notifMap.putIfAbsent('userId', () => userId);
      notifMap.putIfAbsent('appointmentId', () => widget.appointment.appointmentId);
      var refundRes= await http.post( Uri.parse('https://us-central1-app-jeras.cloudfunctions.net/sendChatNotification'),
        body: notifMap,
      );
     /* var refund = jsonDecode(refundRes.body);
      if (refund['message'] != 'Success') {
        print("sendnotification111  error");
      }
      else
      { print("sendnotification1111 success");}*/
    }catch(e){
      print("sendnotification111  "+e.toString());
    }


  }
  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: getTranslated(context, "loading"),
        );
      },
    );
  }
  Future cropImage(context) async {
    setState(() {
      loading = true;
    });
    image = await ImagePicker().getImage(source: ImageSource.gallery);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: theme=="light"?Theme.of(context).primaryColor:Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          showCropGrid: false,
          lockAspectRatio: true,
          statusBarColor: Theme.of(context).primaryColor,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,
        ));

    if (croppedFile != null) {
      print('File size: ' + croppedFile.lengthSync().toString());
      uploadImage(croppedFile);
      setState(() {
        selectedProfileImage = croppedFile;
      });
      // signupBloc.add(PickedProfilePictureEvent(file: croppedFile));
    } else {
      //not croppped

    }
  }
  Future uploadImage(File image) async {

    Size size = MediaQuery
        .of(context)
        .size;

    var uuid = Uuid().v4();
    Reference storageReference =
    FirebaseStorage.instance.ref().child('profileImages/$uuid');
    await storageReference.putFile(image);

    var url = await storageReference.getDownloadURL();
    onSendMessage(url, "image",size);
  }

  @override
  void dispose() {
    _mPlayer.closeAudioSession();
    _mPlayer = null;

    _mRecorder.closeAudioSession();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    _mPathAAC = await _getTempPath('flutter_sound_example.aac');
    _mPathMP3 = await _getTempPath('flutter_sound_example.mp3');

    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording, convertFile(), and playback -------

  void record() {
    _mRecorder
        .startRecorder(
      toFile: _mPathAAC,
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    if(_mRecorder!=null)
    await _mRecorder.stopRecorder().then((value) {
      setState(() {
        uploadingRecord=true;
        _mplaybackReady = true;
      });
      sendVoice();
    });
  }

  Future<void> play() async {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder.isStopped &&
        _mPlayer.isStopped);

    await FlutterSoundHelper()
        .convertFile(_mPathAAC, Codec.aacADTS, _mPathMP3, Codec.mp3);
    await _mPlayer.startPlayer(
        codec: Codec.mp3,
        fromURI: _mPathMP3,
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  void stopPlayer() {
   if(_mPlayer!=null)
    _mPlayer.stopPlayer().then((value) {

      setState(() {});
    });
  }

// ----------------------------- UI --------------------------------------------

  _Fn getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return null;
    }
    return _mRecorder.isStopped ? record : stopRecorder;
  }

  _Fn getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      return null;
    }
    return _mPlayer.isStopped ? play : stopPlayer;
  }
  Future<void> sendVoice() async {
    await FlutterSoundHelper().convertFile(_mPathAAC, Codec.aacADTS, _mPathMP3, Codec.mp3);
    File recordFile=new File(_mPathMP3);
    uploadRecord(recordFile);
    /*  await _mPlayer.startPlayer(codec: Codec.mp3, fromURI: _mPathMP3,  whenFinished: () {
        setState(() {});
        });*/
  }
  Future uploadRecord(File voice) async {

    Size size = MediaQuery
        .of(context)
        .size;

    var uuid = Uuid().v4();
    Reference storageReference =
    FirebaseStorage.instance.ref().child('profileImages/$uuid');
    await storageReference.putFile(voice);

    var url = await storageReference.getDownloadURL();
    print("recording file222");
    print(url);
    onSendMessage(url,"voice",size);
  }
}
