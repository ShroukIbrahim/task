// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/consultPackage.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/promoCode.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/reviews_screen.dart';
import 'package:grocery_store/screens/searchScreen.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../main.dart';
import '../models/consultDays.dart';
import 'account_screen.dart';
import 'bioDetailsScreen.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hijri_picker/hijri_picker.dart';
class ConsultantDetailsScreen extends StatefulWidget {
  final GroceryUser consultant;
  final GroceryUser loggedUser;
  final String theme;
  const ConsultantDetailsScreen({Key key, this.consultant, this.loggedUser, this.theme}) : super(key: key);
  @override
  _ConsultantDetailsScreenState createState() => _ConsultantDetailsScreenState();
}

class _ConsultantDetailsScreenState extends State<ConsultantDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> todayAppointmentList=[];
  String languages="", workDays="",workDaysValue="",from="",to="",lang="";
  final TextEditingController controller = TextEditingController();
  final TextEditingController searchController = new TextEditingController();
  GroceryUser user;
  int currentNumber=0;
  AccountBloc accountBloc;
  List <consultPackage>packages=[];
  List<ConsultReview>reviews=[];
  int _selectedIndex,reviewLength=0,localFrom,localTo;
  int selectedCard = -1;
  bool first=true,showPayView=false,load=false,valid=false,checkPromo=false,loadReviews=true,loadPackage=true,fromBalance=false;
  bool hijri=false, gregorian=true,loadDates=true;
  num _stackIndex = 1;
  String initialUrl = '',userImage,orderId,userName="dreamUser",time=DateFormat('yyyy-MM-dd').format(DateTime.now()),dateText="",
  displayedTime=DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  consultPackage package;
  Orders order;
  bool avaliable=false,activeValue=false,applePay=false,googlePay=false,firstOpen=true;
  DateTime  selectedDate = DateTime.now(),date;
  DateTime appointmentTime;
  PromoCode promo;
  String promoCodeId;
  dynamic price,discount=0;
  Size size;
  @override
  void initState() {
    super.initState();
    user=widget.loggedUser;
    getConsultReviews();
    getConsultPackages();
    cleanConsultDays();
    accountBloc = BlocProvider.of<AccountBloc>(context);

    if(user!=null)
    {
      getNumber();
      accountBloc.add(GetAccountDetailsEvent(user.uid));
    }
    localFrom= DateTime.parse(widget.consultant.fromUtc).toLocal().hour;
    localTo=DateTime.parse(widget.consultant.toUtc).toLocal().hour;
    if(localTo==0)
      localTo=24;
    if(widget.consultant.languages.length>0)
      widget.consultant.languages.forEach((element) { languages=languages+" "+element;});
    if(widget.consultant.workTimes.length>0)
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
    if(widget.consultant.workTimes.length>0)
    {
      if( localTo==12)
        to="12 PM";
      else if( localTo==0||localTo==24)
        to="12 AM";
      else if( localTo>12)
        to=((localTo)-12).toString()+" PM";
      else
        to=(localTo).toString()+" AM";

    }
    accountBloc.listen((state) {
      print(state);
      if (state is GetAccountDetailsCompletedState) {
        user = state.user;
      }
    });
  }
  Future<void> getNumber() async {
    try{
      print("getNumbera1");
      setState(() {
        load=true;
      });
      await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .where( 'user.uid', isEqualTo: user.uid,)
          .where( 'consult.uid', isEqualTo: widget.consultant.uid,)
          .where( 'orderStatus', isEqualTo: (widget.consultant.consultType=="perfect"||widget.consultant.consultType=="jeras")?'completed':'open')
          .get().then((value) async {
        if(value!=null&&value.docs!=null&&value.docs.length>0) {
          var order2=Orders.fromFirestore(value.docs[0]);
          setState(() {
              order=order2;
            });
          if(widget.consultant.consultType=="vocal"||widget.consultant.consultType=="glorified"){
            await FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .where( 'orderId', isEqualTo: order.orderId,)
                .get().then((value) async {
              if(value.docs.length>0) {
                  setState(() {
                  currentNumber =order.packageCallNum - value.docs.length;
                });
              }
              else {
                  setState(() {
                    currentNumber =order.packageCallNum;
               });
              }
            }).catchError((err) {
              errorLog("getNumber1",err.toString());
                setState(() {
                load=false;
              });
            });
          }
          else
            {
              await FirebaseFirestore.instance
                  .collection(Paths.forEverAppointmentsPath)
                  .where( 'orderId', isEqualTo: order.orderId,)
                  .get().then((value) async {
                if(value.docs.length>0) {
                    setState(() {
                    currentNumber =order.packageCallNum - value.docs.length;
                  });
                }
                else {
                    setState(() {
                      currentNumber =order.packageCallNum;
                  });
                }
              }).catchError((err) {
                errorLog("getNumber1",err.toString());
                  setState(() {
                  load=false;
                });
              });
            }
         
        }
        else {
           setState(() {
           currentNumber=0;
           order=null;
         });
        }
          setState(() {
          load=false;
        });
      }).catchError((err) {
        errorLog("getNumber",err.toString());
          setState(() {
          load=false;
        });
      });

    }catch(e) {
      errorLog("getNumber",e.toString());
        setState(() {
        load=false;
        currentNumber=0;
        order=null;
      });
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
      'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
      'screen': "ConsultantDetailsScreen",
      'function': function,
    });
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
  getConsultPackages() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.packagesPath)
          .where('consultUid', isEqualTo:widget.consultant.uid )
          .where('active', isEqualTo: true )
          .orderBy("callNum", descending: false)
          .get();
      var packageList = List<consultPackage>.from(
        querySnapshot.docs.map(
              (snapshot) => consultPackage.fromFirestore(snapshot),
        ),
      );
      setState(() {
        packages=packageList;
        loadPackage=false;
      });
    } catch (e) {
      setState(() {
        loadPackage=false;
      });
      errorLog("getConsultPackages",e.toString());
    }
  }
  getConsultReviews() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.consultReviewsPath)
          .where('consultUid', isEqualTo:widget.consultant.uid )
          .limit(3)
          .orderBy("reviewTime", descending: true)
          .get();
      var reviewsList = List<ConsultReview>.from(
        querySnapshot.docs.map(
              (snapshot) => ConsultReview.fromFirestore(snapshot),
        ),
      );
      setState(() {
        reviewLength=reviewsList.length;
        reviews=reviewsList;
        loadReviews=false;
      });

    } catch (e) {
      setState(() {
        loadReviews=false;
      });
      errorLog("getConsultReviews",e.toString());

    }
  }
  _onSelected(int index) {
    setState(() {
      _selectedIndex = index;
      package=packages[index];
    });
  }
  @override
  Widget build(BuildContext context) {
    String dayNow=DateTime.now().weekday.toString();
    int timeNow=DateTime.now().hour;
    if(widget.consultant.workDays.contains(dayNow))
    {
      if (localFrom<=timeNow&&localTo>timeNow) {
        avaliable=true;
      }
    }
    lang=getTranslated(context, "lang");
    if(user!=null&&user.photoUrl!=null&&user.photoUrl!="")
      setState(() {
        userImage=user.photoUrl;
      });
    if(first&&widget.consultant.workDays.length>0) {
      workDays="";
      if(widget.consultant.workDays.contains("1"))
      {
        workDays=workDays+getTranslated(context,"monday")+",";
      }
      if(widget.consultant.workDays.contains("2"))
      {
        workDays=workDays+getTranslated(context,"tuesday")+",";
      }
      if(widget.consultant.workDays.contains("3"))
      {
        workDays=workDays+getTranslated(context,"wednesday")+",";
      }
      if(widget.consultant.workDays.contains("4"))
      {
        workDays=workDays+getTranslated(context,"thursday")+",";
      }
      if(widget.consultant.workDays.contains("5"))
      {
        workDays=workDays+getTranslated(context,"friday")+",";
      }
      if(widget.consultant.workDays.contains("6"))
      {
        workDays=workDays+getTranslated(context,"saturday")+",";
      }
      if(widget.consultant.workDays.contains("7"))
      {
        workDays=workDays+getTranslated(context,"sunday")+",";
      }
      setState(() {
        workDaysValue="";
        workDaysValue=workDays;
        first=false;
      });
    }
     size = MediaQuery.of(context).size;
    return Scaffold(
      key:_scaffoldKey,
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
              height: size.height*.25,
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
                      InkWell(
                        splashColor:
                        Colors.white.withOpacity(0.5),
                        onTap: () {
                          if(widget.loggedUser!=null&&widget.loggedUser.userType=="CONSULTANT")
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountScreen(user:widget.loggedUser,firstLogged:false), ),);
                          else if(widget.loggedUser!=null&&widget.loggedUser.userType!="CONSULTANT")
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserAccountScreen(user:widget.loggedUser,firstLogged:false), ),);
                          else{}
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: userImage==null ?//whiteLogo.png
                          Image.asset(widget.theme=="light"?
                          'assets/applicationIcons/whiteLogo.png':'assets/applicationIcons/whiteLogo.png',
                            width: 50,
                            height: 50,
                          )
                              :ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: FadeInImage.assetNetwork(
                              placeholder:
                              widget.theme=="light"?
                              'assets/applicationIcons/whiteLogo.png':'assets/applicationIcons/whiteLogo.png',
                              placeholderScale: 0.5,
                              imageErrorBuilder:(context, error, stackTrace) => Icon(
                                Icons.person,color:Colors.black,
                                size: 50.0,
                              ),

                              image: userImage,
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

                      Container(
                        height: 38.0,
                        width: size.width*.55,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 1.0, vertical: 0.0),
                        decoration: BoxDecoration(
                          color: widget.theme=="light"?Colors.white:Color(0xff3f3f3f),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: TextField(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchScreen(loggedUser:user,), ),  );
                          },
                          keyboardType: TextInputType.text,
                          controller: searchController,
                          textInputAction: TextInputAction.search,
                          enableInteractiveSelection: true,
                          readOnly:true,
                          style: GoogleFonts.cairo(
                            fontSize: 14.5,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).primaryColor,
                              size: 25.0,
                            ),
                            border: InputBorder.none,
                            //hintText: getTranslated(context, "search"),
                            hintStyle: GoogleFonts.cairo(
                              fontSize: 14.5,
                              color: Theme.of(context).primaryColor,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.asset(widget.theme=="light"?
                        'assets/applicationIcons/Iconly-Curved-Category.png' : 'assets/applicationIcons/dashbord.png',
                          width: 30,
                          height: 30,
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
                  SizedBox(height: 25,),
                  Center(
                    child: Container(width: size.width*.9,
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
                              color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
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
                                      color: widget.theme=="light"?Colors.white:Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>BioDetailsScreen(consult:widget.consultant),
                              ),
                            );
                          },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: RichText(
                                text: TextSpan(
                                  text: widget.consultant.bio.length>165?widget.consultant.bio.substring(0,165):widget.consultant.bio,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.0,
                                    color:AppColors.black,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "  "+getTranslated(context, "more"),
                                        style: GoogleFonts.cairo(
                                          color: AppColors.brown,
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.bold,)),
                                  ],
                                ),
                              )

                            ),
                          ),
                        ],
                      ),),
                  ),
                  SizedBox(height: 20,),
                  Center(
                      child:  Container(height: 250,width: size.width*.9,
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
                                color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                borderRadius: BorderRadius.circular(25.0),

                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      getTranslated(context, "Reviews"),
                                      style: GoogleFonts.cairo(
                                        color:  widget.theme=="light"?Colors.white:Colors.white,
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
                                            builder: (context) => ReviewScreens(consult:widget.consultant ,reviewLength:reviewLength), ),  );
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward,
                                        color:  widget.theme=="light"?Colors.white:Colors.white,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                            loadReviews?Center(
                                child: CircularProgressIndicator()):SizedBox(),
                            (loadReviews==false&&reviews.length==0)?Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: <Widget>[
                                   /* Image.asset(
                                      'assets/images/cancel_order.png',
                                      width: size.width * 0.6,
                                      height: 120,
                                    ),*/
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    Text(
                                      getTranslated(context, "noReviews"),
                                      style: GoogleFonts.cairo(
                                        color: Colors.black87,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ):SizedBox(),
                            (loadReviews==false&&reviews.length>0)?ListView.separated(
                              itemCount: reviews.length>2?2:reviews.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(0),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  splashColor:
                                  Colors.red.withOpacity(0.5),
                                  onTap: () {
                                    // _onSelected(index);
                                  },
                                  child: Container(height: 90,width: size.width,
                                      padding: const EdgeInsets.only(left: 10,right: 10,top:10),
                                      color: Colors.white,child: Row(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black,width: 2),
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: reviews[index].image.isEmpty ?
                                            Icon( Icons.person,color:Colors.black,size: 45.0, )
                                                :ClipRRect( borderRadius: BorderRadius.circular(100.0),
                                              child: FadeInImage.assetNetwork(
                                                placeholder:
                                                'assets/icons/icon_person.png',
                                                placeholderScale: 0.5,
                                                imageErrorBuilder:(context, error, stackTrace) => Icon(
                                                  Icons.person,color:Colors.black,
                                                  size: 45.0,
                                                ),
                                                image: reviews[index].image,
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
                                          Padding(
                                            padding: const EdgeInsets.only(left: 2,right: 2),
                                            child: Container(width: size.width*.5,
                                              child: Column(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    reviews[index].name,
                                                    overflow:TextOverflow.ellipsis ,
                                                    style: GoogleFonts.cairo(
                                                      color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                                      fontSize: 13.0,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                    ),),
                                                  Text(
                                                    reviews[index].review,
                                                    maxLines: 2,
                                                    overflow:TextOverflow.ellipsis ,
                                                    style: GoogleFonts.cairo(
                                                      color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                                      fontSize: 13.0,
                                                      fontWeight: FontWeight.normal,
                                                      letterSpacing: 0.5,
                                                    ),),
                                                ],),
                                            ),
                                          ),
                                          Row(mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 13,
                                                color: Colors.orange,
                                              ),
                                              Text(
                                                reviews[index].rating.toStringAsFixed(1),
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.cairo(
                                                  color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],)
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Center(child: Container(color:widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,width: size.width*.8,height: 1,));
                              },
                            ):SizedBox(),

                          ],
                        ),
                      )),
                  SizedBox(height: 20,),
                  Center(
                    child: Container(height: 35,width: size.width*.5,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
                        borderRadius: BorderRadius.circular(35.0),

                      ),child:  Center(
                        child: Text(
                          getTranslated(context, "timeOfWork"),
                          style: GoogleFonts.cairo(
                            color: Colors.white,
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
                    Image.asset(widget.theme=="light"?
                    'assets/applicationIcons/Iconly-Two-tone-Calendar-1.png':'assets/applicationIcons/Iconly-Two-tone-Calendar.png',
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 5,),
                    Container(height: 70,width: size.width*.8,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(30.0),

                      ),child:  Center(
                        child: Text(
                          workDaysValue,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: GoogleFonts.cairo(
                            color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
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
                    Image.asset(widget.theme=="light"?
                    'assets/applicationIcons/Iconly-Two-tone-TimeCircle.png':'assets/applicationIcons/whiteTime.png',
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 5,),
                    Container(height: 35,width: size.width*.3,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(30.0),

                      ),child:  Center(
                        child:  Text(
                          from,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: GoogleFonts.cairo(
                            color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),),
                      ),
                    ),
                    Container(height: 35,width: size.width*.3,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(30.0),

                      ),child:  Center(
                        child:Text(
                          to,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: GoogleFonts.cairo(
                            color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
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
                    child: Container(height: 35,width: size.width*.5,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: widget.theme=="light"?Theme.of(context).primaryColor:Colors.black,
                        borderRadius: BorderRadius.circular(35.0),

                      ),child:  Center(
                        child: Text(
                          getTranslated(context, "Packages"),
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  loadPackage? Center(child: CircularProgressIndicator()):SizedBox(),
                  (loadPackage==false&&packages.length==0)?Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/images/credit_card.png',
                            width: size.width * 0.6,
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            getTranslated(context, "noPackages"),
                            style: GoogleFonts.cairo(
                              color: Colors.black87,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ):SizedBox(),
                  (loadPackage==false&&packages.length>0)?ListView.separated(
                    itemCount: packages.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(0),
                    itemBuilder: (context, index) {
                      String callsValue=getTranslated(context, "calls");
                      if(index==0&&widget.consultant.consultType=="glorified")
                        callsValue=getTranslated(context, "oneCall")+getTranslated(context, "15Minutes");
                      else  if(index==0&&widget.consultant.consultType!="glorified")
                        callsValue=getTranslated(context, "oneCall")+getTranslated(context, "60Minutes");
                      else if(packages[index].callNum==10)
                        callsValue="10"+getTranslated(context, "call");
                      else  if(packages[index].callNum==26)
                        callsValue=getTranslated(context, "month");
                      else  if(packages[index].callNum==78)
                        callsValue="3"+getTranslated(context, "months");
                      else  if(packages[index].callNum==156)
                        callsValue="6"+getTranslated(context, "months");
                      else  if(packages[index].callNum==3)
                        callsValue="3"+getTranslated(context, "calls");
                      else  if(packages[index].callNum==6)
                        callsValue="6"+getTranslated(context, "calls");
                      else
                        callsValue=packages[index].callNum.toString()+getTranslated(context, "calls");
                      return InkWell(
                        splashColor:
                        Colors.red.withOpacity(0.5),
                        onTap: () {
                          _onSelected(index);
                        },
                        child: Container(height: 50,width: size.width*.8,
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            decoration: BoxDecoration(
                              color: index==-1?Theme.of(context).primaryColor:AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(color: _selectedIndex != null && _selectedIndex == index
                                  ?AppColors.brown
                                  : AppColors.lightGrey,width: 2),

                            ),child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                              Container(width: size.width*.4,
                                child: Text(
                                  callsValue,//index==0?getTranslated(context, "oneCall"):callsValue,
                                  style: GoogleFonts.cairo(
                                    color:Theme.of(context).primaryColor,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                  ),),
                              ),

                              Container(height: 40,width: size.width*.3,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(25.0),

                                ),child:Center(
                                  child: Text(
                                    packages[index].price.toString()+"\$",
                                    style: GoogleFonts.cairo(
                                      color:  widget.theme=="light"?Colors.white:Colors.black,
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
                  ):SizedBox(),
                  SizedBox(height: 20,),
                  Center(
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(height: 35,width: size.width*.7,
                              decoration: BoxDecoration(
                                color: widget.theme=="light"?Colors.black.withOpacity(0.1):Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: TextFormField(
                                controller: controller,
                                keyboardType: TextInputType.text,
                                textAlign:TextAlign.center ,
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
                                  hintText: getTranslated(context,"enterPromoCode"),
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
                                onChanged: (text) {
                                  if(text.length==5)
                                  {
                                    calculateDiscount();
                                  }
                                  if(text.length==0)
                                  {
                                    setState(() {
                                      promo = null;
                                      promoCodeId="";
                                      checkPromo=false;
                                      valid=false;
                                      discount=0;
                                    });
                                  }
                                },
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color:valid?Colors.green:Colors.grey,
                              size: 30.0,
                            ),
                          ],
                        ),
                        Text(
                            getTranslated(context, "proText")+ discount.toString()+"%",
                            maxLines: 3,
                            overflow:TextOverflow.ellipsis ,
                            softWrap: true,
                            style: GoogleFonts.cairo(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                              color: Colors.grey,
                            ),
                          ),
                        SizedBox(height: 20,),
                        (user!=null&&currentNumber!=0)?Container(
                          height: 35,
                          width: size.width*.5,
                          decoration: BoxDecoration(
                              color: Colors.yellow[200],
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(20.0),
                                topRight: const Radius.circular(20.0),
                              )
                          ),child :Center(
                          child: Text(
                            getTranslated(context, "remainingCalls")+": "+currentNumber.toString(),
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontSize: 13.0,
                            ),
                          ),
                        ),):SizedBox(),
                        load?Center(child: CircularProgressIndicator()):
                        SizedBox(
                          height:45,
                          width: size.width * 0.8,
                          child: FlatButton(
                            onPressed: () async {
                              if(user==null)
                                Navigator.pushNamed(context, '/Register_Type');
                              else if(package==null&&currentNumber==0)
                                showSnakbar(getTranslated(context,'selectPackage'),false);
                              else if(user!=null&&currentNumber==0)
                              {
                                setState(() {
                                  load=true;
                                  price=package.price.toString();
                                  double finalPrice=double.parse(price);
                                  if(valid&&promo!=null)
                                  {
                                    price = (finalPrice - ((finalPrice * double.parse(promo.discount.toString() ) ) / 100)).toString();
                                  }
                                });
                                if(double.parse(user.balance.toString())>=double.parse(price.toString()))
                                {
                                  var newBalance=double.parse(user.balance.toString())-double.parse(price);
                                  await FirebaseFirestore.instance.collection(Paths.usersPath).doc(user.uid).set({
                                    'balance': newBalance,
                                  }, SetOptions(merge: true));

                                  setState(() {
                                    fromBalance=true;
                                    user.balance=newBalance;
                                  });
                                  updateDatabaseAfterAddingOrder(user.customerId, "userBalance");
                                }
                                else
                                {
                                  setState(() {
                                    fromBalance=false;
                                  });
                                  pay();
                                }

                              }
                             else if (widget.consultant.consultType=="perfect"||widget.consultant.consultType=="jeras")
                                {
                                  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                      .collection(Paths.appAppointments)
                                      .where( 'orderId', isEqualTo: order.orderId,)
                                      .get();
                                  if(querySnapshot!=null&&querySnapshot.docs.length>0)
                                    showSnakbar(getTranslated(context,'stillOpen'),true);
                                  else
                                    showConsultAppointmentList(size);
                                }
                              else
                                showConsultAppointmentList(size);


                            },
                            color:AppColors.brown,// Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Text(
                              (user!=null&&currentNumber!=0)?(widget.consultant.consultType=="perfect"||widget.consultant.consultType=="jeras")?getTranslated(context,"stillOpen"):getTranslated(context,"confirm")
                                  :getTranslated(context,"participation"),
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                      ],
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
          top: (size.height*.18),//140.0,
          left: 0,
          child: Center(
            child:  Container(width: size.width*.9,height: 90,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 0.0),
                    blurRadius: 5.0,
                    spreadRadius: 2.0,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
                border: Border.all(color: Colors.white,width: 1),
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20.0),
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
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white,width: 3),
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: widget.consultant.photoUrl.isEmpty ?
                                  Image.asset('assets/applicationIcons/whiteLogo.png',width: 60,height: 60,)
                                  :ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                  'assets/applicationIcons/whiteLogo.png',
                                  placeholderScale: 0.5,
                                  imageErrorBuilder:(context, error, stackTrace) => Image.asset('assets/applicationIcons/whiteLogo.png',width: 60,height: 60,),
                                  image: widget.consultant.photoUrl,
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
                                        border: Border.all(color: Colors.white,width: 2),
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
                              widget.consultant.name,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.cairo(
                                color:  widget.theme=="light"?Colors.white:Colors.black,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: widget.theme=="light"?AppColors.white:AppColors.black,
                                ),
                                Expanded(flex:2,
                                  child: Text(
                                      widget.consultant.location,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    maxLines: 1,
                                    style: GoogleFonts.cairo(
                                      color:  widget.theme=="light"?Colors.white:Colors.black,
                                      fontSize: 12.0,
                                      // fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
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
                                      size: 12,
                                      color: AppColors.yellow,
                                    ),
                                    Text(
                                      widget.consultant.rating==null?"0": widget.consultant.rating.toStringAsFixed(1),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color:  widget.theme=="light"?Colors.white:Colors.black,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 20,),
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(widget.theme=="light"?
                                    'assets/applicationIcons/greenCall.png':'assets/applicationIcons/blackCall.png',
                                      width: 12,
                                      height: 12,
                                    ),


                                    Text(
                                      widget.consultant.ordersNumbers==null?'+100':widget.consultant.ordersNumbers<100?widget.consultant.ordersNumbers.toString():widget.consultant.ordersNumbers<1000?"+100":"+1000",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color:  widget.theme=="light"?Colors.white:Colors.black,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              widget.consultant.price+"\$",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.cairo(
                                color:  AppColors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 20,),
                            Image.asset('assets/applicationIcons/v-w.png',
                              width: 15,
                              height: 15,
                            ),
                          ],),
                      ),
                    ],
                  ),

                ],
              ),


            ),
          ),
        ),
        showPayView ? Positioned(
          child: Scaffold(
            body:IndexedStack(
              index: _stackIndex,
              children: <Widget>[
                WebView(
                  initialUrl:initialUrl,
                  navigationDelegate: (NavigationRequest request) {
                    print('request.url '+request.url);
                    if(request.url.startsWith("https://www.jeras.io/app/redirect_url")){
                      print('onPageSuccess');
                      setState(() {
                        _stackIndex = 1;
                        showPayView = false;
                        var str=request.url;
                        const start = "tap_id=";
                        final startIndex = str.indexOf(start);
                        print(str.substring(startIndex + start.length, str.length));
                        String charge=str.substring(startIndex + start.length, str.length);
                        print("chargeeee11111111  "+charge);
                        payStatus(charge);
                      });
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                  onPageStarted: (url) => print("OnPagestarted " + url),
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                  onPageFinished: (url) {
                    print("onPageFinished " + url);
                    //showSnakbar(url, true);
                    setState(() => _stackIndex = 0);} ,
                ),
                Center(child: Text('Loading  ...')),
                Center(child: Text('order ...'))
              ],
            ),
          ),
        ) : Container()
      ]),
    );
  }
  void showNoNotifSnack(String text) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade500,
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

  calculateDiscount() async {
    setState(() {
      checkPromo=true;
    });
    if(controller.text!=null&&controller.text!="")
    {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.promoPath)
          .where('promoCodeStatus', isEqualTo: true)
          .where('code', isEqualTo: controller.text )
          .limit(1)
          .get();
      var codes = List<PromoCode>.from(
        querySnapshot.docs.map(
              (snapshot) => PromoCode.fromFirestore(snapshot),
        ),
      );
      if(codes.length>0) {
        print("promo3");
        setState(() {
          promo = codes[0];
          promoCodeId=promo.promoCodeId;
          checkPromo=false;
          valid=true;
          discount=promo.discount;

        });
      }else{
        setState(() {
          print("promo4");
          promo = null;
          promoCodeId="";
          checkPromo=false;
          valid=false;
          discount=0;
        });
      }
    }

  }
  pay() async {
    try{
      if(user!=null&&user.name!=null)
        userName=user.name;
      var userPhone=user.phoneNumber;
      print("payStart111");
      final uri = Uri.parse('https://api.tap.company/v2/charges');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"Bearer sk_test_4KmXWCt20xzpfeNvyOiFUY3G",
        'Connection':'keep-alive',
        'Accept-Encoding':'gzip, deflate, br'

      };
      Map<String, dynamic> body ={
        "amount": price,
        "currency": "USD",
        "threeDSecure": true,
        "save_card": true,
        "description": "Test Description",
        "statement_descriptor": "Sample",
        "metadata": {
          "udf1": "test 1",
          "udf2": "test 2"
        },
        "reference": {
          "transaction": "txn_0001",
          "order": "ord_0001"
        },
        "receipt": {
          "email": false,
          "sms": true
        },
        "customer": {
          "id": user.customerId!=null?user.customerId:'',
          "first_name":userName,
          "middle_name": ".",
          "last_name": ".",
          "email": userName+"@jeras.com",
          "phone": {"country_code": "غ",
            "number": userPhone
          }
        },
        "merchant": {
          "id": ""
        },
        "source": {
          "id": "src_all"
        },
        "post": {
          "url": "http://your_website.com/post_url"
        },
        "redirect": {
          "url": "https://www.jeras.io/app/redirect_url"
        }
      };
      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');
      var response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
      String responseBody = response.body;
      print(responseBody);
      var res = json.decode(responseBody);
      String url = res['transaction']['url'];

     // Navigator.pop(context);
      setState(() {
        initialUrl=url;
        showPayView = true;
      });
    }catch(e){
      print("xxxxx"+e.toString());
      errorLog("pay",e.toString());
      setState(() {
        showPayView=false;
        load=false;
      });
      showSnakbar(getTranslated(context, "failed"),true);
    }

  }
  payStatus(String chargeId) async {
    try{
        print("payStatusqqqq");
      final uri = Uri.parse('https://api.tap.company/v2/charges/'+chargeId);
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"Bearer sk_test_4KmXWCt20xzpfeNvyOiFUY3G",
        'Connection':'keep-alive',
        'Accept-Encoding':'gzip, deflate, br'
      };
      var response = await get(
        uri,
        headers: headers,

      );
      print(response.body);
      String responseBody = response.body;
      var res = json.decode(responseBody);
      print(res);
      String customerId=res['customer']['id'];
      customerId= customerId!=null?customerId:"";
      if(res['status']=="CAPTURED")
      {
        updateDatabaseAfterAddingOrder(customerId,"tapCompany");
      }
      else
      {
        String id = Uuid().v4();
        await FirebaseFirestore.instance.collection(Paths.errorLogPath) .doc(id).set({
          'timestamp': Timestamp.now(),
          'id': id,
          'seen': false,
          'desc': res['status'],
          'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
          'screen': "ConsultantDetailsScreen",
          'function': "payStatus",
        });
        setState(() {
          showPayView=false;
          load=false;
        });
        showSnakbar(getTranslated(context, "failed"),true);

      }
    }catch(e){
      errorLog("payStatus",e.toString());
      setState(() {
        showPayView=false;
        load=false;
      });
      showSnakbar(getTranslated(context, "failed"),true);
    }
  }
  updateDatabaseAfterAddingOrder(String customerId,String payWith) async {
    try{
      String orderId=Uuid().v4();
      DateTime dateValue=DateTime.now();
      dynamic callPrice=double.parse(price.toString())/package.callNum;
      await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(orderId).set({
        'orderStatus':(widget.consultant.consultType=="perfect"||widget.consultant.consultType=="jeras")?'completed':'open',
        'consultType':widget.consultant.consultType,
        'orderId': orderId,
        'orderTimestamp': Timestamp.now(),
        'orderTimeValue': DateTime(dateValue.year, dateValue.month, dateValue.day ).millisecondsSinceEpoch,
        'packageId': package.Id,
        'promoCodeId':promoCodeId,
        'remainingCallNum':(widget.consultant.consultType=="perfect"||widget.consultant.consultType=="jeras")?0:package.callNum,
        'packageCallNum': package.callNum,
        'answeredCallNum':0,
        'callPrice':callPrice,
        "payWith":payWith,
        "platform": Platform.isIOS ? "iOS" : "Android",
        'price':price.toString(),
        'consult': {
          'uid': widget.consultant.uid,
          'name': widget.consultant.name,
          'image': widget.consultant.photoUrl,
          'phone': widget.consultant.phoneNumber,
          'countryCode': widget.consultant.countryCode,
          'countryISOCode': widget.consultant.countryISOCode,

        },
        'user': {
          'uid': user.uid,
          'name': user.name,
          'image': user.photoUrl,
          'phone': user.phoneNumber,
          'countryCode': user.countryCode,
          'countryISOCode': user.countryISOCode,

        },
      });
      getNumber();
      //update appAnalysis
      DateTime dateOrder=DateTime.now();
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.appAnalysisPath).doc("TgWCp3B22sbkl0Nm3wLx").get();
      Map<String, dynamic> data =documentSnapshot.data();
      dynamic totalEarned=data['totalEarn'];
      int totalOrder=data['orderNum'];
      await FirebaseFirestore.instance.collection(Paths.appAnalysisPath).doc("TgWCp3B22sbkl0Nm3wLx").set({
        'orderNum': totalOrder+1,
        'totalEarn':totalEarned+double.parse(price.toString()),
      }, SetOptions(merge: true));
      
      await FirebaseFirestore.instance.collection(Paths.orderAnalysisPath).doc(Uuid().v4()).set({
        'time': DateTime(dateOrder.year, dateOrder.month, dateOrder.day ).millisecondsSinceEpoch,
        'price':double.parse(price.toString()),
      }, SetOptions(merge: true));



      //update user order numbers
      int userOrdersNumbers=1;
      dynamic payedBalance=double.parse(price.toString());
      if(user.ordersNumbers!=null)
        userOrdersNumbers=user.ordersNumbers+1;
      if(user.payedBalance!=null)
        payedBalance=user.payedBalance+payedBalance;

      await FirebaseFirestore.instance.collection(Paths.usersPath).doc(user.uid).set({
        'ordersNumbers': userOrdersNumbers,
        'payedBalance':payedBalance,
        'customerId':customerId,
        'preferredPaymentMethod':"tapCompany"
      }, SetOptions(merge: true));
      accountBloc.add(GetAccountDetailsEvent(user.uid));
//======update number ofuse of promocode
      if(promo!=null)
      {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.promoPath).doc(promo.promoCodeId).get();
        Map<String, dynamic> data = documentSnapshot.data();
        int usedNumber = data['usedNumber'];
        await FirebaseFirestore.instance.collection(Paths.promoPath).doc(
            promo.promoCodeId).set({
          'usedNumber': usedNumber + 1,
        }, SetOptions(merge: true));
      }
      //registerAppointment();
      showConsultAppointmentList(size);
    }catch(e){
      errorLog("updateDatabaseAfterAddingOrder", e.toString());
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
  Future<void>addAppointment(DateTime date)async {
    try {
      setState(() {
        load=true;
        currentNumber=(widget.consultant.consultType=="perfect"||widget.consultant.consultType=="jeras")?currentNumber:currentNumber-1;
      });

      date = date.toUtc();
      String appointmentId = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(
          appointmentId).set({
        'appointmentId': appointmentId,
        'appointmentStatus': 'new',
        'remainingCallNum':currentNumber,
        'type':'valid',
        "consultType":widget.consultant.consultType,
        'lessonTime':widget.consultant.consultType=="glorified"?15:60,
        'timestamp': DateTime.now().toUtc(),
        'timeValue': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
        'secondValue': DateTime(
            date.year,
            date.month,
            date.day,
            date.hour,
            date.minute,
            date.second,
            date.millisecond).millisecondsSinceEpoch,
        'appointmentTimestamp': DateTime(
            date.year,
            date.month,
            date.day,
            date.hour,
            date.minute,
            date.second,
            date.millisecond),
        'utcTime': date.toString(),
        'consultChat': 0,
        'userChat': 0,
        'isUtc': true,
        'orderId': order.orderId,
        'callPrice': order.callPrice,
        'consult': {
          'uid': widget.consultant.uid,
          'name': widget.consultant.name,
          'image': widget.consultant.photoUrl,
          'phone': widget.consultant.phoneNumber,
          'countryCode': widget.consultant.countryCode,
          'countryISOCode': widget.consultant.countryISOCode,
        },
        'user': {
          'uid': user.uid,
          'name': user.name,
          'image': user.photoUrl,
          'phone': user.phoneNumber,
          'countryCode': user.countryCode,
          'countryISOCode': user.countryISOCode,

        },
        'date': {
          'day': date.day,
          'month': date.month,
          'year': date.year,
        },
        'time': {
          'hour': date.hour,
          'minute': date.minute,
        },
      }).then((value) async {
        await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(
            order.orderId).set({
          'orderStatus': (widget.consultant.consultType=="perfect"||widget.consultant.consultType=="jeras")?"completed":currentNumber <= 0 ? "completed" : "open",
          'remainingCallNum': currentNumber,
        }, SetOptions(merge: true)).then((value) async {
          getNumber();
          setState(() {
            load=false;
          });
        }).catchError((err) {
        });
      }).catchError((err) {
      });



//========================
      todayAppointmentList.removeAt(selectedCard);
      if(widget.consultant.consultType=="glorified"||widget.consultant.consultType=="vocal")
        {
          await FirebaseFirestore.instance.collection(Paths.consultDaysPath).doc(time+"-"+widget.consultant.uid).set({
            'todayAppointmentList': todayAppointmentList,
          }, SetOptions(merge: true));
        }
      else
        {
         setState(() {
           widget.consultant.consultOpenAppointmentDates==null? widget.consultant.consultOpenAppointmentDates=[date.hour.toString()+":"+date.minute.toString()]:
           widget.consultant.consultOpenAppointmentDates.add(date.hour.toString()+":"+date.minute.toString());
         });
          await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.consultant.uid).set({
            'consultOpenAppointmentDates': widget.consultant.consultOpenAppointmentDates,
          }, SetOptions(merge: true));
        }



      setState(() {
        load = false;
        selectedCard=-1;
      });
      Navigator.pop(context);
      appointmentDialog(MediaQuery
          .of(context)
          .size, date);
    }catch(e)  {
        String id = Uuid().v4();
        await FirebaseFirestore.instance.collection(Paths.errorLogPath).doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'payUrl':initialUrl,
        'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "addAppointment",
        });
        setState(() {
        showPayView=false;
        load=false;
        });
        // Navigator.pop(context);
        showSnakbar(getTranslated(context, "failed"),true);
        }
  }
  appointmentDialog(Size size,DateTime date) {
    // date=DateTime.parse(date.toString()).toLocal();
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
              getTranslated(context, "appointments"),
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
              getTranslated(context, "appointmentRegister"),
              style: GoogleFonts.cairo(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            Text(
              // date.toString(),
              // DateTime.parse(date.toString()).toLocal().toString(),
              '${new DateFormat('dd MMM yyyy, hh:mm').format(DateTime.parse(date.toString()).toLocal())}',
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
                    setState(() {
                      load=false;
                    });
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
  showConsultAppointmentList(Size size) async {
    try{
      setState(() {
        load=true;
        loadDates=true;
        dateText=getTranslated(context, "load");
        todayAppointmentList=[];
      });
      //=========
      if(widget.consultant.consultType=="glorified"||widget.consultant.consultType=="vocal")
      getDate();
      else
        getAvaliableDates();
      //===========
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
            return  Container(height: size.height*.60,width: size.width,
              child: ListView(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, "selectAppointment"),
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: AppColors.pink,
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.white.withOpacity(0.5),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pop(context);

                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          width: 38.0,
                          height: 35.0,
                          child: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        splashColor: AppColors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            displayedTime=DateFormat('yyyy-MM-dd').format(DateTime.now());
                            selectedDate=DateTime.now();
                            time=DateFormat('yyyy-MM-dd').format(DateTime.now());
                            gregorian = true;
                            hijri = false;
                          });
                        },
                        child: Container(
                          height: 20,
                          width: size.width * .3,
                          decoration: BoxDecoration(
                            color: gregorian? Theme.of(context).primaryColor
                                : AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "gregorian"),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: gregorian? Colors.white
                                    :Theme.of(context).primaryColor,
                                fontSize: 9.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox( width: 5.0,),
                      InkWell(
                        splashColor: AppColors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            displayedTime=HijriCalendar.now().toString();
                            selectedDate=DateTime.now();
                            time=DateFormat('yyyy-MM-dd').format(DateTime.now());
                            gregorian = false;
                            hijri = true;
                          });
                        },
                        child: Container(
                          height: 20,
                          width: size.width * .3,
                          decoration: BoxDecoration(
                            color: hijri? Theme.of(context).primaryColor
                                : AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "hijri"),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: hijri? Colors.white
                                    :Theme.of(context).primaryColor,
                                fontSize: 9.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(height: 25,//width: size.width*.60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 0.0),
                          blurRadius: 1.0,
                          spreadRadius: 1.0,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5,right: 5),
                      child:   InkWell(
                        splashColor:
                        Colors.white.withOpacity(0.5),
                        onTap: () async {
                          if(hijri)
                            _selectHijriDate(context);
                          else
                            _selectDate(context);
                        },
                        child: Row(
                          children: [
                            Expanded(flex:2,
                              child: Text(
                                displayedTime,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  color:Theme.of(context).primaryColor,
                                  fontSize: 11.0,
                                ),
                              ),
                            ),
                            Icon( Icons.date_range,size:20,
                              color: AppColors.pink,),
                          ],
                        ),
                      ),
                    ),

                  ),
                  SizedBox( height: 10.0,),
                  (loadDates==false&&todayAppointmentList.length>0)?
                  GridView.count(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    crossAxisCount: 3,
                    children: new List<Widget>.generate(todayAppointmentList.length, (index) {
                      String  minues="00", d="Am",finalTime="";
                      if(DateTime.parse(todayAppointmentList[index]).toLocal().minute!=0)
                        minues=DateTime.parse(todayAppointmentList[index]).toLocal().minute.toString();
                      if(DateTime.parse(todayAppointmentList[index]).toLocal().hour>12)
                        finalTime=((DateTime.parse(todayAppointmentList[index]).toLocal().hour)-12).toString()+":"+minues+"Pm";
                      else
                        finalTime=DateTime.parse(todayAppointmentList[index]).toLocal().hour.toString()+":"+minues+"Am";
                      return   InkWell(
                        splashColor:
                        Colors.purple.withOpacity(0.5),
                        onTap: () async {
                          print("selectedindex"+index.toString());
                          setState(() {
                            selectedCard=index;
                          });
                            addAppointment(DateTime.parse(todayAppointmentList[index]).toLocal());
                        },
                        child: selectedCard == index?Center(child: CircularProgressIndicator()):Card(
                            color: AppColors.pink,
                            child: new Center(
                              child: new Text('$finalTime', style: GoogleFonts.cairo(
                                color:Colors.white,
                                fontSize: 11.0,
                              ),),
                            )
                        ),
                      );
                    }),
                  )
                      :Column(mainAxisAlignment: MainAxisAlignment.end,crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10,),
                        loadDates?CircularProgressIndicator():SizedBox(),
                        Text(
                          dateText,
                          style: GoogleFonts.cairo(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                  ),
                ],
              ),
            );
          }),

        ), barrierDismissible: false,
        context: context,
      );
    } catch(e){
      print("startnew12ddd"+e.toString());
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath) .doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "showConsultAppointmentList",
      });
    }
  }
  getDate() async {
    try{
      if(DateTime(selectedDate.year, selectedDate.month, selectedDate.day).isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))||(!widget.consultant.workDays.contains(selectedDate.weekday.toString())))
        setState(() {
          loadDates=false;
          todayAppointmentList=[];
          dateText=getTranslated(context,"selectData");
        });
      else  {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .where( 'consult.uid', isEqualTo: widget.consultant.uid,)
            .where( 'date.day', isEqualTo: selectedDate.day,)
            .where( 'date.month', isEqualTo: selectedDate.month,)
            .where( 'date.year', isEqualTo: selectedDate.year,)
            .get();
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.consultDaysPath).doc(time+"-"+widget.consultant.uid).get();
        if(querySnapshot.docs.length>0&&documentSnapshot!=null){
          ConsultDays consultDays = ConsultDays.fromFirestore(documentSnapshot);
          setState(() {
            loadDates=false;
            todayAppointmentList=consultDays.todayAppointmentList;
            if(todayAppointmentList.length==0)
              dateText=getTranslated(context,"noAppointment");
          });
        }
        else {
          var from = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,localFrom);
          var to = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,localTo);
          var ttt=(to.difference(from).inHours).round();
          List<dynamic> appointmentList=[];
          var lessonTime=widget.consultant.consultType=="glorified"?4:1;
          var lessonMintes=widget.consultant.consultType=="glorified"?15:60;
          for(int start=0;start<ttt*lessonTime;start++)
          {
            if(from.add(Duration( minutes: start*lessonMintes)).isAfter(DateTime.now())) {
              var value=from.add(Duration( minutes: start*lessonMintes)).toUtc().toString();
              appointmentList.add(value);
            }
          }
          await FirebaseFirestore.instance.collection(Paths.consultDaysPath).doc(time+"-"+widget.consultant.uid).set({
            'id':time+"-"+widget.consultant.uid,
            'day': time,
            'date': DateTime(selectedDate.year, selectedDate.month, selectedDate.day).millisecondsSinceEpoch,
            'consultUid':widget.consultant.uid,
            'todayAppointmentList': appointmentList,
          });
          setState(() {
            loadDates=false;
            todayAppointmentList=appointmentList;
          });
        }
      }
    }catch(e){
      print("startnew12ddd"+e.toString());
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath) .doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "getDate",
      });
    }
  }
  getAvaliableDates() async {
    try{
      if(DateTime(selectedDate.year, selectedDate.month, selectedDate.day).isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))||(!widget.consultant.workDays.contains(selectedDate.weekday.toString())))
        setState(() {
          loadDates=false;
          todayAppointmentList=[];
          dateText=getTranslated(context,"selectData");
        });
      else  {
        List<dynamic> consultOpenAppointmentDates=widget.consultant.consultOpenAppointmentDates;
        var from = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,localFrom);
        var to = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,localTo);
        var ttt=(to.difference(from).inHours).round();
        List<dynamic> appointmentList=[];
        var lessonTime=1;
        var lessonMintes=60;
        for(int start=0;start<ttt*lessonTime;start++)
        {
          if(from.add(Duration( minutes: start*lessonMintes)).isAfter(DateTime.now())) {
            var value=from.add(Duration( minutes: start*lessonMintes)).toUtc().toString();
            var hmTime=from.add(Duration( minutes: start*lessonMintes)).toUtc().hour.toString()+":"+from.add(Duration( minutes: start*lessonMintes)).toUtc().minute.toString();
            if(consultOpenAppointmentDates.contains(hmTime)==false)
               appointmentList.add(value);
          }
        }
        setState(() {
          loadDates=false;
          todayAppointmentList=appointmentList;
          if(todayAppointmentList.length==0)
            dateText=getTranslated(context,"noAppointment");
        });

      }
    }catch(e){
      print("startnew12ddd"+e.toString());
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath) .doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "getAvaliableDates",
      });
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    try{
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          time = DateFormat('yyyy-MM-dd').format(picked);
          displayedTime=time;
          loadDates=true;
          todayAppointmentList=[];
          dateText=getTranslated(context,"load");
        });
        if(widget.consultant.consultType=="glorified"||widget.consultant.consultType=="vocal")
          getDate();
        else
          getAvaliableDates();
      }
    }catch(e){
      print("startnew12ddd"+e.toString());
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath) .doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "_selectDate",
      });
    }
  }
  Future<Null> _selectHijriDate(BuildContext context) async {
    try{
      final HijriCalendar picked = await showHijriDatePicker(
        context: context,
        initialDate: new HijriCalendar.now(),
        lastDate: new HijriCalendar()
          ..hYear = 1445
          ..hMonth = 9
          ..hDay = 25,
        firstDate: new HijriCalendar()
          ..hYear = 1438
          ..hMonth = 12
          ..hDay = 25,
        initialDatePickerMode: DatePickerMode.day,
      );
      if (picked != null) {
        setState(() {
          selectedDate = HijriCalendar().hijriToGregorian( picked.hYear, picked.hMonth, picked.hDay);
          time = DateFormat('yyyy-MM-dd').format(selectedDate);
          displayedTime = picked.toString();
          loadDates = true;
          todayAppointmentList = [];
          dateText = getTranslated(context, "load");
        });
        if(widget.consultant.consultType=="glorified"||widget.consultant.consultType=="vocal")
          getDate();
        else
          getAvaliableDates();
      }
    }catch(e){
      print("startnew12ddd"+e.toString());
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath) .doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "_selectHijriDate",
      });
    }
  }
  cleanConsultDays() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.consultDaysPath)
          .where('date', isLessThan:DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch)
          .where('consultUid', isEqualTo: widget.consultant.uid )
          .get();
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance.collection(Paths.consultDaysPath).doc(doc.id).delete();
      }

    } catch (e) {
      print("hhhhhh"+e.toString());
    }
  }
}
