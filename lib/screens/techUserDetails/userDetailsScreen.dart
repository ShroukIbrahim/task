// @dart=2.9
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/SupportList.dart';
import 'package:grocery_store/models/consultPackage.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/reviews_screen.dart';
import 'package:grocery_store/screens/techUserDetails/userAppointmentScreen.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:uuid/uuid.dart';

import '../myOrderScreen.dart';
import '../supportMessagesScreen.dart';
class UserDetailsScreen extends StatefulWidget {
  final GroceryUser user;
  final GroceryUser loggedUser;

  const UserDetailsScreen({Key key, this.user, this.loggedUser}) : super(key: key);
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int localFrom,localTo;
  String languages="", workDays="",workDaysValue="",from="",to="",lang="",theme;
  final TextEditingController callNumController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController displayController = TextEditingController();

  DateTime _now=DateTime.now();
  final TextEditingController searchController = new TextEditingController();
  List <consultPackage>packages=[];
  bool first=true,saving=false,load=false,activeValue=false,activeUser=false;
  consultPackage package;
  bool avaliable=false,delete=false,chating=false;

  @override
  void initState() {
    super.initState();
    if(widget.user.userType=="CONSULTANT")
    getConsultPackages();


    if(widget.user.userType=="CONSULTANT"&&widget.user.languages.length>0)
      widget.user.languages.forEach((element) { languages=languages+" "+element;});
    String dayNow=DateTime.now().weekday.toString();
    int timeNow=DateTime.now().hour;
    if(widget.user.workDays.contains(dayNow))
    {
      if(widget.user.fromUtc!=null&&widget.user.toUtc!=null)
        {
          localFrom= DateTime.parse(widget.user.fromUtc).toLocal().hour;
          localTo=DateTime.parse(widget.user.toUtc).toLocal().hour;
          if (localFrom<=timeNow&&localTo>timeNow) {
            avaliable=true;
          }
          if(widget.user.workTimes.length>0)
          {
            if( localFrom==12)
              from="12 PM";
            else if( localFrom==0)
              from="12 AM";
            else if( localFrom>12)
              from=((localFrom)-12).toString()+" PM";
            else
              from=(localFrom).toString()+" AM";

          }
          if(widget.user.workTimes.length>0)
          {
            if( localTo==12)
              to="12 PM";
            else if( localTo==0)
              to="12 AM";
            else if( localTo>12)
              to=((localTo)-12).toString()+" PM";
            else
              to=(localTo).toString()+" AM";

          }
        }
    }

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
  Future<void> getConsultPackages() async {
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.packagesPath)
          .where( 'consultUid', isEqualTo: widget.user.uid,)
          .orderBy("callNum", descending: false)
          .get();
      if(querySnapshot.docs.length>0)
      {
        setState(() {
          packages = List<consultPackage>.from(
            querySnapshot.docs.map(
                  (snapshot) => consultPackage.fromFirestore(snapshot),
            ),
          );
        });
      }
      else
        setState(() {
          packages=[];
        });

    }catch(e){
      print("getnumbererror"+e.toString());
    }
  }
  @override
  void dispose() {
    super.dispose();

    searchController.dispose();
    priceController.dispose();
    discountController.dispose();
    callNumController.dispose();
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


  @override
  Widget build(BuildContext context) {

    lang=getTranslated(context, "lang");

    if(widget.user.userType=="CONSULTANT"&&first&&widget.user.workDays.length>0) {
      workDays="";
      if(widget.user.workDays.contains("1"))
      {
        workDays=workDays+getTranslated(context,"monday")+",";
      }
      if(widget.user.workDays.contains("2"))
      {
        workDays=workDays+getTranslated(context,"tuesday")+",";
      }
      if(widget.user.workDays.contains("3"))
      {
        workDays=workDays+getTranslated(context,"wednesday")+",";
      }
      if(widget.user.workDays.contains("4"))
      {
        workDays=workDays+getTranslated(context,"thursday")+",";
      }
      if(widget.user.workDays.contains("5"))
      {
        workDays=workDays+getTranslated(context,"friday")+",";
      }
      if(widget.user.workDays.contains("6"))
      {
        workDays=workDays+getTranslated(context,"saturday")+",";
      }
      if(widget.user.workDays.contains("7"))
      {
        workDays=workDays+getTranslated(context,"sunday")+",";
      }
      setState(() {
        workDaysValue="";
        workDaysValue=workDays;
        first=false;
      });
    }
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key:_scaffoldKey,
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child: Padding(
                padding:  EdgeInsets.only(
                    right: lang=="ar"?16:10.0, left:lang=="ar"?10.0:16.0, top: 5.0, bottom: 16.0),
                child: Container(width: size.width,height: 100,
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
                      Text(
                        getTranslated(context, "details"),
                        style: GoogleFonts.poppins(
                          color: theme=="light"?Colors.white:Colors.black,
                          fontSize: 19.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      chating?CircularProgressIndicator():ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.white.withOpacity(0.5),
                            onTap: () {
                               startChat();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              width: 38.0,
                              height: 35.0,
                              child: Icon(
                                Icons.chat_outlined,
                                color: theme=="light"?Colors.white:Colors.black,
                                size: 24.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(physics:  AlwaysScrollableScrollPhysics(),children: [
                  SizedBox(height: 40,),
                  Center(
                    child: Container(height: 200,width: size.width*.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.white,width: 2),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 0.0),
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),child:Column(
                        children: [
                          Container(height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(25.0),

                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, "bio"),
                                    style: GoogleFonts.cairo(
                                      color: theme=="light"?Colors.white:Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(),

                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                widget.user.bio==null?"...": widget.user.bio,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 4,
                                style: GoogleFonts.cairo(
                                  color:theme=="light"? Theme.of(context).primaryColor:Colors.black,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),),
                  ),
                   widget.user.userType=="USER"?SizedBox():Column(children: [
                          SizedBox(height: 20,),
                          Center(
                            child: Container(height: 35,width: size.width*.5,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
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
                          Row(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.center,children: [
                            //Icon( Icons.calendar_today_outlined,size:30,  color: Theme.of(context).primaryColor,),
                            Image.asset(theme=="light"?
                            'assets/applicationIcons/Iconly-Two-tone-Calendar-1.png':'assets/applicationIcons/Iconly-Two-tone-Calendar.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 5,),
                            Container(height: 70,width: size.width*.8,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.circular(30.0),

                              ),child:  Center(
                                child: Text(
                                  workDaysValue,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  style: GoogleFonts.cairo(
                                    color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),),
                              ),
                            ),
                          ],),
                          SizedBox(height: 20,),
                          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,crossAxisAlignment:CrossAxisAlignment.center,children: [
                            // Icon( Icons.update,size:30,  color: Theme.of(context).primaryColor,),
                            Image.asset(theme=="light"?
                            'assets/applicationIcons/Iconly-Two-tone-TimeCircle.png':'assets/applicationIcons/whiteTime.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 5,),
                            Container(height: 35,width: size.width*.3,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.circular(30.0),

                              ),child:  Center(
                                child:  Text(
                                  from,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  style: GoogleFonts.cairo(
                                    color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),),
                              ),
                            ),
                            Container(height: 35,width: size.width*.3,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.circular(30.0),

                              ),child:  Center(
                                child:Text(
                                  to,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  style: GoogleFonts.cairo(
                                    color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),),
                              ),
                            ),
                            SizedBox(width: 5,),
                          ],),
                          SizedBox(height: 30,),
                          Center(
                              child:  Container(width: size.width*.9,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25.0),
                                  border: Border.all(color: Colors.white,width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 0.0),
                                      blurRadius: 5.0,
                                      spreadRadius: 1.0,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                                child: Column(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(height: 50,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(25.0),

                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10,right: 10),
                                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              getTranslated(context, "allPackages"),
                                              style: GoogleFonts.cairo(
                                                color: theme=="light"?Colors.white:Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                package=new consultPackage();
                                                package.Id=Uuid().v4();
                                                package.price=0;
                                                package.discount=0;
                                                package.callNum=0;
                                                package.active=true;
                                                package.consultUid=widget.user.uid;
                                                packageDialog(size, package);
                                              },
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color: theme=="light"?Colors.white:Colors.black,
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Center(
                                      child:  packages.length==0? Text(
                                        getTranslated(context, "noPackages"),
                                        style: GoogleFonts.cairo(
                                          color: Colors.black87,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ):ListView.separated(
                                        itemCount: packages.length,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.all(0),
                                        itemBuilder: (context, index) {

                                          return InkWell(
                                            splashColor:
                                            Colors.red.withOpacity(0.5),
                                            onTap: () {
                                              packageDialog(size,packages[index]);
                                            },
                                            child: Container(height: 50,width: size.width,
                                                padding: const EdgeInsets.only(left: 10,right: 10),
                                                decoration: BoxDecoration(
                                                  color: AppColors.grey,
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  border: Border.all(color:  Colors.grey[300],width: 2),

                                                ),child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                                                  Container(width: size.width*.25,
                                                    child: Text(
                                                      packages[index].callNum.toString()+getTranslated(context, "call"),
                                                      style: GoogleFonts.cairo(
                                                        color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.bold,
                                                      ),),
                                                  ),
                                                  Container(height: 25,width: size.width*.25,
                                                    //padding: const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.lightGreen,
                                                      borderRadius: BorderRadius.circular(25.0),

                                                    ),child:Center(
                                                      child: Text(
                                                        packages[index].discount.toString()+"%"+getTranslated(context, "discount"),
                                                        style: GoogleFonts.cairo(
                                                          color: Colors.black,
                                                          fontSize: 13.0,
                                                          fontWeight: FontWeight.bold,
                                                          letterSpacing: 0.5,
                                                        ),),
                                                    ),),
                                                  Container(height: 35,width: size.width*.25,
                                                    padding: const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).primaryColor,
                                                      borderRadius: BorderRadius.circular(25.0),

                                                    ),child:Center(
                                                      child: Text(
                                                        packages[index].price.toString()+"\$",
                                                        style: GoogleFonts.cairo(
                                                          color: theme=="light"?Colors.white:Colors.black,
                                                          fontSize: 13.0,
                                                          fontWeight: FontWeight.bold,
                                                          letterSpacing: 0.5,
                                                        ),),
                                                    ),)
                                                ],)
                                            ),
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return SizedBox(
                                            height: 8.0,
                                          );
                                        },
                                      ),
                                    )],
                                ),
                              )),
                        ],),

                  SizedBox(height: 20,),
                  Container(height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(25.0),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            getTranslated(context, "allOrders"),
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyOrdersScreen(user:widget.user,loggedType:widget.user.userType,fromSupport: true, ), ),  );
                            },
                            icon: Icon(
                              Icons.arrow_forward,
                              color: theme=="light"?Colors.white:Colors.black,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(25.0),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            getTranslated(context, "appointments"),
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserAppointmentsScreen(user:widget.user ), ),  );
                            },
                            icon: Icon(
                              Icons.arrow_forward,
                              color: theme=="light"?Colors.white:Colors.black,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40,),

                ],),
              ),
            )


          ],
        ),
        Positioned(
          right: 0.0,
          top: 130.0,
          left: 0,
          child: Center(
            child:  Container(width: size.width*.9,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 0.0),
                    blurRadius: 15.0,
                    spreadRadius: 2.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
                border: Border.all(color: Colors.white,width: 3),
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black,width: 3),
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: widget.user.photoUrl.isEmpty ?
                              Icon( Icons.person,color:Colors.black,size: 50.0, )
                                  :ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                  'assets/icons/icon_person.png',
                                  placeholderScale: 0.5,
                                  imageErrorBuilder:(context, error, stackTrace) => Icon(
                                    Icons.person,color:Colors.black,
                                    size: 50.0,
                                  ),
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
                            Positioned(
                              bottom: 5,
                              left: 5.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Material(
                                  color: Theme.of(context).primaryColor,
                                  child: InkWell(
                                    splashColor: Colors.white.withOpacity(0.5),
                                    onTap: () {

                                    },
                                    child: Container(
                                      decoration:  BoxDecoration(
                                        border: Border.all(color: Colors.black,width: 2),
                                        shape: BoxShape.circle,
                                        color: avaliable?AppColors.brown:Colors.red,
                                      ),
                                      width: 10.0,
                                      height: 10.0,

                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex:2,
                        child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.user.name,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.cairo(
                                color: theme=="light"?Colors.white:Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.mic_none,
                                  size: 15,
                                  color: theme=="light"?Colors.white:Colors.black,
                                ),
                                Text(
                                  languages,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                  style: GoogleFonts.cairo(
                                    color: theme=="light"?Colors.white:Colors.black,
                                    fontSize: 15.0,
                                    // fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),

                            Row( mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 13,
                                      color: AppColors.yellow,
                                    ),
                                    Text(
                                      widget.user.rating==null?"0": widget.user.rating.toStringAsFixed(1),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color: theme=="light"?Colors.white:Colors.black,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 20,),
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/applicationIcons/greenCall.png',
                                      width: 15,
                                      height: 15,
                                    ),


                                    Text(
                                      widget.user.ordersNumbers==null?"0":widget.user.ordersNumbers.toString(),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color: theme=="light"?Colors.white:Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],),
                      ),
                      Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            widget.user.price==null?'0':widget.user.price+"\$",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 5,),
                          Container(
                            width: 40,height: 40,
                            decoration: BoxDecoration(
                              // border: Border.all( color: Colors.red[500],),
                                color: avaliable?AppColors.brown:Colors.red,
                                borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            child:  Center(
                              child:avaliable? Image.asset(
                                'assets/applicationIcons/Iconly-Two-tone-Calling-1.png',
                                width: 20,
                                height: 20,
                              ):Image.asset(
                                'assets/applicationIcons/Iconly-Two-tone-Calling-1.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ],),
                    ],
                  ),

                ],
              ),


            ),
          ),
        ),

      ]),
    );
  }
  void showNoNotifSnack(String text,bool status) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: status?Colors.green.shade500:Colors.red.shade500,
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
  packageDialog(Size size,consultPackage selectedPackage) {
    callNumController.text=selectedPackage.callNum.toString();
    priceController.text=selectedPackage.price.toString();
    discountController.text=selectedPackage.discount.toString();
    activeValue=selectedPackage.active;
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
          content:StatefulBuilder(builder: (context, setState) {
            return
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 5,),
                      Text(
                        getTranslated(context, "edit"),
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: Colors.black87,
                        ),
                      ),
                      InkWell( splashColor: Colors.white.withOpacity(0.5),
                        onTap: () async {
                          await FirebaseFirestore.instance.collection(
                              Paths.packagesPath).doc(selectedPackage.Id).delete();
                          getConsultPackages();
                          Navigator.pop(context);
                        },
                        child: Icon( Icons.delete,
                          color: Colors.red,
                          size: 24.0,),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15.0,
                  ),

                  Row(
                    children: [
                      Container(width: size.width * .3,
                        child: Text(
                          getTranslated(context, "call"),
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                      Container(width: size.width * .3,
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: TextFormField(
                          //initialValue: selectedPackage.callNum.toString(),
                          controller: callNumController,
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                         enableInteractiveSelection: true,
                          style: GoogleFonts.cairo(
                            fontSize: 14.0,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                            border: InputBorder.none,
                            hintText: getTranslated(context, "call"),
                            hintStyle: GoogleFonts.cairo(
                              fontSize: 14.0,
                              color: Colors.black54,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                            ),
                            counterStyle: GoogleFonts.cairo(
                              fontSize: 12.5,
                              color: Colors.black54,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0,),

                  Row(
                    children: [
                      Container(width: size.width * .3,
                        child: Text(
                          getTranslated(context, "discount"),
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                      Container(width: size.width * .3,
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: TextFormField(
                          //initialValue: selectedPackage.callNum.toString(),
                          controller: discountController,
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                         enableInteractiveSelection: true,
                          style: GoogleFonts.cairo(
                            fontSize: 14.0,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                            border: InputBorder.none,
                            hintText: getTranslated(context, "discount"),
                            hintStyle: GoogleFonts.cairo(
                              fontSize: 14.0,
                              color: Colors.black54,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                            ),
                            counterStyle: GoogleFonts.cairo(
                              fontSize: 12.5,
                              color: Colors.black54,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0,),

                  Row(
                    children: [
                      Container(width: size.width * .3,
                        child: Text(
                          getTranslated(context, "price"),
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                      Container(width: size.width * .3,
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: TextFormField(
                          //initialValue: selectedPackage.callNum.toString(),
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                         enableInteractiveSelection: true,
                          style: GoogleFonts.cairo(
                            fontSize: 14.0,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                            border: InputBorder.none,
                            hintText: getTranslated(context, "price"),
                            hintStyle: GoogleFonts.cairo(
                              fontSize: 14.0,
                              color: Colors.black54,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                            ),
                            counterStyle: GoogleFonts.cairo(
                              fontSize: 12.5,
                              color: Colors.black54,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0,),
                  Row(
                    children: [
                      Checkbox(
                        value: activeValue,
                        onChanged: (value) {
                          setState(() {
                            activeValue = !activeValue;
                          });
                        },
                      ),
                      Text(
                        getTranslated(context, "active"),
                        style: GoogleFonts.cairo(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        child: FlatButton(
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () {
                            setState(() {
                              load = false;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            getTranslated(context, 'cancel'),
                            style: GoogleFonts.cairo(
                              color: Colors.black87,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      saving ? CircularProgressIndicator() : Container(
                        width: 50.0,
                        child: FlatButton(
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () async {
                            setState(() {
                              saving = true;
                            });
                            await FirebaseFirestore.instance.collection(
                                Paths.packagesPath).doc(selectedPackage.Id).set({
                              'price': int.parse(priceController.text),
                              'discount': int.parse(discountController.text),
                              'callNum': int.parse(callNumController.text),
                              'consultUid': widget.user.uid,
                              'Id': selectedPackage.Id,
                              'active': activeValue,
                            }, SetOptions(merge: true));
                            getConsultPackages();
                            setState(() {
                              saving = false;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            getTranslated(context, 'save'),
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
              );
          })
      ), barrierDismissible: false,
      context: context,
    );
  }
  startChat() async
  {
    setState(() {
      chating=true;
    });
    QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection("SupportList")
        .where( 'userUid', isEqualTo: widget.user.uid, ).limit(1).get();
    if(querySnapshot!=null&&querySnapshot.docs.length!=0)
    {
      var item=SupportList.fromFirestore(querySnapshot.docs[0]);
      setState(() {
        load=false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportMessageScreen(
            item: item,
             user:widget.loggedUser), ),);
      setState(() {
        chating=false;
      });

    }
    else
    {
      setState(() {
        chating=false;
      });
    }
  }
}
