/*
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
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/consultPackage.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/promoCode.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/screens/reviews_screen.dart';
import 'package:grocery_store/screens/searchScreen.dart';
import 'package:grocery_store/screens/sign_up_screen.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:grocery_store/widget/confirmDialog.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:http/http.dart';
import 'package:pay/pay.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../main.dart';
import 'account_screen.dart';
import 'completeUserProfile.dart';
import 'dashboard.dart';
import 'notification_screen.dart';

class ConsultantDetailsScreen extends StatefulWidget {
  final GroceryUser consultant;
  final GroceryUser loggedUser;
  final String theme;
  const ConsultantDetailsScreen({Key key, this.consultant, this.loggedUser, this.theme}) : super(key: key);
  @override
  _ConsultantDetailsScreenState createState() => _ConsultantDetailsScreenState();
}
Pay _payClient = Pay.withAssets([
  'applepay.json',
  'gpay.json'
]);
class _ConsultantDetailsScreenState extends State<ConsultantDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  NotificationBloc notificationBloc;
  UserNotification userNotification;
  String languages="", workDays="",workDaysValue="",from="",to="",lang="",payMethod;
  final TextEditingController controller = TextEditingController();
  final TextEditingController searchController = new TextEditingController();
  GroceryUser user;
  int currentNumber=0;
  int selectedCard;
  AccountBloc accountBloc;
  List <consultPackage>packages=[];
  List<ConsultReview>reviews=[];
  int _selectedIndex,reviewLength=0;
  bool first=true,showPayView=false,load=false,valid=false,checkPromo=false,loadReviews=true,loadPackage=true;
  num _stackIndex = 1;
  String initialUrl = '',userImage,orderId;
  consultPackage package;
  Orders order;
  bool avaliable=false,activeValue=false,applePay=false,googlePay=false,firstOpen=true;
  DateTime _now = DateTime.now();
  PromoCode promo;
  String promoCodeId;
  dynamic price,discount=0;
  @override
  void initState() {
    super.initState();
    selectedCard=0;
    user=widget.loggedUser;
    if(user!=null)
      payMethod=user.preferredPaymentMethod;
    checkAvaliable();
    getConsultReviews();
    getConsultPackages();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    */
/* if(firstOpen){
      accountBloc.add(GetConsultReviewsEvent(widget.consultant.uid));
      accountBloc.add(GetConsultPackagesEvent(widget.consultant.uid));
      firstOpen=false;
    }*//*


    notificationBloc = BlocProvider.of<NotificationBloc>(context);

    if((user!=null&&user.userConsultIds!=null&&user.userConsultIds.contains(widget.consultant.uid)))
    {
      getnumber();
    }

    if(widget.consultant.languages.length>0)
      widget.consultant.languages.forEach((element) { languages=languages+" "+element;});
    if(widget.consultant.workTimes.length>0)
    {
      if( int.parse(widget.consultant.workTimes[0].from)>12)
        from=(int.parse(widget.consultant.workTimes[0].from)-12).toString()+" Pm";
      else
        from=widget.consultant.workTimes[0].from+" Am";

    }
    if(widget.consultant.workTimes.length>0)
    {
      if( int.parse(widget.consultant.workTimes[0].to)>12)
        to=(int.parse(widget.consultant.workTimes[0].to)-12).toString()+" Pm";
      else
        to=widget.consultant.workTimes[0].to+" Am";

    }

    accountBloc.listen((state) {
      print(state);
      if (state is GetAccountDetailsCompletedState) {
        print("usernowdetails " + state.user.uid);
        user = state.user;
        if((user!=null&&user.userConsultIds!=null&&user.userConsultIds.contains(widget.consultant.uid)))
        {
          getnumber();
        }
        if(mounted)
          setState(() {
            load=false;
          });
      }

    });
  }
  Future<void> getnumber() async {
    print("callfffff");
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .where( 'user.uid', isEqualTo: user.uid,)
          .where( 'consult.uid', isEqualTo: widget.consultant.uid,)//
          .where( 'orderStatus', isEqualTo: "open",)
          .get();
      if(querySnapshot.docs.length>0)
      {
        order=Orders.fromFirestore(querySnapshot.docs[0]);
        setState(() {
          currentNumber=order.remainingCallNum;
        });}

    }catch(e){
      print("getnumbererror"+e.toString());
    }
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
  checkAvaliable() async {
    print("checkAvaliable");
    if(user!=null&&user.profileCompleted==false&&user.userType!="CONSULTANT") {
      {
        print("profileCompleted3");
        Navigator.push( context, MaterialPageRoute(
          builder: (context) => CompleteUserProfileScreen(user:user), ),);}
    }

    else
    {
    }
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
        reviews=reviewsList;
        loadReviews=false;
      });

    } catch (e) {
      setState(() {
        loadReviews=false;
      });
    }
  }
  _onSelected(int index) {
    // setState(() => _selectedIndex = index);
    setState(() {
      _selectedIndex = index;
      package=packages[index];
      // price=package.price.toString();

    });
  }
  @override
  Widget build(BuildContext context) {
    _payClient.userCanPay(PayProvider.apple_pay).then((value) {
      if(value==true)//&&user!=null&&user.preferredPaymentMethod=="applePay")
        setState(() {
          applePay=true;
        });
    });
    _payClient.userCanPay(PayProvider.google_pay).then((value) {
      if(value==true)//&&user!=null&&user.preferredPaymentMethod=="googlePay")
        setState(() {
          googlePay=true;
        });
    });
    String dayNow=_now.weekday.toString();
    int timeNow=_now.hour;
    if(widget.consultant.workDays.contains(dayNow))
    {
      if (int.parse(widget.consultant.workTimes[0].from )<=timeNow&&int.parse(widget.consultant.workTimes[0].to )>=timeNow) {
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
                          height: 60,
                          width: 60,
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
                      */
