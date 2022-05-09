// @dart=2.9
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../config/paths.dart';
class AccountScreen extends StatefulWidget {
  final GroceryUser user;
  final bool firstLogged;

  const AccountScreen({Key key, this.user, this.firstLogged}) : super(key: key);
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  AccountBloc accountBloc;
  bool profileCompleted=false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TimeOfDay selectedTime = TimeOfDay.now();
  String name,userName,price,bio,workDays="",lang="",type="",from,to,theme,location;
  TextEditingController daysController ,langController,typeController,fromController,toController;
  bool monday=false,tuesday=false,wednesday=false,thursday=false,friday=false,saturday=false,sunday=false,first=true ;
  bool arabic=false,english=false,allowVoice=false,allowChat=false;
  ScrollController scrollController;
  List<WorkTimes> workTimes;
  List<dynamic>daysValue=[];
  WorkTimes _workTime=new WorkTimes();
  var image;
  File selectedProfileImage;

  @override
  void initState() {
    super.initState();
    print("account screen");
    print(widget.user.name);
    profileCompleted=widget.user.profileCompleted;
    userName=widget.user.name;
    price=widget.user.price;
    bio=widget.user.bio;
    location=widget.user.location;
    daysController= TextEditingController();
    typeController= TextEditingController();
    fromController= TextEditingController();
    toController= TextEditingController();
    if(widget.user.languages.length>0){
      widget.user.languages.forEach((element) {
        if(element=="English")
          english=true;
        if(element=="العربية")
          arabic=true;
        lang=lang+" "+element;
      }
      );

    }

    langController= TextEditingController(text:lang);
    if(widget.user.workTimes.length>0) {

      _workTime = widget.user.workTimes[0];
      if(_workTime.from!=null){
        from=_workTime.from;
        int fromvalue=int.parse(_workTime.from);
        if(fromvalue==12)
          fromController.text="12 PM";
        else if(fromvalue==0)
          fromController.text="12 AM";
        else if(fromvalue>12)
          fromController.text=(fromvalue-12).toString()+" PM";
        else
          fromController.text=fromvalue.toString()+" AM";
      }
      if(_workTime.to!=null) {
        to=_workTime.to;
        int toValue=int.parse(_workTime.to);
        if(toValue==12)
          toController.text="12 PM";
        else if(toValue==0)
          toController.text="12 AM";
        else if(toValue>12)
          toController.text=(toValue-12).toString()+" PM";
        else
          toController.text=toValue.toString()+" AM";
      }
    }

    if(widget.user.voice){
      type=type+"Voice";
      allowVoice=true;
      typeController= TextEditingController(text:type);
    }
    if(widget.user.chat) {
      type=type+"  Chat";
      allowChat=true;
      typeController= TextEditingController(text:type);
    }

    accountBloc = BlocProvider.of<AccountBloc>(context);

    accountBloc.listen((state) {
      print(state);
      if (state is GetAccountDetailsCompletedState) {
        if(mounted)
        {
          Navigator.pop(context);
          /*  if(profileCompleted&&widget.firstLogged==false)
            Navigator.pop(context);
          else if(profileCompleted==false&&widget.firstLogged) {
            Navigator.popAndPushNamed(context, '/home');

          }*/
        }

      }
      if (state is UpdateAccountDetailsInProgressState) {
        //show dialog
        if(mounted)
          showUpdatingDialog();
      }
      if (state is UpdateAccountDetailsFailedState) {
        //show error
        showSnack(getTranslated(context, "error"), context,false);
      }
      if (state is UpdateAccountDetailsCompletedState) {
        if(mounted){
          accountBloc.add(GetAccountDetailsEvent(widget.user.uid));
          selectedProfileImage=null;
          //Navigator.pop(context);
          // accountBloc.add(GetAccountDetailsEvent(widget.user.uid));
        }

      }
    });
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
  void showSnack(String text, BuildContext context,bool status ) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(10),
      backgroundColor: status?Theme.of(context).primaryColor:Colors.red.shade500,
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
        style: GoogleFonts.cairo(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
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
  void showFailedSnakbar(String s) {
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
      backgroundColor: Colors.red,
      action: SnackBarAction(
          label: 'OK', textColor: Colors.white, onPressed: () {}),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }
  Future cropImage(context) async {
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
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          showCropGrid: false,
          lockAspectRatio: true,
          statusBarColor: theme=="light"?Theme.of(context).primaryColor:Colors.black,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,
        ));

    if (croppedFile != null) {
      print('File size: ' + croppedFile.lengthSync().toString());
      setState(() {
        selectedProfileImage = croppedFile;
      });
      // signupBloc.add(PickedProfilePictureEvent(file: croppedFile));
    } else {
      //not croppped

    }
  }
  @override
  Widget build(BuildContext context) {
    if(first&&widget.user.workDays.length>0) {
      if(widget.user.workDays.contains("1"))
      {
        workDays=workDays+getTranslated(context,"monday")+",";
        monday=true;
      }
      if(widget.user.workDays.contains("2"))
      {
        workDays=workDays+getTranslated(context,"tuesday")+",";
        tuesday=true;
      }
      if(widget.user.workDays.contains("3"))
      {
        workDays=workDays+getTranslated(context,"wednesday")+",";
        wednesday=true;
      }
      if(widget.user.workDays.contains("4"))
      {
        workDays=workDays+getTranslated(context,"thursday")+",";
        thursday=true;
      }
      if(widget.user.workDays.contains("5"))
      {
        workDays=workDays+getTranslated(context,"friday")+",";
        friday=true;
      }
      if(widget.user.workDays.contains("6"))
      {
        workDays=workDays+getTranslated(context,"saturday")+",";
        saturday=true;
      }
      if(widget.user.workDays.contains("7"))
      {
        workDays=workDays+getTranslated(context,"sunday")+",";
        sunday=true;
      }
      setState(() {
        daysController.text=workDays;
        first=false;
      });
    }
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body:  SingleChildScrollView(controller: scrollController,
        child: Column(

          children: <Widget>[
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    splashColor:
                    Colors.white.withOpacity(0.5),
                    onTap: () {
                      if(profileCompleted&&widget.firstLogged==false)
                        Navigator.popAndPushNamed(context, '/home');
                      else if(profileCompleted==false&&widget.firstLogged) {
                        Navigator.popAndPushNamed(context, '/home');

                      }
                    },
                    child: Image.asset(theme!="light"?
                    'assets/applicationIcons/whiteLogo.png':'assets/applicationIcons/whiteLogo.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Image.asset(theme=="light"?
                    'assets/applicationIcons/Iconly-Two-tone-Category.png' : 'assets/applicationIcons/Iconly-Curved-Category.png',
                      width: 30,
                      height: 30,
                    ),
                  ),

                ],
              ),
            ),
            Center(
              child: InkWell(
                splashColor: Colors.white.withOpacity(0.5),
                onTap: () {
                  cropImage(context);
                },
                child: Container(height: 100,width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35.0),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 0.0),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                  child: widget.user.photoUrl==null &&selectedProfileImage == null
                      ?  Image.asset('assets/applicationIcons/whiteLogo.png', fit:BoxFit.fill,height: 100,width: 100)
                      : selectedProfileImage != null
                      ? ClipRRect(borderRadius:BorderRadius.circular(35.0),child: Image.file(selectedProfileImage,fit:BoxFit.fill,height: 100,width: 100))
                      : ClipRRect(borderRadius:
                  BorderRadius.circular(35.0),
                    child: FadeInImage.assetNetwork(
                      placeholder:'assets/icons/icon_person.png',
                      placeholderScale: 0.5,
                      imageErrorBuilder: (context, error, stackTrace) =>
                          Icon( Icons.person,color:Colors.black, size: 50.0,),
                      image: widget.user.photoUrl,
                      fit: BoxFit.cover,
                      fadeInDuration:
                      Duration(milliseconds: 250),
                      fadeInCurve: Curves.easeInOut,
                      fadeOutDuration:
                      Duration(milliseconds: 150),
                      fadeOutCurve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10,),
            Center(
              child: Text(
                getTranslated(context, "welcomeBack"),
                style: GoogleFonts.cairo(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                ),),
            ),
            (widget.user.name!=null&&widget.user.name!="")?Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20),
                child: Text(
                  widget.user.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow:TextOverflow.clip ,
                  style: GoogleFonts.cairo(
                    color: Theme.of(context).primaryColor,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),),
              ),
            ):SizedBox(),
            SizedBox(height: 20,),
            Container(
              height:size.height*2,
              width: size.width,
              padding:const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(40.0),
                    topRight: const Radius.circular(40.0),
                  )
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: ListView(physics: NeverScrollableScrollPhysics(),controller: scrollController,
                  children:  [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getTranslated(context, "name"),
                          style: GoogleFonts.cairo(
                            color: theme=="light"?Colors.white:Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),),
                        Text(
                          "*", style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),),
                      ],
                    ),
                    SizedBox(height: 2,),
                    Container(height: 45,width: size.width,
                      padding: const EdgeInsets.only(left: 5,right: 5),
                      decoration: BoxDecoration(
                        color:theme=="light"?Colors.white:Colors.grey,
                        borderRadius: BorderRadius.circular(35.0),

                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              height: 35,width:35,
                              decoration: new BoxDecoration(
                                color: Theme.of(context).primaryColor,

                                shape: BoxShape.circle,
                              ),child: Icon( Icons.edit,size:20,
                            color: Colors.white,)),
                          SizedBox(width: 2,),
                          Expanded(flex:2,
                            child: Container(
                              child:  TextFormField(
                                enableInteractiveSelection:true,
                                style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                cursorColor: Colors.black,
                                initialValue: widget.user.name,
                                keyboardType: TextInputType.name,
                                onChanged: (value) {
                                  setState(() {
                                    userName = value;
                                  });
                                },
                                decoration: new InputDecoration(
                                  hintStyle: GoogleFonts.cairo(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  hintText: getTranslated(context,'name'),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10,),

                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getTranslated(context, "bio"),
                          style: GoogleFonts.cairo(
                            color: theme=="light"?Colors.white:Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),),
                        Text(
                          "*", style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),),
                      ],
                    ),
                    SizedBox(height: 2,),
                    Container(height: 200,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: theme=="light"?Colors.white:Colors.grey,
                        borderRadius: BorderRadius.circular(35.0),

                      ),
                      child: Center(
                        child:Container(width: size.width*.7,
                          child: TextFormField(
                            enableInteractiveSelection: true,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),

                            cursorColor: Colors.black,
                            initialValue: widget.user.bio,
                            onChanged: (value) {
                              setState(() {
                                bio=value;
                              });
                            },
                            decoration: new InputDecoration(
                              hintStyle: GoogleFonts.cairo(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              hintText: getTranslated(context,'bio'),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,

                              //  hintText: sLabel
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getTranslated(context, "price"),
                          style: GoogleFonts.cairo(
                            color: theme=="light"?Colors.white:Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),),
                        Text(
                          "*", style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),),
                      ],
                    ),
                    SizedBox(height: 2,),
                    Container(height: 45,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: theme=="light"?Colors.white:Colors.grey,
                        borderRadius: BorderRadius.circular(35.0),

                      ),
                      child: Center(
                        child: Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                height: 35,width:35,
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).primaryColor,

                                  //color: Colors.white,
                                  shape: BoxShape.circle,
                                ),child: Icon( Icons.attach_money,size:20,
                              color: Colors.white,)),
                            SizedBox(width: 2,),
                            Container(width: size.width*.7,
                              child: TextFormField(
                                style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),

                                cursorColor: Colors.black,
                                initialValue: widget.user.price,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    price=value;
                                  });
                                },
                                decoration: new InputDecoration(
                                  hintStyle: GoogleFonts.cairo(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  hintText: getTranslated(context,'price'),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,

                                  //  hintText: sLabel
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getTranslated(context, "location"),
                          style: GoogleFonts.cairo(
                            color: theme=="light"?Colors.white:Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),),
                        Text(
                          "*", style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),),
                      ],
                    ),
                    SizedBox(height: 2,),
                    Container(height: 45,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: theme=="light"?Colors.white:Colors.grey,
                        borderRadius: BorderRadius.circular(35.0),

                      ),
                      child: Center(
                        child: Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                height: 35,width:35,
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).primaryColor,

                                  //color: Colors.white,
                                  shape: BoxShape.circle,
                                ),child: Icon( Icons.location_on_outlined,size:20,
                              color: Colors.white,)),
                            SizedBox(width: 2,),
                            Container(width: size.width*.7,
                              child: TextFormField(
                                style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),

                                cursorColor: Colors.black,
                                initialValue: widget.user.location,
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  setState(() {
                                    location=value;
                                  });
                                },
                                decoration: new InputDecoration(
                                  hintStyle: GoogleFonts.cairo(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  hintText: getTranslated(context,'location'),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,

                                  //  hintText: sLabel
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Center(
                      child: Container(height: 35,width: size.width*.5,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(35.0),

                        ),child:  Center(
                          child: Text(
                            getTranslated(context, "timeOfWork"),
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getTranslated(context, "workDays"),
                          style: GoogleFonts.cairo(
                            color: theme=="light"?Colors.white:Colors.grey,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),),
                        Text(
                          "*", style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),),
                      ],
                    ),
                    SizedBox(height: 2,),
                    Container(height: 45,
                      padding: const EdgeInsets.only(left: 5,right: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35.0),

                      ),
                      child: Center(
                        child: Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                height: 35,width:35,
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),child: Icon( Icons.calendar_today_outlined,size:20,
                              color: Colors.white,)),
                            SizedBox(width: 2,),
                            Expanded(flex:2,
                              child: Container(
                                child: TextFormField(
                                  onTap: () {
                                    _show(context,size);
                                  },
                                  readOnly: true,
                                  style: GoogleFonts.cairo(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),

                                  cursorColor: Colors.black,
                                  //initialValue: widget.user.name,
                                  controller: daysController,
                                  keyboardType: TextInputType.name,
                                  decoration: new InputDecoration(
                                    hintStyle: GoogleFonts.cairo(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                    hintText: getTranslated(context,'workDays'),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,

                                    //  hintText: sLabel
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                      Container(width:size.width*.4,
                        child: Column(children: [
                          Text(
                            getTranslated(context, "from"),
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),),
                          Container(height: 45,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: theme=="light"?Colors.white:Colors.grey,
                              borderRadius: BorderRadius.circular(35.0),

                            ),
                            child: Center(
                              child: Row(mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 35,width:35,
                                      decoration: new BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                      ),child: Icon( Icons.update,size:20,
                                    color: Colors.white,)),
                                  SizedBox(width: 2,),
                                  Container(width: size.width*.2,
                                    child: TextFormField(
                                      onTap: () {
                                        _selectTimeFrom(context);
                                      },
                                      readOnly: true,
                                      style: GoogleFonts.cairo(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),

                                      cursorColor: Colors.black,
                                      //initialValue: widget.user.name,
                                      controller: fromController,
                                      keyboardType: TextInputType.name,
                                      decoration: new InputDecoration(
                                        hintStyle: GoogleFonts.cairo(
                                          color: Colors.grey,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                        hintText: getTranslated(context,'from'),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],),
                      ),
                      Container(width:size.width*.4,
                        child: Column(children: [
                          Text(
                            getTranslated(context, "to"),
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),),
                          Container(height: 45,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: theme=="light"?Colors.white:Colors.grey,
                              borderRadius: BorderRadius.circular(35.0),

                            ),
                            child: Center(
                              child: Row(mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 35,width:35,
                                      decoration: new BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                      ),child: Icon( Icons.update,size:20,
                                    color: Colors.white,)),
                                  SizedBox(width: 2,),
                                  Container(width: size.width*.2,
                                    child: TextFormField(
                                      onTap: () {
                                        _selectTimeTo(context);
                                      },
                                      readOnly: true,
                                      style: GoogleFonts.cairo(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),

                                      cursorColor: Colors.black,
                                      //initialValue: widget.user.name,
                                      controller: toController,
                                      keyboardType: TextInputType.name,
                                      decoration: new InputDecoration(
                                        hintStyle: GoogleFonts.cairo(
                                          color: Colors.grey,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                        hintText: getTranslated(context,'to'),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,

                                        //  hintText: sLabel
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],),
                      )
                    ],),
                    SizedBox(height: 40,),
                    Container(
                      width: size.width*.8,
                      height: 45.0,
                      child: FlatButton(
                        onPressed: () async {
                          save();
                        },
                        color: AppColors.brown ,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text(
                          getTranslated(context, "saveAndContinue"),
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],),
              ),
            ),
          ],
        ),
      ),
    );
  }
  save() async {

    if(userName==null||bio==null||price==null||userName==""||bio==""||price==""||location==null||location==""){
      showSnack(getTranslated(context, "allRequired"), context,false);

    }
    else if(int.parse(from)>int.parse(to))
    { showSnack(getTranslated(context, "fromError"), context,false);}
    else
    {
      List<String>splitList=userName.split(" ");
      List<String>indexList=[];
      for(int i=0;i<splitList.length;i++)
      {
        for(int y=1;y<splitList[i].length;y++)
        {
          indexList.add(splitList[i].substring(0,y).toLowerCase());
        }
      }
      print(indexList);

      //============packages
      if(widget.user.price!=price){
        widget.user.price=price;
        var querySnapshot = await FirebaseFirestore.instance
            .collection(Paths.packagesPath)
            .where('consultUid', isEqualTo: widget.user.uid)
            .get();


        if(querySnapshot.docs.length>0){
          for (var doc in querySnapshot.docs) {
            var price=doc['callNum']*double.parse(widget.user.price);
            FirebaseFirestore.instance.collection(Paths.packagesPath).doc(doc.id).update({
              'price': price,
            });
          }
        }
        else{
          if(widget.user.consultType=="vocal")
          {
            var packageId0 = Uuid().v4();
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId0)
                .set({
              'price': double.parse(widget.user.price.toString()),
              'discount': 0,
              'callNum': 1,
              'consultUid': widget.user.uid,
              'Id': packageId0,
              'active': true,
            }, SetOptions(merge: true));

            var packageId1 = Uuid().v4();
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId1)
                .set({
              'price': 3*double.parse(widget.user.price),
              'discount': 0,
              'callNum': 3,
              'consultUid': widget.user.uid,
              'Id': packageId1,
              'active': true,
            }, SetOptions(merge: true));



            var packageId2 = Uuid().v4();
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId2)
                .set({
              'price': 6*double.parse(widget.user.price),
              'discount': 0,
              'callNum': 6,
              'consultUid': widget.user.uid,
              'Id': packageId2,
              'active': true,
            }, SetOptions(merge: true));

          }
          else if(widget.user.consultType!="glorified")
          {
            var packageId0 = Uuid().v4();
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId0)
                .set({
              'price': double.parse(widget.user.price.toString()),
              'discount': 0,
              'callNum': 1,
              'consultUid': widget.user.uid,
              'Id': packageId0,
              'active': true,
            }, SetOptions(merge: true));

            var packageId1 = Uuid().v4();
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId1)
                .set({
              'price': 26*double.parse(widget.user.price),
              'discount': 0,
              'callNum': 26,
              'consultUid': widget.user.uid,
              'Id': packageId1,
              'active': true,
            }, SetOptions(merge: true));



            var packageId2 = Uuid().v4();
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId2)
                .set({
              'price': 78*double.parse(widget.user.price),
              'discount': 0,
              'callNum': 78,
              'consultUid': widget.user.uid,
              'Id': packageId2,
              'active': true,
            }, SetOptions(merge: true));

            var packageId3 = Uuid().v4();
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId3)
                .set({
              'price': 156*double.parse(widget.user.price),
              'discount': 0,
              'callNum': 156,
              'consultUid': widget.user.uid,
              'Id': packageId3,
              'active': true,
            }, SetOptions(merge: true));
          }
          else{
            var packageId0 = Uuid().v4();
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId0)
                .set({
              'price': double.parse(widget.user.price.toString()),
              'discount': 0,
              'callNum': 1,
              'consultUid': widget.user.uid,
              'Id': packageId0,
              'active': true,
            }, SetOptions(merge: true));

            var packageId1 = Uuid().v4();
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId1)
                .set({
              'price': 10*double.parse(widget.user.price),
              'discount': 0,
              'callNum': 10,
              'consultUid': widget.user.uid,
              'Id': packageId1,
              'active': true,
            }, SetOptions(merge: true));
          }
        }
        //==================
      }
      var datenow=DateTime.now();

      widget.user.searchIndex=indexList;
      widget.user.name=userName;
      widget.user.bio=bio;
      widget.user.price=price;
      _workTime.from=from;
      _workTime.to=to;
      widget.user.location=location;
      widget.user.voice=allowVoice;
      widget.user.chat=allowChat;
      widget.user.workTimes.clear();
      widget.user.workTimes.add(_workTime);
      widget.user.profileCompleted=true;
      widget.user.userLang=getTranslated(context, 'lang');
      if( widget.user.order==null)
        widget.user.order=0;
      //=============
      widget.user.fromUtc=DateTime(datenow.year, datenow.month, datenow.day,int.parse(from), 0, 0).toUtc().toString();
      widget.user.toUtc=DateTime(datenow.year, datenow.month, datenow.day,int.parse(to), 0, 0).toUtc().toString();

      if (selectedProfileImage != null) {
        accountBloc.add(UpdateAccountDetailsEvent(
            user: widget.user, profileImage: selectedProfileImage));
      } else {
        accountBloc.add(UpdateAccountDetailsEvent(user: widget.user));
      }
    }
  }
  _selectTimeFrom(BuildContext context) async {
    final TimeOfDay timeOfDay = await showTimePicker(
      context: context,
      initialTime: _workTime.from==null?selectedTime:TimeOfDay(hour:int.parse(widget.user.workTimes[0].from ), minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeOfDay != null )
    {
      setState(() {
        from=timeOfDay.hour.toString();
        if(timeOfDay.hour==12)
          fromController.text="12 PM";
       else if(timeOfDay.hour==0)
          fromController.text="12 Am";
        else if(timeOfDay.hour>12)
          fromController.text=(timeOfDay.hour-12).toString()+" PM";
        else
          fromController.text=timeOfDay.hour.toString()+" AM";
      });
    }
  }
  _selectTimeTo(BuildContext context) async {
    final TimeOfDay timeOfDay = await showTimePicker(
      context: context,
      initialTime: _workTime.to==null?selectedTime:TimeOfDay(hour:int.parse(widget.user.workTimes[0].to ), minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeOfDay != null )
    {
      setState(() {
        to=timeOfDay.hour.toString();
        if(timeOfDay.hour==12)
          toController.text="12 PM";
        else if(timeOfDay.hour==0)
          toController.text="12 Am";
        else if(timeOfDay.hour>12)
          toController.text=(timeOfDay.hour-12).toString()+" PM";
        else
          toController.text=timeOfDay.hour.toString()+" AM";
      });
    }
  }
  void _show(BuildContext ctx,size) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Colors.transparent,
      context: ctx,
      builder: (ctx) =>  Container(
        height: size.height*.8,
        width: size.width,
        padding:
        const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(40.0),
              topRight: const Radius.circular(40.0),
            )
        ),
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:StatefulBuilder(builder: (context, setState) {
              return     SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:  [

                    Text(
                      getTranslated(context, "workDays"),
                      style: GoogleFonts.cairo(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: monday,
                          onChanged: (value) {
                            setState(() {
                              monday = value;//!monday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "monday"),
                          style: GoogleFonts.cairo(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                           color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: tuesday,
                          onChanged: (value) {
                            setState(() {
                              tuesday = !tuesday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "tuesday"),
                          style: GoogleFonts.cairo(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: wednesday,
                          onChanged: (value) {
                            setState(() {
                              wednesday = !wednesday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "wednesday"),
                          style: GoogleFonts.cairo(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: thursday,
                          onChanged: (value) {
                            setState(() {
                              thursday = !thursday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "thursday"),
                          style: GoogleFonts.cairo(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: friday,
                          onChanged: (value) {
                            setState(() {
                              friday = !friday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "friday"),
                          style: GoogleFonts.cairo(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: saturday,
                          onChanged: (value) {
                            setState(() {
                              saturday = !saturday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "saturday"),
                          style: GoogleFonts.cairo(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: sunday,
                          onChanged: (value) {
                            setState(() {
                              sunday = !sunday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "sunday"),
                          style: GoogleFonts.cairo(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),

                    Center(
                      child: SizedBox(
                        height:35,
                        width: size.width * 0.5,
                        child: FlatButton(
                          onPressed: () {
                            workDays="";
                            daysValue.clear;
                            widget.user.workDays.clear();
                            if(monday)
                            {
                              workDays=workDays+getTranslated(context,"monday")+",";
                              daysValue.add("1");
                            }
                            if(tuesday)
                            {
                              workDays=workDays+getTranslated(context,"tuesday")+",";
                              daysValue.add("2");
                            }
                            if(wednesday)
                            {
                              workDays=workDays+getTranslated(context,"wednesday")+",";
                              daysValue.add("3");
                            }
                            if(thursday)
                            {
                              workDays=workDays+getTranslated(context,"thursday")+",";
                              daysValue.add("4");
                            }
                            if(friday)
                            {
                              workDays=workDays+getTranslated(context,"friday")+",";
                              daysValue.add("5");
                            }
                            if(saturday)
                            {
                              workDays=workDays+getTranslated(context,"saturday")+",";
                              daysValue.add("6");
                            }
                            if(sunday)
                            {
                              workDays=workDays+getTranslated(context,"sunday")+",";
                              daysValue.add("7");
                            }
                            setState(() {
                              daysController.text=workDays;
                              print("days   "+ daysController.text);
                              widget.user.workDays=daysValue;
                            });
                            Navigator.pop(context);
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Text(
                            getTranslated(context,"done"),
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],),
              );
            })


        ),
      ),);
  }
  void _showTypes(BuildContext ctx,size) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Colors.transparent,
      context: ctx,
      builder: (ctx) =>  Container(
        height: size.height*.4,
        width: size.width,
        padding:
        const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(40.0),
              topRight: const Radius.circular(40.0),
            )
        ),
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:StatefulBuilder(builder: (context, setState) {
              return     SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:  [

                    Text(
                      getTranslated(context, "accountType"),
                      style: GoogleFonts.cairo(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: allowChat,
                          onChanged: (value) {
                            setState(() {
                              allowChat =value;// !allowChat;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "allowChat"),
                          style: GoogleFonts.cairo(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: allowVoice,
                          onChanged: (value) {
                            setState(() {
                              allowVoice = value;//!allowVoice;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "allowVoice"),
                          style: GoogleFonts.cairo(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),


                    Center(
                      child: SizedBox(
                        height:35,
                        width: size.width * 0.5,
                        child: FlatButton(
                          onPressed: () {
                            type="";
                            if(allowVoice)
                            {
                              type=type+"Voice";
                              widget.user.voice=true;
                            }
                            if(allowChat)
                            {
                              type=type+"- Chat";
                              widget.user.chat=true;
                            }

                            setState(() {
                              typeController.text=type;
                              print("days   "+ typeController.text);
                            });
                            Navigator.pop(context);
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Text(
                            getTranslated(context,"done"),
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],),
              );
            })


        ),
      ),);
  }
  void _showLang(BuildContext ctx,size) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Colors.transparent,
      context: ctx,
      builder: (ctx) =>  Container(
        height: size.height*.4,
        width: size.width,
        padding:
        const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(40.0),
              topRight: const Radius.circular(40.0),
            )
        ),
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:StatefulBuilder(builder: (context, setState) {
              return     SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:  [

                    Text(
                      getTranslated(context, "languages"),
                      style: GoogleFonts.cairo(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: arabic,
                          onChanged: (value) {
                            setState(() {
                              arabic = !arabic;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "arabic"),
                          style: GoogleFonts.cairo(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: english,
                          onChanged: (value) {
                            setState(() {
                              english = !english;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "english"),
                          style: GoogleFonts.cairo(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),


                    Center(
                      child: SizedBox(
                        height:35,
                        width: size.width * 0.5,
                        child: FlatButton(
                          onPressed: () {
                            lang="";
                            widget.user.languages.clear();
                            if(arabic)
                            {
                              lang=lang+"العربية";
                              widget.user.languages.add("العربية");
                            }
                            if(english)
                            {
                              lang=lang+" - English";
                              widget.user.languages.add("English");
                            }

                            setState(() {
                              langController.text=lang;
                              print("days   "+ langController.text);
                            });
                            Navigator.pop(context);
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Text(
                            getTranslated(context,"done"),
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],),
              );
            })


        ),
      ),);
  }
  showDaysDialog1(Size size) {
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
              height: 5.0,
            ),
            Text(
              getTranslated(context, "workDays"),
              style: GoogleFonts.cairo(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: theme=="light"?Colors.white:Colors.black,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Container(
              width: 70.0,
              child: FlatButton(
                padding: const EdgeInsets.all(0.0),
                onPressed: () {
                  Navigator.pop(context);

                },
                child: Text(
                  getTranslated(context, 'done'),
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
      ), barrierDismissible: false,
      context: context,
    );
  }
}
