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
import 'package:grocery_store/models/DevelopTechSupport.dart';
import 'package:grocery_store/models/SupportMessage.dart';
import 'package:grocery_store/models/developMessage.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/setting.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/AppointChatMessageItem.dart';
import 'package:grocery_store/widget/developItem.dart';
import 'package:grocery_store/widget/messageItem.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
var image;
File selectedProfileImage;
typedef _Fn = void Function();

Future<String> _getTempPath(String path) async {
  var tempDir = await getTemporaryDirectory();
  var tempPath = tempDir.path;
  return tempPath + '/' + path;
}
class DevelopMessageScreen extends StatefulWidget {
  final DevelopTechSupport develop ;
  final GroceryUser user;

  const DevelopMessageScreen({this.develop, this.user});

  @override
  _DevelopMessageScreenState createState() => _DevelopMessageScreenState();
}

class _DevelopMessageScreenState extends State<DevelopMessageScreen> {
  bool loading;
  bool isShowSticker,answered=false,loadStatus=false;
  String imageUrl;
  var stCollection = 'messages',theme;
  String text = "";
  AccountBloc accountBloc;
  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
String dropdownTypeValue;
  final FocusNode focusNode = new FocusNode();
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false,uploadingRecord=false;
  String _mPathAAC = '';
  String _mPathMP3 = '';
  List<KeyValueModel> _typeArray = [
    KeyValueModel(key: "new", value: "New"),
    KeyValueModel(key: "open", value: "Open"),
    KeyValueModel(key: "done", value: "Done"),
    KeyValueModel(key: "closed", value: "Closed"),
  ];
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
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: Text(
                        widget.develop.userName,
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

                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
              Text(
                getTranslated(context, "selectStatus"),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 1,
                style: GoogleFonts.cairo(
                  color:Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                  height: 40.0,width: size.width*.5,
                  decoration: BoxDecoration(
                      color: theme=="light"?Colors.white:Colors.transparent,
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius:
                      BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: DropdownButton<String>(
                      hint: Text(
                        getTranslated(context, "selectStatus"),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          //color: Colors.black,
                          fontSize: 15.0,
                          letterSpacing: 0.5,
                        ),
                      ),
                      underline: Container(),
                      isExpanded: true,
                      value: dropdownTypeValue,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: Colors.black),
                      iconSize: 24,
                      elevation: 16,
                      style: GoogleFonts.cairo(
                        color: Color(0xFF3b98e1),
                        fontSize: 13.0,
                        letterSpacing: 0.5,
                      ),
                      items: _typeArray
                          .map((data) => DropdownMenuItem<String>(
                          child: Text(
                            data.value,
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontSize: 15.0,
                              letterSpacing: 0.5,
                            ),
                          ),
                          value: data.key.toString() //data.key,
                      ))
                          .toList(),
                      onChanged: (String value) {
                        print(value);
                        setState(() {
                          dropdownTypeValue = value;

                        });
                      },
                    ),
                  )),
            ],),
          ),
         loadStatus
              ? Center(child: CircularProgressIndicator())
              : Container(
                  height: 45.0,
                  width: size.width*.5,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 0.0),
                  child: FlatButton(
                    onPressed: () {
                      //add notificationMap
                      changeStatus(dropdownTypeValue);
                    },
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      getTranslated(
                          context, "save"),
                      style: GoogleFonts.poppins(
                        color: theme=="light"?Colors.white:Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
          Expanded(
            child: PaginateFirestore(
              scrollController: listScrollController,
              reverse: true,
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  DevelopItem(
                    message: DevelopMessage.fromFirestore(documentSnapshot[index]),
                    user:widget.user
                );

              },
              query: FirebaseFirestore.instance.collection(Paths.dvelopChat)
                  .where('developTechSupportId', isEqualTo: widget.develop.developTechSupportId)
                  .orderBy('messageTime', descending: true),
              isLive: true,
            ),
          ),
          buildInput(size),
        ],
      ),
    );
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
              child:AutoDirection(
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
  Future<void> changeStatus(String status) async {
    //update appointment
    await FirebaseFirestore.instance.collection(Paths.developTechSupportPath).doc(widget.develop.developTechSupportId).set({
      'status': status,
    }, SetOptions(merge: true));

    Navigator.pop(context);
  }

  Future<void> onSendMessage(String content, String type,Size size) async {
    if (content.trim() != '') {
      textEditingController.clear();
      String messageId=Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.dvelopChat).doc(messageId).set({
        'type': type,
        'owner': widget.user.userType,
        'message': content,
        'messageTime': FieldValue.serverTimestamp(),
        'messageTimeUtc':DateTime.now().toUtc().toString(),
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'developTechSupportId': widget.develop.developTechSupportId,

      });
      String data=getTranslated(context, "attatchment");
      if(type=="text")
        data=content;


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
            builder: (context) => DevelopMessageScreen(
              develop: widget.develop,
              user:widget.user,
            ),
          ),
        );
      }

    } else {
      // Fluttertoast.showToast(msg: 'Nothing to send');
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
  ////===============
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