/* user == null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.white.withOpacity(0.5),
                                onTap: () {
                                  print('Notificationsssssss');
                                  showNoNotifSnack(getTranslated(context, "noNotification"));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  width: 38.0,
                                  height: 35.0,
                                  child: Image.asset(
                                    widget.theme == "light"
                                        ? 'assets/applicationIcons/Iconly-Two-tone-Notification.png'
                                        : 'assets/applicationIcons/Iconly-Two-tone-Notification.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ),
                            ),
                          )
                              : BlocBuilder(
                            bloc: notificationBloc,
                            buildWhen: (previous, current) {
                              if (current
                              is GetAllNotificationsInProgressState ||
                                  current is GetAllNotificationsFailedState ||
                                  current
                                  is GetAllNotificationsCompletedState ||
                                  current is GetNotificationsUpdateState) {
                                return true;
                              }
                              return false;
                            },
                            builder: (context, state) {
                              print("nnnnnn");
                              print(state);
                              if (state is GetAllNotificationsInProgressState) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor:
                                      Colors.white.withOpacity(0.5),
                                      onTap: () {
                                        print('Notificationllllllll');
                                        showNoNotifSnack(getTranslated(
                                            context, "noNotification"));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        width: 38.0,
                                        height: 35.0,
                                        child: Image.asset(
                                          widget.theme == "light"
                                              ? 'assets/applicationIcons/Iconly-Two-tone-Notification.png'
                                              : 'assets/applicationIcons/Iconly-Two-tone-Notification.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (state is GetNotificationsUpdateState) {
                                if (state.userNotification != null) {
                                  if (state.userNotification.notifications
                                      .length ==
                                      0) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          splashColor:
                                          Colors.white.withOpacity(0.5),
                                          onTap: () {
                                            print('Notificationddddd');
                                            showNoNotifSnack(getTranslated(
                                                context, "noNotification"));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            width: 38.0,
                                            height: 35.0,
                                            child: Image.asset(
                                              widget.theme == "light"
                                                  ? 'assets/applicationIcons/Iconly-Two-tone-Notification.png'
                                                  : 'assets/applicationIcons/Iconly-Two-tone-Notification.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  userNotification = state.userNotification;
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      Positioned(
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(50.0),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              splashColor:
                                              Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                print('Notificationrrrrrr');
                                                if (userNotification.unread) {
                                                  notificationBloc.add(
                                                    NotificationMarkReadEvent(
                                                        user.uid),
                                                  );
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        NotificationScreen(
                                                          userNotification:userNotification,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                ),
                                                width: 38.0,
                                                height: 35.0,
                                                child: Image.asset(
                                                  widget.theme == "light"
                                                      ? 'assets/applicationIcons/Iconly-Two-tone-Notification.png'
                                                      : 'assets/applicationIcons/Iconly-Two-tone-Notification.png',
                                                  width: 30,
                                                  height: 30,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      userNotification.unread
                                          ? Positioned(
                                        right: 4.0,
                                        top: 4.0,
                                        child: Container(
                                          height: 7.5,
                                          width: 7.5,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      )
                                          : SizedBox(),
                                    ],
                                  );
                                }
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor:
                                      Colors.white.withOpacity(0.5),
                                      onTap: () {
                                        print('Notificationgggggg');
                                        showNoNotifSnack(getTranslated(
                                            context, "noNotification"));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        width: 38.0,
                                        height: 35.0,
                                        child: Image.asset(
                                          widget.theme == "light"
                                              ? 'assets/applicationIcons/Iconly-Two-tone-Notification.png'
                                              : 'assets/applicationIcons/Iconly-Two-tone-Notification.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: Colors.white.withOpacity(0.5),
                                    onTap: () {
                                      print('Notification');
                                      showNoNotifSnack(getTranslated(
                                          context, "noNotification"));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      width: 38.0,
                                      height: 35.0,
                                      child: Image.asset(
                                        widget.theme == "light"
                                            ? 'assets/applicationIcons/Iconly-Two-tone-Notification.png'
                                            : 'assets/applicationIcons/Iconly-Two-tone-Notification.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),*//*

                      Container(
                        height: 35.0,
                        width: size.width*.55,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 1.0, vertical: 0.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            prefixIcon: Image.asset(widget.theme=="light"?
                            'assets/applicationIcons/search.png':'assets/applicationIcons/Iconly-Two-tone-Search.png',
                              width: 30,
                              height: 30,
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
                                      color: Colors.white,
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
                                widget.consultant.bio,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 4,
                                style: GoogleFonts.cairo(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 14.0,
                                ),
                              ),
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
                                color: Theme.of(context).primaryColor,
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
                                        color: Colors.white,
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
                                        color: Colors.white,
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
                                    Image.asset(
                                      'assets/images/cancel_order.png',
                                      width: size.width * 0.6,
                                      height: 120,
                                    ),
                                    SizedBox(
                                      height: 15.0,
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
                                                      color: Theme.of(context).primaryColor,
                                                      fontSize: 13.0,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                    ),),
                                                  Text(
                                                    reviews[index].review,
                                                    maxLines: 2,
                                                    overflow:TextOverflow.ellipsis ,
                                                    style: GoogleFonts.cairo(
                                                      color: Theme.of(context).primaryColor,
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
                                                  color: Theme.of(context).primaryColor,
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
                                return Center(child: Container(color:Theme.of(context).primaryColor,width: size.width*.8,height: 1,));
                              },
                            ):SizedBox(),
                            */
