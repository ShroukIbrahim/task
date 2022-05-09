// @dart=2.9
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../config/colorsFile.dart';
class UserAccountScreen extends StatefulWidget {
  final GroceryUser user;
  final bool firstLogged;
  const UserAccountScreen({Key key, this.user, this.firstLogged}) : super(key: key);
  @override
  _UserAccountScreenState createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  AccountBloc accountBloc;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TimeOfDay selectedTime = TimeOfDay.now();
  String name,userName,bio,theme,age,education;
  ScrollController scrollController;
  var image;
  File selectedProfileImage;
bool profileCompleted=false;
  @override
  void initState() {
    super.initState();

    userName=widget.user.name;
    age=widget.user.age;
    education=widget.user.education;
    profileCompleted=widget.user.profileCompleted;
    bio=widget.user.bio;
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.listen((state) {
      print(state);
      if (state is GetAccountDetailsCompletedState) {
        if(mounted)
        {
          Navigator.pop(context);

        }
      }
      if (state is UpdateAccountDetailsInProgressState) {
        //show dialog
        if(mounted)
        showUpdatingDialog();
      }
      if (state is UpdateAccountDetailsFailedState) {
        //show error
        if(mounted)
        showSnack(getTranslated(context, "error"), context,false);
      }
      if (state is UpdateAccountDetailsCompletedState) {
       if(mounted){
         accountBloc.add(GetAccountDetailsEvent(widget.user.uid));
         selectedProfileImage=null;
        // Navigator.pop(context);
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
      borderRadius: BorderRadius.circular(7),
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
  void showFailedSnakbar(String s,bool status) {
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
          statusBarColor: Theme.of(context).primaryColor,
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

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body:  SingleChildScrollView(controller: scrollController,
        child: Column(
          children: <Widget>[
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    splashColor: Colors.white.withOpacity(0.5),
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                            (route) => false,
                      );
                    },
                    child: Image.asset(theme!="light"?
                    'assets/applicationIcons/whiteLogo.png':'assets/applicationIcons/whiteLogo.png',
                      width: 50,
                      height:50,
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
            SizedBox(height: 30,),
            Container(
              height:size.height,
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
                        color: theme=="light"?Colors.white:Colors.grey[300],
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
                          getTranslated(context, "age"),
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
                        color: theme=="light"?Colors.white:Colors.grey[300],
                        borderRadius: BorderRadius.circular(35.0),

                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              height: 35,width:35,
                              decoration: new BoxDecoration(
                                color: Theme.of(context).primaryColor,

                                shape: BoxShape.circle,
                              ),child: Icon( Icons.workspaces_outline,size:20,
                            color: Colors.white,)),
                          SizedBox(width: 2,),
                          Expanded(flex:2,
                            child: Container(
                              child:  TextFormField(
                                style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                cursorColor: Colors.black,
                                initialValue: widget.user.age,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    age = value;
                                  });
                                },
                                decoration: new InputDecoration(
                                  hintStyle: GoogleFonts.cairo(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  hintText: getTranslated(context,'age'),
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
                          getTranslated(context, "education"),
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
                        color: theme=="light"?Colors.white:Colors.grey[300],
                        borderRadius: BorderRadius.circular(35.0),

                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              height: 35,width:35,
                              decoration: new BoxDecoration(
                                color: Theme.of(context).primaryColor,

                                shape: BoxShape.circle,
                              ),child: Icon( Icons.account_box_rounded,size:20,
                            color: Colors.white,)),
                          SizedBox(width: 2,),
                          Expanded(flex:2,
                            child: Container(
                              child:  TextFormField(
                                style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                cursorColor: Colors.black,
                                initialValue: widget.user.education,
                                keyboardType: TextInputType.name,
                                onChanged: (value) {
                                  setState(() {
                                    education = value;
                                  });
                                },
                                decoration: new InputDecoration(
                                  hintStyle: GoogleFonts.cairo(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  hintText: getTranslated(context,'education'),
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
                        /*Text(
                          "", style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),),*/
                      ],
                    ),
                    SizedBox(height: 2,),
                    Container(height: 150,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: theme=="light"?Colors.white:Colors.grey[300],
                        borderRadius: BorderRadius.circular(35.0),

                      ),
                      child: Center(
                        child:Container(width: size.width*.7,
                          child: TextFormField(
                            maxLines: 7,
                            maxLength: 300,
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),

                            cursorColor: Colors.black,
                            initialValue: widget.user.bio,
                            keyboardType: TextInputType.name,
                            onChanged: (value) {
                              setState(() {
                                bio=value;
                              });
                            },
                            decoration: new InputDecoration(
                              counterStyle: TextStyle( color: Colors.grey,
                                fontSize: 13,),
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
                    SizedBox(height: 40,),
                    Container(
                      width: size.width*.8,
                      height: 45.0,
                      child: FlatButton(
                        onPressed: () async {
                          save();
                        },
                        color: AppColors.brown,
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
  save(){
    if(userName==null||userName==""){
      showSnack(getTranslated(context, "allRequired"), context,false);
    }

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
      print("searchindex");
      print(indexList);
      widget.user.searchIndex=indexList;
      widget.user.name=userName;
      widget.user.bio=bio;
      widget.user.age=age;
      widget.user.education=education;
      widget.user.profileCompleted=true;
      widget.user.userLang=getTranslated(context, 'lang');
      if (selectedProfileImage != null) {
        accountBloc.add(UpdateAccountDetailsEvent(
            user: widget.user, profileImage: selectedProfileImage));
      } else {
        accountBloc.add(UpdateAccountDetailsEvent(user: widget.user));
      }
    }
  }

}
