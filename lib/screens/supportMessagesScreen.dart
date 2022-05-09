// @dart=2.9
import 'dart:io';
import 'package:auto_direction/auto_direction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/SupportList.dart';
import 'package:grocery_store/models/SupportMessage.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/widget/AppointChatMessageItem.dart';
import 'package:grocery_store/widget/messageItem.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
var image;
File selectedProfileImage;
typedef _Fn = void Function();

Future<String> _getTempPath(String path) async {
  var tempDir = await getTemporaryDirectory();
  var tempPath = tempDir.path;
  return tempPath + '/' + path;
}
class SupportMessageScreen extends StatefulWidget {
  final SupportList item ;
  final GroceryUser user;
  final String theme;

  const SupportMessageScreen({this.item, this.user, this.theme});

  @override
  _SupportMessageScreenState createState() => _SupportMessageScreenState();
}

class _SupportMessageScreenState extends State<SupportMessageScreen> {
  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();

  bool loading;
  bool isShowSticker,answered=false;
  String imageUrl;
  var stCollection = 'messages';

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
  String mobileNumber='..';
  bool isRTL = false;
  String text = "";
  @override
  void initState() {
    _mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
      getUserMobileNumber();

    });
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
    loading=false;
    focusNode.addListener(onFocusChange);
      userReadHisMessage(widget.user.userType);
  }
  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }
  getUserMobileNumber() async {
    DocumentReference userRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.item.userUid);
    final DocumentSnapshot userSnapshot = await userRef.get();
    var phone= GroceryUser.fromFirestore(userSnapshot).phoneNumber;
    setState(() {
      mobileNumber=phone;
    });
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: endSupport,
      child: Scaffold(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.white.withOpacity(0.5),
                                onTap: () {
                                  endSupport();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  width: 38.0,
                                  height: 35.0,
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: widget.theme=="light"?Colors.white:Colors.black,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Column(
                            children: [
                              Text(
                                widget.user.userType=="SUPPORT"?widget.item.userName==null?" ":widget.item.userName:getTranslated(context, "tecSupport"),
                                style: GoogleFonts.cairo(
                                  color: widget.theme=="light"?Colors.white:Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              widget.user.userType=="SUPPORT"?Text(
                                mobileNumber,
                                style: GoogleFonts.cairo(
                                  color: widget.theme=="light"?Colors.white:Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ):SizedBox(),
                            ],
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            widget.user.userType=="SUPPORT"? Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: answered,
                  onChanged: (value) {
                    setState(() {
                      answered = !answered;
                      callAnswered();
                    });
                  },
                ),
                Text(
                  getTranslated(context, "answered"),
                  style: GoogleFonts.cairo(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color:widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
                  ),
                ),
              ],
            ):
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
                  ),child:Image.asset('assets/applicationIcons/Group171.png',
                  width: 25,
                  height: 25,
                ),
                ),
                SizedBox(width: 5,),
                Container(
                  padding:const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 0.0),
                      blurRadius: 15.0,
                      spreadRadius: 2.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                  child: Text(
                    getTranslated(context, "helpText"),
                    style: GoogleFonts.cairo(
                      color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
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
                    return  MessageItem(
                        message: SupportMessage.fromFirestore(documentSnapshot[index]),
                        user:widget.user
                    );

                  },
                  query: FirebaseFirestore.instance.collection('SupportMessage')
                      .where('supportId', isEqualTo: widget.item.supportListId)
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
            buildInput(size),
          ],
        ),
      ),
    );
  }


  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      padding: EdgeInsets.all(5.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    return loginBtn;
  }

  //=======
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
                onPressed: () =>cropImage(context),// getImage(0),
                color:widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
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
            child: _mRecorder.isRecording ? Icon(Icons.pause_outlined,color:Colors.red):Icon(Icons.mic,color:widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,),
          ),

          // Edit text
          Flexible(
            child: Container(
              child: AutoDirection(
                text: text,
                child: TextField(
                  enableInteractiveSelection: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(color:Theme.of(context).primaryColor, fontSize: 15.0),
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
                color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
                ),
                child: Center(
                  child: new IconButton(
                    icon: new Icon(Icons.send,color:Colors.white,size: 15,),
                    onPressed: () => onSendMessage(textEditingController.text, "text",size),
                    color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
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
  Future<void> onSendMessage(String content, String type,Size size) async {
    if ((content.trim() != ''&&type=="text") ||type!="text"){
      textEditingController.clear();
      if(widget.user.userType=="SUPPORT")
      {
        await FirebaseFirestore.instance.collection("SupportList").doc(widget.item.supportListId).set({
          'userMessageNum': FieldValue.increment(1),
          'messageTime': FieldValue.serverTimestamp(),
          'lastMessage': type=="text"?content:type=="image"?"imageFile":"voiceFile",
        }, SetOptions(merge: true));

      }
      else
        await FirebaseFirestore.instance.collection("SupportList").doc(widget.item.supportListId).set({
          'supportMessageNum': FieldValue.increment(1),
          'supportListStatus': false,
          'userName':widget.user.name,
          'messageTime': FieldValue.serverTimestamp(),
          'lastMessage': type=="text"?content:type=="image"?"imageFile":"voiceFile",
        }, SetOptions(merge: true));
      String messageId=Uuid().v4();
      await FirebaseFirestore.instance.collection("SupportMessage").doc(messageId).set({
        'type': type,
        'message': content,
        'messageTime': FieldValue.serverTimestamp(),
        'messageTimeUtc':DateTime.now().toUtc().toString(),
        'owner': widget.user.userType,
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'supportId': widget.item.supportListId,

      });


      listScrollController.animateTo(0.0,duration: Duration(milliseconds: 300), curve: Curves.easeOut);
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
              builder: (context) => SupportMessageScreen(
                  item: widget.item,
                  user:widget.user,
                theme: widget.theme,
              ),
            ),
          );
        }

    }
  }
  Future<void> callAnswered() async {
    showUpdatingDialog();
    await FirebaseFirestore.instance.collection("SupportList").doc(widget.item.supportListId).set({
      'supportListStatus':false,
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance.collection("SupportList").doc(widget.item.supportListId).set({
      'supportListStatus':true,
      'openingStatus':false,
      'supportMessageNum': 0,
    }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.user.uid).set({
        'answeredSupportNum': int.parse(widget.user.answeredSupportNum.toString())+1,
      }, SetOptions(merge: true));
      var date=DateTime.now();
    await FirebaseFirestore.instance.collection(Paths.supportAnalysisPath).doc(Uuid().v4()).set({
      'time': DateTime(date.year, date.month, date.day ).millisecondsSinceEpoch,
      'techSupportUser':widget.user.uid,
    }, SetOptions(merge: true));
    Navigator.pop(context);
  }
  Future<void> userReadHisMessage( String type  ) async {
    try{
      if(type=="SUPPORT")
      await FirebaseFirestore.instance.collection("SupportList").doc(widget.item.supportListId).set({
        //'supportMessageNum': 0,
        'openingStatus': true,
      }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance.collection("SupportList").doc(widget.item.supportListId).set({
          'userMessageNum': 0,
        }, SetOptions(merge: true));

    }catch(e){
      print("cccccc"+e.toString());
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
          toolbarColor: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
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
  ////===============
  @override
  void dispose() {
    _mPlayer.closeAudioSession();
    _mPlayer = null;

    _mRecorder.closeAudioSession();
    _mRecorder = null;
    endSupport();
    super.dispose();
  }
  Future<bool> endSupport() async {
    try{
      if(widget.user.userType=="SUPPORT")
        await FirebaseFirestore.instance.collection("SupportList").doc(widget.item.supportListId).set({
          'openingStatus': false,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance.collection("SupportList").doc(widget.item.supportListId).set({
          'userMessageNum': 0,
        }, SetOptions(merge: true));
      Navigator.of(context).pop(true);

    }catch(e){
      print("cccccc"+e.toString());
    }

  }
  Future<void> openTheRecorder() async {
    try{print("testssssss111");
    _mPathAAC = await _getTempPath('flutter_sound_example.aac');
    _mPathMP3 = await _getTempPath('flutter_sound_example.mp3');
    print("testssssss111dddd");
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print("testssssss111dddd55555555555");
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    print("testssssss111ssss");
    await _mRecorder.openAudioSession();
    print("testssssss111qqq");
   setState(() {
     _mRecorderIsInited = true;
   });
    }catch(e){print("testssssssss222"+e.toString());}
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
    try{
    print("testssssss");
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      print(!_mRecorderIsInited);
      print(!_mPlayer.isStopped);
      return null;
    }
    print(_mRecorder.isStopped);
    return _mRecorder.isStopped ? record : stopRecorder;
    }catch(e){print("testsssssserror"+e.toString());}
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