/* Center(
                                      child: BlocBuilder(
                                        bloc: accountBloc,
                                        buildWhen: (previous, current) {
                                          if (current is getConsultReviewsInProgressState ||
                                              current is getConsultReviewsCompletedState ||
                                              current is getConsultReviewsFailedState) {
                                            return true;
                                          }
                                          return false;
                                        },
                                        builder: (context, state) {
                                          if (state is getConsultReviewsInProgressState) {
                                            return Center(
                                                child: CircularProgressIndicator());
                                          }
                                          if (state is getConsultReviewsFailedState) {
                                            return Center(
                                              child: Text(
                                                getTranslated(context, "noReviews"),
                                                style: GoogleFonts.cairo(
                                                  color: Colors.black87,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            );
                                          }
                                          if (state is getConsultReviewsCompletedState) {
                                            if (state.reviews != null) {
                                              reviews = state.reviews;
                                              print("reviews lenth");
                                              print(reviews.length.toString());
                                                reviewLength=reviews.length;
                                            }
                                            if (reviews.length == 0) {
                                              return Padding(
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
                                                        'assets/images/cancel_order.png',
                                                        width: size.width * 0.6,
                                                        height: 120,
                                                      ),
                                                      SizedBox(
                                                        height: 15.0,
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
                                              );
                                            }
                                            return  ListView.separated(
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
                                                                    color: Theme.of(context).primaryColor,
                                                                    fontSize: 13.0,
                                                                    fontWeight: FontWeight.bold,
                                                                    letterSpacing: 0.5,
                                                                  ),),
                                                                 Text(
                                                                reviews[index].review,
                                                                maxLines: 2,
                                                                overflow:TextOverflow.ellipsis ,
                                                                style: GoogleFonts.cairo(
                                                                  color: Theme.of(context).primaryColor,
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
                                                                  color: Theme.of(context).primaryColor,
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
                                                return Center(child: Container(color:Theme.of(context).primaryColor,width: size.width*.8,height: 1,));
                                              },
                                            );
                                          }
                                          return SizedBox();
                                        },
                                      )),*//*

                          ],
                        ),
                      )),
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
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(30.0),

                      ),child:  Center(
                        child: Text(
                          workDaysValue,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: GoogleFonts.cairo(
                            color: Theme.of(context).primaryColor,
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
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(30.0),

                      ),child:  Center(
                        child:  Text(
                          from,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: GoogleFonts.cairo(
                            color: Theme.of(context).primaryColor,
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
                            color: Theme.of(context).primaryColor,
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
                        color: Theme.of(context).primaryColor,
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
                  loadPackage? Center(
                      child: CircularProgressIndicator()):SizedBox(),
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

                      return InkWell(
                        splashColor:
                        Colors.red.withOpacity(0.5),
                        onTap: () {
                          _onSelected(index);
                        },
                        child: Container(height: 50,width: size.width*.8,
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            decoration: BoxDecoration(
                              color: index==0?Theme.of(context).primaryColor:Colors.grey[300],
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(color: _selectedIndex != null && _selectedIndex == index
                                  ? Colors.lightGreen
                                  : Colors.grey[300],width: 2),

                            ),child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                              Container(width: size.width*.3,
                                child: Text(
                                  packages[index].callNum.toString()+getTranslated(context, "call"),
                                  style: GoogleFonts.cairo(
                                    color:  index==0?Colors.white:Theme.of(context).primaryColor,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),),
                              ),
                              index==0?SizedBox(): Container(height: 25,width: size.width*.25,
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
                              Container(height: 40,width: size.width*.3,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(25.0),

                                ),child:Center(
                                  child: Text(
                                    packages[index].price.toString()+"\$",
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
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
                  */
