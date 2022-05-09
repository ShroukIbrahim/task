// @dart=2.9

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/userPaymentHistory.dart';
import 'package:grocery_store/widget/orderListItem.dart';
import 'package:grocery_store/widget/userPaymentHistoryListItem.dart';
import 'package:http/http.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
class AddGrantsScreen extends StatefulWidget {
  final GroceryUser loggedUser;
  const AddGrantsScreen({Key key, this.loggedUser}) : super(key: key);
  @override
  _AddGrantsScreenState createState() => _AddGrantsScreenState();
}

class _AddGrantsScreenState extends State<AddGrantsScreen>with SingleTickerProviderStateMixin {
  AccountBloc accountBloc;
  GroceryUser user;
  bool load=false,showBalance=true,showHistory=false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving=false,publicSpeaking=false,educationAndTeaching=false,advocacyWork=false;
  GroceryUser searchUser;
  //var personalImage,personalIdImage,quranImage;
  var selectedPersonalImage,selectedPersonalImageId,selectedQueanImage;
  String  name,country,phone,school,education,age,grantDate,langLevel,personalIdPhoto,personalPhoto,quranLevel,quranPhoto,referance,scienceLevel,theme;
  List<dynamic>futureWork;
  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetAccountDetailsEvent(widget.loggedUser.uid));
    accountBloc.listen((state) {
      print(state);
      if (state is GetAccountDetailsCompletedState) {
        user = state.user;
        if(mounted)
          setState(() {
            load=false;
          });
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
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body:
      Column(
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
                child: Container(height: 80,
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                          getTranslated(context, "grantRequest"),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 3,
                          style: GoogleFonts.cairo(
                            color: theme=="light"?Colors.white:Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: ListView(padding:const EdgeInsets.only(left: 10,right: 10),
                children: <Widget>[
                  widget.loggedUser.sendGrant?SizedBox(height: 50,):SizedBox(height: 1,),
                  widget.loggedUser.sendGrant? Center(
                    child: Text(
                      getTranslated(context, "grantAdded"),
                      textAlign:TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      maxLines: 3,
                      style: GoogleFonts.cairo(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ):Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          Center(
                            child: Container(height: 35,width: size.width*.7,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color:Colors.white,
                                borderRadius: BorderRadius.circular(35.0),
                                border: Border.all(color:  theme=="light"?Theme.of(context).primaryColor:Colors.black,width: 1),

                              ),child:  Center(
                                child: Text(
                                  getTranslated(context,"personalInformation"),
                                  style: GoogleFonts.cairo(
                                    color: Colors.black,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              name=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.person_outline,color: AppColors.pink,),
                              labelText: getTranslated(context, "name"),
                              hintText:  getTranslated(context, "name"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              phone=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.call,color:AppColors.pink),
                              labelText: getTranslated(context, "phoneNumber"),
                              hintText: "+966XXXXXXXXX",
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              country=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.language,color: AppColors.pink,),
                              labelText: getTranslated(context, "country"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              age=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.date_range,color: AppColors.pink,),
                              labelText: getTranslated(context, "age"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              school=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.school,color: AppColors.pink,),
                              labelText: getTranslated(context, "school"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              education=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.cast_for_education,color: AppColors.pink,),
                              labelText: getTranslated(context, "education"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              referance=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.file_copy_outlined,color: AppColors.pink,),
                              labelText: getTranslated(context, "referance"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            getTranslated(context,"personalPhoto"),
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontSize: 13.0,
                              letterSpacing: 0.5,
                            ),),
                          SizedBox(
                            height: 15.0,
                          ),
                          Center(
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: size.width * 0.45,
                                  width: size.width * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: theme=="light"?Colors.white:Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 0.0),
                                        blurRadius: 15.0,
                                        spreadRadius: 2.0,
                                        color: Colors.black.withOpacity(0.05),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: selectedPersonalImage == null
                                        ? Icon(
                                      Icons.image,
                                      size: 50.0,
                                    )
                                        : ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(20.0),
                                      child: Image.file(
                                        selectedPersonalImage,
                                      ),
                                    ),
                                  ),
                                ),
                                selectedPersonalImage != null
                                    ? Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.5),
                                        onTap: () {
                                          cropImage(context,"personalPhoto");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.edit,
                                            color:theme=="light"?Colors.white:Colors.black,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.5),
                                        onTap: () {
                                          cropImage(context,"personalPhoto");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            getTranslated(context,"personalPhotoId"),
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontSize: 13.0,
                              letterSpacing: 0.5,
                            ),),
                          SizedBox(
                            height: 15.0,
                          ),
                          Center(
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: size.width * 0.45,
                                  width: size.width * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: theme=="light"?Colors.white:Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 0.0),
                                        blurRadius: 15.0,
                                        spreadRadius: 2.0,
                                        color: Colors.black.withOpacity(0.05),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: selectedPersonalImageId == null
                                        ? Icon(
                                      Icons.image,
                                      size: 50.0,
                                    )
                                        : ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(20.0),
                                      child: Image.file(
                                        selectedPersonalImageId,
                                      ),
                                    ),
                                  ),
                                ),
                                selectedPersonalImageId != null
                                    ? Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.5),
                                        onTap: () {
                                          cropImage(context,"personalPhotoId");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.edit,
                                            color:theme=="light"?Colors.white:Colors.black,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.5),
                                        onTap: () {
                                          cropImage(context,"personalPhotoId");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Center(
                            child: Container(height: 35,width: size.width*.7,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color:Colors.white,
                                borderRadius: BorderRadius.circular(35.0),
                                border: Border.all(color:  theme=="light"?Theme.of(context).primaryColor:Colors.black,width: 1),

                              ),child:  Center(
                                child: Text(
                                  getTranslated(context,"education"),
                                  style: GoogleFonts.cairo(
                                    color: Colors.black,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              scienceLevel=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            textInputAction: TextInputAction.newline,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 150,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.school,color: AppColors.pink),
                              labelText: getTranslated(context, "scienceLevel"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              langLevel=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            textInputAction: TextInputAction.newline,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 150,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.school,color: AppColors.pink),
                              labelText: getTranslated(context, "langLevel"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              quranLevel=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            textInputAction: TextInputAction.newline,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 150,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.school,color: AppColors.pink),
                              labelText: getTranslated(context, "quranLevel"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Text(
                            getTranslated(context,"quranPhoto"),
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontSize: 13.0,
                              letterSpacing: 0.5,
                            ),),
                          SizedBox(
                            height: 15.0,
                          ),
                          Center(
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: size.width * 0.45,
                                  width: size.width * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: theme=="light"?Colors.white:Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 0.0),
                                        blurRadius: 15.0,
                                        spreadRadius: 2.0,
                                        color: Colors.black.withOpacity(0.05),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: selectedQueanImage == null
                                        ? Icon(
                                      Icons.image,
                                      size: 50.0,
                                    )
                                        : ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(20.0),
                                      child: Image.file(
                                        selectedQueanImage,
                                      ),
                                    ),
                                  ),
                                ),
                                selectedQueanImage != null
                                    ? Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.5),
                                        onTap: () {
                                          cropImage(context,"quranPhoto");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.edit,
                                            color:theme=="light"?Colors.white:Colors.black,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.5),
                                        onTap: () {
                                          cropImage(context,"quranPhoto");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Center(
                            child: Container(height: 35,width: size.width*.7,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color:Colors.white,
                                borderRadius: BorderRadius.circular(35.0),
                                border: Border.all(color:  theme=="light"?Theme.of(context).primaryColor:Colors.black,width: 1),

                              ),child:  Center(
                                child: Text(
                                  getTranslated(context,"futureWork"),
                                  style: GoogleFonts.cairo(
                                    color: Colors.black,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: publicSpeaking,
                                onChanged: (value) {
                                  setState(() {
                                    publicSpeaking = !publicSpeaking;
                                  });
                                },
                              ),
                              Text(
                                getTranslated(context, "publicSpeaking"),
                                style: GoogleFonts.cairo(
                                  fontSize: 15.0,
                                  color: Colors.black,

                                ),
                              ),
                            ],
                          ),

                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: educationAndTeaching,
                                onChanged: (value) {
                                  setState(() {
                                    educationAndTeaching = !educationAndTeaching;
                                  });
                                },
                              ),
                              Text(
                                getTranslated(context, "educationAndTeaching"),
                                style: GoogleFonts.cairo(
                                  fontSize: 15.0,
                                  color: Colors.black,

                                ),
                              ),
                            ],
                          ),

                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: advocacyWork,
                                onChanged: (value) {
                                  setState(() {
                                    advocacyWork = !advocacyWork;
                                  });
                                },
                              ),
                              Text(
                                getTranslated(context, "advocacyWork"),
                                style: GoogleFonts.cairo(
                                  fontSize: 15.0,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25.0,
                          ),

                          Container(
                            height: 45.0,
                            width: double.infinity,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 0.0),
                            child: saving?Center(child: CircularProgressIndicator()):FlatButton(
                              onPressed: () {
                                save();
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

                                  Text(
                                    getTranslated(context, "save"),
                                    style: GoogleFonts.poppins(
                                      color:theme=="light"?Colors.white:Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          )


        ],
      ),
    );
  }
  Future cropImage(context,String type) async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.ratio16x9,
      ],
      aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
      cropStyle: CropStyle.rectangle,
      compressFormat: ImageCompressFormat.jpg,
      maxHeight: 300,
      maxWidth: 600,
      compressQuality: 50,
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
      ),
    );

    if (croppedFile != null) {
      if(type=="personalPhoto")
        setState(() {
          selectedPersonalImage = croppedFile;
        });
      else if(type=="personalPhotoId")
        setState(() {
          selectedPersonalImageId = croppedFile;
        });
      else
        setState(() {
          selectedQueanImage = croppedFile;
        });

    } else {
      //not croppped

    }
  }
  save() async {

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try{
        if(selectedQueanImage!=null&&selectedPersonalImageId!=null&&selectedPersonalImage!=null)
        {
          setState(() {
            saving=true;
          });
          if (selectedPersonalImage != null) {
            var uuid1 = Uuid().v4();
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('grants/$uuid1');
            await storageReference.putFile(selectedPersonalImage);
            personalPhoto = await storageReference.getDownloadURL();
          }
          if (selectedPersonalImageId != null) {
            var uuid2 = Uuid().v4();
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('grants/$uuid2');
            await storageReference.putFile(selectedPersonalImageId);
            personalIdPhoto = await storageReference.getDownloadURL();
          }
          if (selectedQueanImage != null) {
            var uuid3 = Uuid().v4();
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('grants/$uuid3');
            await storageReference.putFile(selectedQueanImage);
            quranPhoto = await storageReference.getDownloadURL();
          }
          futureWork=[];
          if(publicSpeaking)
            futureWork.add("publicSpeaking");
          if(educationAndTeaching)
            futureWork.add("educationAndTeaching");
          if(advocacyWork)
            futureWork.add("advocacyWork");
          String grantId=Uuid().v4();
          await FirebaseFirestore.instance.collection(Paths.grantsPath)
              .doc(grantId)
              .set({
            "userUid":widget.loggedUser.uid,
            'grantId': grantId,
            'status':"new",
            'grantDate': Timestamp.now(),
            'name': name,
            'age':age,
            'country': country,
            'phone':phone,
            'education': education,
            'school':school,
            'langLevel': langLevel,
            'quranLevel':quranLevel,
            'scienceLevel': scienceLevel,
            'referance':referance,
            'personalPhoto': personalPhoto,
            'personalPhoto':personalPhoto,
            'personalIdPhoto': personalIdPhoto,
            'quranPhoto':quranPhoto,
            'futureWork':futureWork



          });
          await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.loggedUser.uid).set({
            'sendGrant':true,
          }, SetOptions(merge: true));
          accountBloc.add(GetAccountDetailsEvent(widget.loggedUser.uid));
          setState(() {
            saving = false;
          });
          addingDialog(MediaQuery.of(context).size,true);
        }
        else
        {
          showSnakbar(getTranslated(context, "enterAll"), false);
        }

      }catch(e)
      {print("rrrrrrrrrr"+e.toString());}
    }

  }
  addingDialog(Size size,bool status) {

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
            Text(
              getTranslated(context, "grants"),
              style: GoogleFonts.cairo(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 15.0,
            ),

            Text(
              getTranslated(context, "grantAdded"),
              style: GoogleFonts.cairo(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Center(
              child: Container(
                width: size.width*.5,
                child: FlatButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
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
            ),
          ],
        ),
      ), barrierDismissible: false,
      context: context,
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
}