/*  SizedBox(height: 20,),
                      Center(
                          child: BlocBuilder(
                            bloc: accountBloc,
                            buildWhen: (previous, current) {
                              if (current is getConsultPackagesInProgressState ||
                                  current is getConsultPackagesCompletedState ||
                                  current is getConsultPackagesFailedState) {
                                return true;
                              }
                              return false;
                            },
                            builder: (context, state) {
                              if (state is getConsultPackagesInProgressState) {
                                print("consultPackages getConsultPackagesInProgressState");
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (state is getConsultPackagesFailedState) {
                                print("consultPackages getConsultPackagesFailedState");

                                return Center(
                                  child: Text(
                                    getTranslated(context, "noPackages"),
                                    style: GoogleFonts.cairo(
                                      color: Colors.black87,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                );
                              }
                              if (state is getConsultPackagesCompletedState) {
                                print("consultPackages getConsultPackagesCompletedState");

                                if (state.packages != null) {
                                  packages = state.packages;

                                  print("consultPackages "+packages.length.toString());
                                  if (packages.length == 0) {
                                    return Padding(
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
                                    );
                                  }
                                  else
                                  return  ListView.separated(
                                    itemCount: packages.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(0),
                                    itemBuilder: (context, index) {

                                      return InkWell(
                                        splashColor:
                                        Colors.red.withOpacity(0.5),
                                        onTap: () {
                                          _onSelected(index);
                                        },
                                        child: Container(height: 50,width: size.width*.8,
                                            padding: const EdgeInsets.only(left: 10,right: 10),
                                            decoration: BoxDecoration(
                                              color: index==0?Theme.of(context).primaryColor:Colors.grey[300],
                                              borderRadius: BorderRadius.circular(25.0),
                                              border: Border.all(color: _selectedIndex != null && _selectedIndex == index
                                                  ? Colors.lightGreen
                                                  : Colors.grey[300],width: 2),

                                            ),child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                                              Container(width: size.width*.3,
                                                child: Text(
                                                  packages[index].callNum.toString()+getTranslated(context, "call"),
                                                  style: GoogleFonts.cairo(
                                                    color:  index==0?Colors.white:Theme.of(context).primaryColor,
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),),
                                              ),
                                             index==0?SizedBox(): Container(height: 25,width: size.width*.25,
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
                                              Container(height: 40,width: size.width*.3,
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor,
                                                  borderRadius: BorderRadius.circular(25.0),

                                                ),child:Center(
                                                  child: Text(
                                                    packages[index].price.toString()+"\$",
                                                    style: GoogleFonts.cairo(
                                                      color: Colors.white,
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
                                  );
                                }
                                else
                                  return SizedBox();
                              }
                              else
                                return SizedBox();
                            },
                          )),*//*

                  SizedBox(height: 20,),
                  Center(
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(height: 35,width: size.width*.7,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
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
                                },
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color:valid?Colors.green:Colors.black.withOpacity(0.1),
                              size: 30.0,
                            ),
                          ],
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "proText"),
                              style: GoogleFonts.cairo(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                                color: Colors.grey,
                              ),
                            ),
                            discount!=0? Text(
                              discount.toString()+"%",
                              style: GoogleFonts.cairo(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                                color: Colors.grey,
                              ),
                            ):SizedBox(),
                          ],
                        ),
                        SizedBox(height: 20,),
                        (user!=null&&currentNumber!=0)?Container(
                          height: 35,
                          width: size.width*.5,
                          // padding:const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
                          decoration: BoxDecoration(
                              color: Colors.lightGreen,
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
                        (user!=null&&currentNumber==0&&user.preferredPaymentMethod!=""&&user.preferredPaymentMethod!=null&&package!=null)?
                        Column(mainAxisAlignment:MainAxisAlignment.center,
                            children: [
                              InkWell(
                                splashColor:
                                Colors.white.withOpacity(0.5),
                                onTap: () {
                                  promoDialog(size);
                                },
                                child: Row(mainAxisAlignment:MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      getTranslated(context, "payWith"),
                                      style: GoogleFonts.cairo(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Icon(
                                      Icons.track_changes,
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5,),
                              user.preferredPaymentMethod=="cards"?InkWell(
                                splashColor:
                                Colors.white.withOpacity(0.5),
                                onTap: () {
                                  setState(() {
                                    load=true;
                                    price=package.price.toString();
                                    if(valid&&promo!=null)//(controller.text!=null&&controller.text!="")
                                        {
                                      price = double.parse(price.toString()) -
                                          ((double.parse(price.toString()) *
                                              double.parse(promo.discount.toString())) / 100);
                                    }
                                  });
                                  pay();
                                },
                                child: Container(height: 40,width: size.width*.7,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Center(
                                    child: Image.asset('assets/applicationIcons/all.png',
                                      width: size.width*.7,
                                      height: 30,

                                    ),
                                  ),),
                              ):SizedBox(),
                              googlePay?Container(color: Colors.black ,width: size.width*.7, height: 40,
                                child: RawGooglePayButton(
                                    style: GooglePayButtonStyle.black,
                                    type: GooglePayButtonType.plain,
                                    onPressed: onGooglePayPressed),
                              ):SizedBox(),
                              applePay?Container(color: Colors.black ,width: size.width*.7, height: 40,
                                child: RawApplePayButton(
                                    style: ApplePayButtonStyle.black,
                                    type: ApplePayButtonType.plain,
                                    onPressed: onApplePayPressed),
                              ):SizedBox(),
                            ]):
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
                                promoDialog(size);
                              }
                              else
                                registerAppointment();


                            },
                            color:AppColors.brown,// Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Text(
                              (user!=null&&currentNumber!=0)?
                              getTranslated(context,"confirm"):getTranslated(context,"participation"),
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
                              child: widget.consultant.photoUrl.isEmpty ?
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
                              widget.consultant.name,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
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
                                  color: widget.theme=="light"?AppColors.white:AppColors.black,
                                ),
                                Text(
                                  languages,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 13.0,
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
                                      size: 15,
                                      color: AppColors.yellow,
                                    ),
                                    Text(
                                      widget.consultant.rating.toStringAsFixed(1),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 13.0,
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
                                      width: 15,
                                      height: 15,
                                    ),


                                    Text(
                                      widget.consultant.ordersNumbers<100?widget.consultant.ordersNumbers.toString():widget.consultant.ordersNumbers<1000?"+100":"+1000",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 13.0,
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
                      Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            widget.consultant.price+"\$",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
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
                                color: widget.theme=="light"?avaliable?AppColors.brown:Colors.red:AppColors.black,
                                borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            child:  Center(
                              child:avaliable? Image.asset(widget.theme=="light"?
                              'assets/applicationIcons/Iconly-Two-tone-Calling-1.png':'assets/applicationIcons/Iconly-Two-tone-Calling-1.png',
                                width: 30,
                                height: 30,
                              ):Image.asset(widget.theme=="light"?
                              'assets/applicationIcons/Iconly-Two-tone-Calling-1.png':'assets/applicationIcons/redCall.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ],),
                    ],
                  ),
                  */
/* Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      widget.consultant.bio,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),*//*

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
                        String charge=request.url.substring(46);
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
  promoDialog(Size size) {
    try{
      setState(() {
        load=true;
        price=package.price.toString();
        if(valid&&promo!=null)//(controller.text!=null&&controller.text!="")
            {
          price = double.parse(price.toString()) -
              ((double.parse(price.toString()) *
                  double.parse(promo.discount.toString())) / 100);
        }
      });
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
                getTranslated(context, "payWith"),
                style: GoogleFonts.cairo(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  color: Colors.black87,
                ),
              ),
              SizedBox( height: 15.0,),
              */
/*  ApplePayButton(
                      paymentConfigurationAsset: 'applepay.json',
                      paymentItems: [PaymentItem(
                        label: 'Total',
                        amount: "1",
                        status: PaymentItemStatus.final_price,
                      )],
                      style: ApplePayButtonStyle.black,
                      type: ApplePayButtonType.plain,
                      width: size.width*.7, height: 40,
                      margin: const EdgeInsets.only(top: 15.0),
                      onPaymentResult: onApplePayResult,
                      onError: (Object e) {
                        print("yaraaaaaaab6666");
                        setState(() {
                          showPayView=false;
                          load=false;
                        });
                        Navigator.pop(context);
                        Navigator.pop(context);
                        showSnakbar(getTranslated(context, "failed"),true);
                      },
                      loadingIndicator: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                GooglePayButton(
                      paymentConfigurationAsset:
                      'gpay.json',
                      paymentItems: [PaymentItem(
                        label: 'Total',
                        amount: price.toString(),
                        status: PaymentItemStatus.final_price,
                      )],
                      style: GooglePayButtonStyle.black,
                      type: GooglePayButtonType.plain,
                      width: size.width*.7,
                      margin: const EdgeInsets.only(top: 15.0),
                      onPaymentResult: onGooglePayResult,
                      onError: (Object e) {
                        print("yaraaaaaaab");
                        setState(() {
                          showPayView=false;
                          load=false;
                        });
                        Navigator.pop(context);
                        Navigator.pop(context);
                        showSnakbar(getTranslated(context, "failed"),true);
                      },
                      loadingIndicator: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),*//*

              googlePay?Container(color: Colors.black ,width: size.width*.7, height: 40,
                child: RawGooglePayButton(
                    style: GooglePayButtonStyle.black,
                    type: GooglePayButtonType.plain,
                    onPressed: onGooglePayPressed),
              ):SizedBox(),
              applePay?Container(color: Colors.black ,width: size.width*.7, height: 40,
                child: RawApplePayButton(
                    style: ApplePayButtonStyle.black,
                    type: ApplePayButtonType.plain,
                    onPressed: onApplePayPressed),
              ):SizedBox(),
              SizedBox(
                height: 15.0,
              ),
              InkWell(
                splashColor:
                Colors.white.withOpacity(0.5),
                onTap: () {
                  Navigator.pop(context);
                  pay();
                },
                child: Container(height: 40,width: size.width*.7,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Image.asset('assets/applicationIcons/all.png',
                      width: size.width*.7,
                      height: 30,

                    ),
                  ),),
              ),
              SizedBox(
                height: 15.0,
              ),
              StatefulBuilder(builder: (context, setState) {
                return     SingleChildScrollView(
                    child: Row(
                      children: [
                        Checkbox(
                          value: activeValue,
                          onChanged: (value) {
                            setState(() {
                              activeValue = !activeValue;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            getTranslated(context, "preferred"),
                            maxLines: 2,
                            style: GoogleFonts.cairo(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ));
              }),
              SizedBox(
                height: 15.0,
              ),
              InkWell(
                splashColor:
                Colors.white.withOpacity(0.5),
                onTap: () {
                  setState(() {
                    load=false;
                  });
                  print("gdsfafasfsfasfas");
                  Navigator.pop(context);
                },
                child: Center(
                  child: Container(height: 35,width: size.width*.5,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(35.0),

                    ),child:  Center(
                      child: Text(
                        getTranslated(context, "cancel"),
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),),
                    ),
                  ),
                ),
              ),

            ],
          ),

        ), barrierDismissible: false,
        context: context,
      );
    }catch(e){print("yaraberror"+e.toString());}
  }
  void onGooglePayPressed() async {
    print("pricebeforDiscount");
    print(price);
    setState(() {
      load=true;
      price=package.price.toString();
      if(valid&&promo!=null)//(controller.text!=null&&controller.text!="")
          {
        price = double.parse(price.toString()) -
            ((double.parse(price.toString()) *
                double.parse(promo.discount.toString())) / 100);
      }
    });
    print("priceafterDiscount");
    print(price);
    await _payClient.showPaymentSelector(
      provider: PayProvider.google_pay,
      paymentItems: [PaymentItem(
        label: 'Total',
        amount: price.toString(),
        status: PaymentItemStatus.final_price,
      )],
    ).then((value) {
      print("applePayyyyyyy");
      print(value);
      if(value!=null&&value!="")
      {
        if(activeValue)
          payMethod="googlePay";
        updateDatabaseAfterAddingOrder(user.customerId,"googlePay");
      }
      else
      {
        setState(() {
          showPayView=false;
          load=false;
        });
        // if(user.preferredPaymentMethod=="googlePay"){}
        // else Navigator.pop(context);
        showSnakbar(getTranslated(context, "failed"),true);
      }

    });
    // Send the resulting Google Pay token to your server / PSP
  }
  void onApplePayPressed() async {
    print("pricebeforDiscount");
    print(price);
    setState(() {
      load=true;
      price=package.price.toString();
      if(valid&&promo!=null)//(controller.text!=null&&controller.text!="")
          {
        price = double.parse(price.toString()) -
            ((double.parse(price.toString()) *
                double.parse(promo.discount.toString())) / 100);
      }
    });
    print("priceafterDiscount");
    print(price);
    await _payClient.showPaymentSelector(
      provider: PayProvider.apple_pay,
      paymentItems: [PaymentItem(
        label: 'Total',
        amount: price.toString(),
        status: PaymentItemStatus.final_price,
      )],
    ).then((value) {
      print("applePayyyyyyy");
      print(value);
      if(value!=""&&value!=null)
      {
        if(activeValue)
          payMethod="applePay";
        updateDatabaseAfterAddingOrder(user.customerId,"applePay");
      }
      else
      {
        setState(() {
          showPayView=false;
          load=false;
        });
        //if(user.preferredPaymentMethod=="applePay"){}
        // else Navigator.pop(context);
        showSnakbar(getTranslated(context, "failed"),true);
      }

    });
    // Send the resulting Google Pay token to your server / PSP
  }
  void onGooglePayResult(paymentResult) {
    // Navigator.pop(context);
    if(activeValue)
      payMethod="googlePay";
    updateDatabaseAfterAddingOrder(user.customerId,"googlePay");
  }

  void onApplePayResult(paymentResult) {
    // Navigator.pop(context);
    if(activeValue)
      payMethod="applePay";
    updateDatabaseAfterAddingOrder(user.customerId,"applePay");
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
        setState(() {
          promo = codes[0];
          promoCodeId=promo.promoCodeId;
          checkPromo=false;
          valid=true;
          discount=promo.discount;
          */
/* price = double.parse(price.toString()) -
                ((double.parse(price.toString()) *
                    double.parse(promo.discount.toString())) / 100);*//*

        });
      }else{
        setState(() {
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

    showUpdatingDialog();
    final uri = Uri.parse('https://api.tap.company/v2/charges');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization':"Bearer sk_test_4KmXWCt20xzpfeNvyOiFUY3G",
      // 'Authorization':"Bearer sk_live_LJrxost8E5WQp7Xja6cUqlnG",
      'Connection':'keep-alive',
      'Accept-Encoding':'gzip, deflate, br'

    };
    Map<String, dynamic> body ={
      "amount": price,
      "currency": "SAR",
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
        "first_name": user.name,
        "middle_name": ".",
        "last_name": ".",
        "email": user.name+"@example.com",
        "phone": {"country_code": "",
          "number": user.phoneNumber
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
    print("start5");
    print(user.customerId);
    print(responseBody);
    var res = json.decode(responseBody);
    print(res['transaction']);
    print("start6");
    String url = res['transaction']['url'];
    Navigator.pop(context);
    setState(() {
      initialUrl=url;
      print("yarab applepay");
      print(initialUrl);
      showPayView = true;
    });


  }
  payStatus(String chargeId) async {
    showUpdatingDialog();
    final uri = Uri.parse('https://api.tap.company/v2/charges/'+chargeId);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization':"Bearer sk_test_4KmXWCt20xzpfeNvyOiFUY3G",
      // 'Authorization':"Bearer sk_live_LJrxost8E5WQp7Xja6cUqlnG",
      'Connection':'keep-alive',
      'Accept-Encoding':'gzip, deflate, br'
    };
    print("startchargeId1");
    var response = await get(
      uri,
      headers: headers,

    );
    String responseBody = response.body;
    var res = json.decode(responseBody);

    String customerId=res['customer']['id'];
    customerId= customerId!=null?customerId:"";
    if(res['status']=="CAPTURED")
    {
      if(activeValue)
        payMethod="cards";
      updateDatabaseAfterAddingOrder(customerId,"tapCompany");
    }
    else
    {
      print("yaraaaaaaab");
      setState(() {
        showPayView=false;
        load=false;
      });
      Navigator.pop(context);
      showSnakbar(getTranslated(context, "failed"),true);

    }
  }
  updateDatabaseAfterAddingOrder(String customerId,String payWith) async {
    print("successPayment");
    String orderId=Uuid().v4();
    DateTime dateValue=DateTime.now();
    dynamic callPrice=double.parse(price)/package.callNum;
    await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(orderId).set({
      'orderStatus': 'open',
      'orderId': orderId,
      'orderTimestamp': Timestamp.now(),
      'orderTimeValue': DateTime(dateValue.year, dateValue.month, dateValue.day ).millisecondsSinceEpoch,
      'packageId': package.Id,
      'promoCodeId':promoCodeId,
      'remainingCallNum': package.callNum,
      'packageCallNum':package.callNum,
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
      },
      'user': {
        'uid': user.uid,
        'name': user.name,
        'image': user.photoUrl,
        'phone': user.phoneNumber,

      },
    });
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
    //update consult order numbers
    int consultOrdersNumbers=1;
    print("ffff1");
    print(widget.consultant.ordersNumbers);
    if(widget.consultant.ordersNumbers!=null)
      consultOrdersNumbers=1+widget.consultant.ordersNumbers;
    */
/* if(widget.consultant.balance!=null)
        consultBalance=consultBalance+widget.consultant.balance;*//*

    await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.consultant.uid).set({
      'ordersNumbers': consultOrdersNumbers,
      //'balance':consultBalance,
    }, SetOptions(merge: true));
    widget.consultant.ordersNumbers=consultOrdersNumbers;
    print("ffff2");

    //update user order numbers
    int userOrdersNumbers=1;
    String consulIds=widget.consultant.uid;
    dynamic payedBalance=double.parse(price.toString());

    if(user.userConsultIds!=null&&(!user.userConsultIds.contains(widget.consultant.uid)))
      consulIds=user.userConsultIds+","+widget.consultant.uid;
    print("ffff3");

    if(user.ordersNumbers!=null)
      userOrdersNumbers=user.ordersNumbers+1;
    if(user.payedBalance!=null)
      payedBalance=user.payedBalance+payedBalance;

    print("ffff4");
    user.preferredPaymentMethod=payMethod;
    await FirebaseFirestore.instance.collection(Paths.usersPath).doc(user.uid).set({
      'ordersNumbers': userOrdersNumbers,
      'payedBalance':payedBalance,
      'userConsultIds':consulIds,
      'customerId':customerId,
      'preferredPaymentMethod':payMethod

    }, SetOptions(merge: true));
    print("ffff5");
//======update number ofuse of promocode
    if(promo!=null)
    {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(Paths.promoPath).doc(promo.promoCodeId).get();
      Map<String, dynamic> data = documentSnapshot.data();
      int usedNumber = data['usedNumber'];
      await FirebaseFirestore.instance.collection(Paths.promoPath).doc(
          promo.promoCodeId).set({
        'usedNumber': usedNumber + 1,
      }, SetOptions(merge: true));
    }
    accountBloc.add(GetAccountDetailsEvent(user.uid));
    Navigator.pop(context);
    showSnakbar(getTranslated(context, "success"),true);
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
  Future<void> registerAppointment() async {
    setState(() {
      load=true;
    });
    DateTime _now = DateTime.now();
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .where( 'consult.uid', isEqualTo: widget.consultant.uid,)
          .orderBy('secondValue', descending: true)
          .limit(1)
          .get();
      AppAppointments appointment;
      if(querySnapshot.docs.length>0)
      {
        appointment =AppAppointments.fromFirestore(querySnapshot.docs[0]);
        if(appointment.secondValue>DateTime.now().millisecondsSinceEpoch)
        {
          print("dssdadasd");
          print(appointment.time.hour);
          var newdate= appointment.appointmentTimestamp.toDate().add(Duration( minutes: 10));
          //addAppointment(newdate);
          if(newdate.hour<int.parse(widget.consultant.workTimes[0].to))
          {
            print("dssdadasd٢٢٢٢٢");
            addAppointment(newdate);
          }
          else
          { print("newdate1112222");

          var date3=  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1 );//_now.add(Duration(days: 1));
          print(date3);
          addNewdate(date3);
          }
        }
        else {
          print("dssdadasdaaaaaaa");
          print(DateTime.now().millisecondsSinceEpoch-appointment.secondValue);
          if(DateTime.now().millisecondsSinceEpoch-appointment.secondValue< 600000&&DateTime.now().millisecondsSinceEpoch-appointment.secondValue>0)
            addNewdate(appointment.appointmentTimestamp.toDate().add(Duration( minutes: 10)));
          else
            addNewdate(DateTime.now());
        }

      }
      else
        addNewdate(DateTime.now());
    }catch(e){
      print("getnumbererror"+e.toString());
    }
  }
  addNewdate(DateTime _nowtime) {
    print("addNewdate");
    if(widget.consultant.workDays.contains(_nowtime.weekday.toString())&&_nowtime.hour>=int.parse(widget.consultant.workTimes[0].from)&&
        _now.hour<=int.parse(widget.consultant.workTimes[0].to))
    {
      addAppointment(_nowtime);
    }
    else
    {
      for(int x=1;x<15; x++)
      {
        var _now2 = DateTime.now().add(Duration(days: x));
        print("dddd1");
        print(_now2);
        if(widget.consultant.workDays.contains(_now2.weekday.toString()))
        {
          print("dddd2");
          DateTime today = DateTime(_now2.year, _now2.month, _now2.day );
          print("dddd3");
          print(today);
          var newdate= today.add(Duration( hours: int.parse(widget.consultant.workTimes[0].from),minutes: 0));
          print("dddd4");
          print(newdate);
          addAppointment(newdate);
          break;
        }
        else
        {print("_mmmmmm");}
      }
    }
  }
  Future<void>addAppointment(DateTime date)
  async {
    print("finaldate");
    print(date);
    String appointmentId=Uuid().v4();
    await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(appointmentId).set({
      'appointmentId': appointmentId,
      'appointmentStatus': 'new',
      'timestamp': Timestamp.now(),//FieldValue.serverTimestamp(),
      'timeValue': DateTime(date.year, date.month, date.day ).millisecondsSinceEpoch,
      'secondValue': DateTime(date.year, date.month, date.day,date.hour, date.minute, date.second ).millisecondsSinceEpoch,
      'appointmentTimestamp': Timestamp.fromDate(date),
      'consultChat':0,
      'userChat':0,
      'orderId': order.orderId,
      'callPrice':order.callPrice,
      'consult': {
        'uid': widget.consultant.uid,
        'name': widget.consultant.name,
        'image': widget.consultant.photoUrl,
        'phone': widget.consultant.phoneNumber,
      },
      'user': {
        'uid': user.uid,
        'name': user.name,
        'image': user.photoUrl,
        'phone': user.phoneNumber,

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
    });
    currentNumber=order.remainingCallNum-1;
    await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(order.orderId).set({
      'orderStatus': currentNumber<=0?"completed":"open",
      'remainingCallNum':currentNumber,
    }, SetOptions(merge: true));

    getnumber();
    if(currentNumber==0) {
      String userOrder=user.userConsultIds.replaceAll(widget.consultant.uid, ",");
      await FirebaseFirestore.instance.collection(Paths.usersPath).doc(
          widget.loggedUser.uid).set({
        'userConsultIds': userOrder,
      }, SetOptions(merge: true));
      accountBloc.add(GetAccountDetailsEvent(user.uid));
    }
    setState(() {
      load=false;
    });
    //showSnakbar(getTranslated(context,'appointmentRegister'),true);
    appointmentDialog(MediaQuery.of(context).size,date);
  }
  appointmentDialog(Size size,DateTime date) {

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
              date.toString(),
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
}
*/
