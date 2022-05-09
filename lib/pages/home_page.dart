// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/banner_bloc/banner_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/setting.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/screens/DevelopTechSupport/allDevelopSupport.dart';
import 'package:grocery_store/screens/account_screen.dart';
import 'package:grocery_store/screens/dashboard.dart';
import 'package:grocery_store/screens/moreScreen.dart';
import 'package:grocery_store/screens/notification_screen.dart';
import 'package:grocery_store/screens/searchScreen.dart';
import 'package:grocery_store/screens/twCallScreen.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:grocery_store/services/firebase_service.dart';
import 'package:grocery_store/widget/appointmentWidget.dart';
import 'package:grocery_store/widget/consultantListItem.dart';
import 'package:http/http.dart' as http;
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:twilio_voice/twilio_voice.dart';
import 'package:uuid/uuid.dart';


class HomePage extends StatefulWidget {
  final userType;

  const HomePage({Key key, this.userType}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController searchController = new TextEditingController();
  AccountBloc accountBloc;
  SigninBloc signinBloc;
  BannerBloc bannerBloc;
  User currentUser;
  NotificationBloc notificationBloc;
  UserNotification userNotification;
  GroceryUser user = null;
  bool first;
  bool perfect = false, glorified = false,jeras=true,vocal=false,wait=true,fixed=false;
  bool load = true, loadPageWidget = true;
  bool active = false;
  List<GroceryUser> activeConsultantList = [];
  Query query;
  String userImage, lang, theme, appTitle,consultType="perfect",listText="";
  bool avaliable = false;
  DateTime _now = DateTime.now();
  Setting setting;

  String userId;
  var registered = false;
  var hasPushedToCall = false;
  AppLifecycleState state;

  @override
  void initState() {
    super.initState();
    first = true;
    jeras=true;
    accountBloc = BlocProvider.of<AccountBloc>(context);
    signinBloc = BlocProvider.of<SigninBloc>(context);
    bannerBloc = BlocProvider.of<BannerBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    getTitle();
    signinBloc.listen((state) {
      if (state is GetCurrentUserCompleted) {
        if (mounted) {
          currentUser = state.firebaseUser;
          accountBloc.add(GetAccountDetailsEvent(currentUser.uid));
          if (first) {
            FirebaseService.init(context, currentUser.uid, currentUser);
            first = false;
          }
        }
      }
      if (state is GetCurrentUserFailed) {
        loadPageWidget = false;
      }
    });
    accountBloc.listen((state) {
      print(state);
      if (state is GetAccountDetailsCompletedState) {
        user = state.user;
        notificationBloc.add(GetAllNotificationsEvent(state.user.uid));
        if (mounted) {
          checkAvaliable();
          setState(() {
            load = false;
            loadPageWidget = false;
          });
        }

        if (mounted && user.photoUrl != null && user.photoUrl != "")
          setState(() {
            userImage = user.photoUrl;
          });
        if (user != null) {
          waitForLogin();
          waitForCall();
          WidgetsBinding.instance.addObserver(this);
          TwilioVoice.instance.registerClient(user.uid, user.uid);
        }
      }
    });
    bannerBloc.listen((state) {
      if (state is getActiveconsultantsCompletedState) {
        activeConsultantList = state.consultants;
        if (state.consultants.length > 0) {
          if (mounted)
            setState(() {
              active = true;
            });
        }
      }
    });
    notificationBloc.listen((state) {
      print('NOTIFICATION STATE :::: $state');
    });
    bannerBloc.add(getActiveConsultationsEvent());
    signinBloc.add(GetCurrentUser());
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
  void dispose() {
    first = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  @override
  Widget build(BuildContext context) {

    lang = getTranslated(context, "lang");

    if (setting != null) {
      if (lang == "ar")
        setState(() {
          appTitle = setting.firstTitleAr;
        });
      else
        setState(() {
          appTitle = setting.firstTitleEn;
        });
    } else
      setState(() {
        appTitle = getTranslated(context, "firstApp");
      });
    super.build(context);
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child:  Scaffold(
              key: _scaffoldKey,
              body: loadPageWidget ? loadWidget(size): widget.userType == "CONSULTANT"
                  ? consultHome(size)
                  : userHome(size),
            ) ,
    );
  }

  Widget loadWidget(Size size) {
    return Stack(children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: size.width,
            height: size.height * .28,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                  width: size.width,
                  child: Column( mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: () {
                            if (user != null && user.userType != "CONSULTANT")
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserAccountScreen(
                                      user: user, firstLogged: false),
                                ),
                              );
                            else {
                              Navigator.pushNamed(context, '/Register_Type');
                            }
                          },
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: userImage == null
                                ? Image.asset(
                              theme == "light"
                                  ? 'assets/applicationIcons/whiteLogo.png'
                                  : 'assets/applicationIcons/whiteLogo.png',
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: FadeInImage.assetNetwork(
                                placeholder: theme == "light"
                                    ? 'assets/applicationIcons/whiteLogo.png'
                                    : 'assets/applicationIcons/whiteLogo.png',
                                imageErrorBuilder:
                                    (context, error, stackTrace) => Icon(
                                  Icons.person,
                                  color: Colors.black,
                                  size: 50.0,
                                ),
                                image: userImage,
                                fit: BoxFit.cover,

                                fadeInDuration: Duration(milliseconds: 250),
                                fadeInCurve: Curves.easeInOut,
                                fadeOutDuration: Duration(milliseconds: 150),
                                fadeOutCurve: Curves.easeInOut,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[

                          currentUser == null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.white.withOpacity(0.5),
                                onTap: () {
                                  showNoNotifSnack(
                                      getTranslated(context, "noNotification"));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  width: 25.0,
                                  height: 25.0,
                                  child: Image.asset(
                                    theme == "light"
                                        ? 'assets/applicationIcons/lightNotification.png'
                                        : 'assets/applicationIcons/darkNotification.png',
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
                                        width: 25.0,
                                        height: 25.0,
                                        child: Image.asset(
                                          theme == "light"
                                              ? 'assets/applicationIcons/lightNotification.png'
                                              : 'assets/applicationIcons/darkNotification.png',
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
                                            showNoNotifSnack(getTranslated(context, "noNotification"));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            width: 25.0,
                                            height: 25.0,
                                            child: Image.asset(
                                              theme == "light"
                                                  ? 'assets/applicationIcons/lightNotification.png'
                                                  : 'assets/applicationIcons/darkNotification.png',
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
                                                if (userNotification.unread) {
                                                  notificationBloc.add(
                                                    NotificationMarkReadEvent(
                                                        currentUser.uid),
                                                  );
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        NotificationScreen(
                                                          userNotification:
                                                          userNotification,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                ),
                                                width: 25.0,
                                                height: 25.0,
                                                child: Image.asset(
                                                  theme == "light"
                                                      ? 'assets/applicationIcons/lightNotification.png'
                                                      : 'assets/applicationIcons/darkNotification.png',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      userNotification.unread
                                          ? Positioned(
                                        left: 2.0,
                                        top: 2.0,
                                        child: Container(
                                          height: 10,
                                          width: 10,
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
                                        width: 25.0,
                                        height: 25.0,
                                        child: Image.asset(
                                          theme == "light"
                                              ? 'assets/applicationIcons/lightNotification.png'
                                              : 'assets/applicationIcons/darkNotification.png',
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
                                      width: 25.0,
                                      height: 25.0,
                                      child: Image.asset(
                                        theme == "light"
                                            ? 'assets/applicationIcons/lightNotification.png'
                                            : 'assets/applicationIcons/darkNotification.png',
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                              height: 35.0,
                              width: size.width * .65,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 1.0, vertical: 0.0),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: SizedBox()),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashboardScreen(),
                                ),
                              );
                            },
                            icon: Image.asset(
                              theme == "light"
                                  ? 'assets/applicationIcons/Iconly-Curved-Category.png'
                                  : 'assets/applicationIcons/dashbord.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ),
          ),
          SizedBox(
            height: 80,
          ),
          Center(child: CircularProgressIndicator()),
        ],
      ),
    ]);
  }

  Widget userHome(Size size) {

    return Stack(children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: size.width,
            height: size.height * .28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child:  Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                  width: size.width,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      SizedBox(height: 5,),
//-------AppBar---------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,

                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          //----------DashboardButton----------
                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: theme=="light"?Colors.white:Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 0.0),
                                  blurRadius: 5.0,
                                  spreadRadius: 1.0,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ],

                            ),
                            child:
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardScreen(),
                                  ),
                                );
                              },
                              icon: Image.asset(
                                theme == "light"
                                    ? 'assets/applicationIcons/dashbord.png'
                                    : 'assets/applicationIcons/Iconly-Curved-Category.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),

                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: theme=="light"?Colors.white:Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 0.0),
                                  blurRadius: 5.0,
                                  spreadRadius: 1.0,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ],

                            ),
                            child:
                          currentUser == null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.white.withOpacity(0.5),
                                onTap: () {
                                  showNoNotifSnack(
                                      getTranslated(context, "noNotification"));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  width: 20.0,
                                  height: 20.0,
                                  child: Image.asset(
                                    theme == "light"
                                        ? 'assets/applicationIcons/darkNotification.png'
                                    :'assets/applicationIcons/lightNotification.png',
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

                              if (state is GetAllNotificationsInProgressState) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor:
                                      Colors.white.withOpacity(0.5),
                                      onTap: () {
                                        showNoNotifSnack(getTranslated( context, "noNotification"));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        width: 20.0,
                                        height: 20.0,
                                        child: Image.asset(
                                          theme == "light"
                                              ? 'assets/applicationIcons/darkNotification.png'
                                              :'assets/applicationIcons/lightNotification.png',),
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
                                            showNoNotifSnack(getTranslated(  context, "noNotification"));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            width: 20.0,
                                            height: 20.0,
                                            child: Image.asset(
                                              theme == "light"
                                                  ? 'assets/applicationIcons/darkNotification.png'
                                                  :'assets/applicationIcons/lightNotification.png', ),
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
                                                if (userNotification.unread) {
                                                  notificationBloc.add(
                                                    NotificationMarkReadEvent(
                                                        currentUser.uid),
                                                  );
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        NotificationScreen(
                                                          userNotification:
                                                          userNotification,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                ),
                                                width: 20.0,
                                                height: 20.0,
                                                child: Image.asset(
                                                  theme == "light"
                                                      ? 'assets/applicationIcons/darkNotification.png'
                                                      :'assets/applicationIcons/lightNotification.png', ),
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
                                        showNoNotifSnack(getTranslated( context, "noNotification"));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        width: 25.0,
                                        height: 25.0,
                                        child: Image.asset(
                                          theme == "light"
                                              ? 'assets/applicationIcons/lightNotification.png'
                                              : 'assets/applicationIcons/darkNotification.png',
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
                                      showNoNotifSnack(getTranslated(
                                          context, "noNotification"));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      width: 25.0,
                                      height: 25.0,
                                      child: Image.asset(
                                        theme == "light"
                                            ? 'assets/applicationIcons/lightNotification.png'
                                            : 'assets/applicationIcons/darkNotification.png',
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          ),
                          //-----------------------search------------------------
                          Container(
                            height: 45.0,
                            width: size.width*.55,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 1.0, vertical: 0.0),
                            decoration: BoxDecoration(
                              color: theme=="light"?Colors.white:Color(0xff3f3f3f),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 0.0),
                                  blurRadius: 5.0,
                                  spreadRadius: 1.0,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ],
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
                                hintText: getTranslated(context, "search"),
                                hintStyle: GoogleFonts.cairo(
                                  fontSize: 14.5,
                                  color: Theme.of(context).primaryColor,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                           InkWell(
                              splashColor: Colors.white.withOpacity(0.5),
                              onTap: () {
                                if (user != null && user.isDeveloper)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AllDevelopTechScreen(loggedUser: user),
                                    ),
                                  );
                                else if (user != null && user.userType != "CONSULTANT")
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserAccountScreen(
                                          user: user, firstLogged: false),
                                    ),
                                  );
                                else {
                                  Navigator.pushNamed(context, '/Register_Type');
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: userImage == null
                                    ? Image.asset(
                                  theme == "light"
                                      ? 'assets/applicationIcons/whiteLogo.png'
                                      : 'assets/applicationIcons/whiteLogo.png',
                                  width: 70,
                                  height: 70,
                                )
                                    : ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: theme == "light"
                                        ? 'assets/applicationIcons/whiteLogo.png'
                                        : 'assets/applicationIcons/whiteLogo.png',
                                    //placeholderScale: 0.5,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) => Icon(
                                      Icons.person,
                                      color: Colors.black,
                                      size: 50.0,
                                    ),
                                    image: userImage,
                                    fit: BoxFit.cover,
                                    /* width: 50,
                                        height: 50,*/
                                    fadeInDuration: Duration(milliseconds: 250),
                                    fadeInCurve: Curves.easeInOut,
                                    fadeOutDuration: Duration(milliseconds: 150),
                                    fadeOutCurve: Curves.easeInOut,
                                  ),
                                ),
                              ),
                            ),

                        ],
                      ),
                      SizedBox(height: 15,),
                      Divider(
                          height: 2,
                          color:Colors.grey
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          height: 90,
                          width: size.width * .8,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.pink,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 0.0),
                                blurRadius: 2.0,
                                spreadRadius: 2.0,
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ],
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    appTitle,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),

                                SizedBox( height: 2,),
                              ])),
                    ],
                  ),
                ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Center(
            child:Container(
                height: 50,
                width: size.width ,
                padding: const EdgeInsets.all(10),
                //color: Colors.white,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            consultType="perfect";
                            perfect = true;
                            glorified = false;
                            jeras=false;
                            vocal = false;
                            listText=getTranslated(context, "perfectText");
                          });
                        },
                        child:
                        Container(
                          height: 40,
                          width: size.width * .22,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: perfect
                                ? theme == "light"
                                ? AppColors.pink
                                : Colors.black
                                : AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "perfect"),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: perfect
                                    ? theme == "light"
                                    ? Colors.white
                                    : Colors.white
                                    : theme == "light"
                                    ? AppColors.grey//Theme.of(context).primaryColor
                                    : Colors.black,
                              fontSize: 11.0,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      InkWell(

                        onTap: () {
                          setState(() {
                            consultType="glorified";
                            perfect = false;
                            glorified = true;
                            jeras=false;
                            vocal = false;
                            listText=getTranslated(context, "glorifiedText");

                          });
                        },
                        child: Container(
                          height: 40,
                          width: size.width * .22,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: glorified
                                ? theme == "light"
                                ? AppColors.pink
                                : Colors.black
                                : AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "glorified"),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: glorified
                                    ? theme == "light"
                                    ? Colors.white
                                    : Colors.white
                                    : theme == "light"
                                    ? AppColors.grey//Theme.of(context).primaryColor
                                    : Colors.black,
                              fontSize: 11.0,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      InkWell(

                        onTap: () {
                          setState(() {
                            consultType="jeras";
                            perfect = false;
                            glorified = false;
                            jeras=true;
                            vocal = false;
                            listText=getTranslated(context, "jerasText");
                          });
                        },
                        child: Container(
                          height: 40,
                          width: size.width * .22,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: jeras
                                ? theme == "light"
                                ? AppColors.pink
                                : Colors.black
                                : AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "jeras"),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: jeras
                                    ? theme == "light"
                                    ? Colors.white
                                    : Colors.white
                                    : theme == "light"
                                    ? AppColors.grey//Theme.of(context).primaryColor
                                    : Colors.black,
                              fontSize: 11.0,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      InkWell(

                        onTap: () {
                          setState(() {
                            consultType="vocal";
                            perfect = false;
                            glorified = false;
                            jeras=false;
                            vocal=true;
                            listText=getTranslated(context, "vocalText");
                          });
                        },
                        child: Container(
                          height: 40,
                          width: size.width * .22,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: vocal
                                ? theme == "light"
                                ? AppColors.pink
                                : Colors.black
                                : AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "vocal"),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: vocal
                                    ? theme == "light"
                                    ? Colors.white
                                    : Colors.white
                                    : theme == "light"
                                    ? AppColors.grey//Theme.of(context).primaryColor
                                    : Colors.black,
                                fontSize: 11.0,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ])),
          ),
          Center(child: Container(color: AppColors.grey,height: 1,width: size.width*.9)),
          Center(
            child: Text(
              listText,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: AppColors.pink,
               fontSize: 11.0,
                letterSpacing: 0.3,
              ),
            ),
          ),
          perfect?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.gridView,
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 16.0, top: 1.0),
              //Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return ConsultantListItem(
                    consult: GroceryUser.fromFirestore(documentSnapshot[index]),
                    loggedUser: user,
                    theme: theme);
              },
              query: FirebaseFirestore.instance
                  .collection('Users')
                  .where('userType', isEqualTo: 'CONSULTANT')
                  .where('consultType', isEqualTo: "perfect")
                  .where('accountStatus', isEqualTo: "Active")
                  .orderBy('order', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(),
          glorified?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.gridView,
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 16.0, top: 1.0),
              //Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return ConsultantListItem(
                    consult: GroceryUser.fromFirestore(documentSnapshot[index]),
                    loggedUser: user,
                    theme: theme);
              },
              query: FirebaseFirestore.instance
                  .collection('Users')
                  .where('userType', isEqualTo: 'CONSULTANT')
                  .where('consultType', isEqualTo: "glorified")
                  .where('accountStatus', isEqualTo: "Active")
                  .orderBy('order', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(),
          jeras?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.gridView,
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 20.0, top: 5.0),
              //Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return ConsultantListItem(
                    consult: GroceryUser.fromFirestore(documentSnapshot[index]),
                    loggedUser: user,
                    theme: theme);
              },
              query: FirebaseFirestore.instance
                  .collection('Users')
                  .where('userType', isEqualTo: 'CONSULTANT')
                  .where('consultType', isEqualTo: "jeras")
                  .where('accountStatus', isEqualTo: "Active")
                  .orderBy('order', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(
            height: 10.0,
          ),
          vocal?Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.gridView,
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 16.0, top: 1.0),
              //Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return ConsultantListItem(
                    consult: GroceryUser.fromFirestore(documentSnapshot[index]),
                    loggedUser: user,
                    theme: theme);
              },
              query: FirebaseFirestore.instance
                  .collection('Users')
                  .where('userType', isEqualTo: 'CONSULTANT')
                  .where('consultType', isEqualTo: "vocal")
                  .where('accountStatus', isEqualTo: "Active")
                  .orderBy('order', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):SizedBox(
            height: 10.0,
          ),
        ],
      ),

      Positioned(top: 200,
        left: (MediaQuery.of(context).size.width/7),
        child: Container(
          height: 25,
          width: size.width * 0.3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 0.0),
                blurRadius: 5.0,
                spreadRadius: 1.0,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          child: FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoreScreen(),
                ),
              );
            },

            child: Text(
              getTranslated(context, "readMore"),
              style: GoogleFonts.cairo(
                color: AppColors.pink,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget consultHome(Size size) {
    return Stack(children: <Widget>[
      Column(
        children: <Widget>[
          Container(
            width: size.width,
            height: size.height * .28,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                  width: size.width,
                  child: Column( mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: () {
                          if (user != null && user.isDeveloper )
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>AllDevelopTechScreen(loggedUser:user),
                                ),
                              );
                            else if (user != null && user.userType == "CONSULTANT")
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AccountScreen(user: user, firstLogged: false),
                                ),
                              );
                            else {
                              Navigator.pushNamed(context, '/Register_Type');
                            }
                          },
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: userImage == null
                                ? Image.asset(
                              theme == "light"
                                  ? 'assets/applicationIcons/whiteLogo.png'
                                  : 'assets/applicationIcons/whiteLogo.png',
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(70.0),
                              child: FadeInImage.assetNetwork(
                                placeholder: theme == "light"
                                    ? 'assets/applicationIcons/whiteLogo.png'
                                    : 'assets/applicationIcons/whiteLogo.png',
                                placeholderScale: 0.5,
                                imageErrorBuilder:
                                    (context, error, stackTrace) => Icon(
                                  Icons.person,
                                  color: Colors.black,
                                  size: 50.0,
                                ),
                                width: 70,
                                height: 70,
                                image: userImage,
                                fit: BoxFit.cover,
                                fadeInDuration: Duration(milliseconds: 250),
                                fadeInCurve: Curves.easeInOut,
                                fadeOutDuration: Duration(milliseconds: 150),
                                fadeOutCurve: Curves.easeInOut,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height:5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[

                          currentUser == null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.white.withOpacity(0.5),
                                onTap: () {
                                  showNoNotifSnack(
                                      getTranslated(context, "noNotification"));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  width: 25.0,
                                  height: 25.0,
                                  child: Image.asset(
                                    theme == "light"
                                        ? 'assets/applicationIcons/lightNotification.png'
                                        : 'assets/applicationIcons/darkNotification.png',
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
                                        width: 25.0,
                                        height: 25.0,
                                        child: Image.asset(
                                          theme == "light"
                                              ? 'assets/applicationIcons/lightNotification.png'
                                              : 'assets/applicationIcons/darkNotification.png',
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
                                            width: 25.0,
                                            height: 25.0,
                                            child: Image.asset(
                                              theme == "light"
                                                  ? 'assets/applicationIcons/lightNotification.png'
                                                  : 'assets/applicationIcons/darkNotification.png',
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
                                                        currentUser.uid),
                                                  );
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        NotificationScreen(
                                                          userNotification:
                                                          userNotification,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                ),
                                                width: 25.0,
                                                height: 25.0,
                                                child: Image.asset(
                                                  theme == "light"
                                                      ? 'assets/applicationIcons/lightNotification.png'
                                                      : 'assets/applicationIcons/darkNotification.png',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      userNotification.unread
                                          ? Positioned(
                                        left: 2.0,
                                        top: 2.0,
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
                                        width: 25.0,
                                        height: 25.0,
                                        child: Image.asset(
                                          theme == "light"
                                              ? 'assets/applicationIcons/lightNotification.png'
                                              : 'assets/applicationIcons/darkNotification.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor:
                                      Colors.white.withOpacity(0.5),
                                      onTap: () {
                                        print('Notification');
                                        showNoNotifSnack(getTranslated(
                                            context, "noNotification"));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        width: 25.0,
                                        height: 25.0,
                                        child: Image.asset(
                                          theme == "light"
                                              ? 'assets/applicationIcons/lightNotification.png'
                                              : 'assets/applicationIcons/darkNotification.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                            },
                          ),
                          Container(
                            height: 35.0,
                            width: size.width * .50,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 1.0, vertical: 0.0),
                            decoration: BoxDecoration(
                              color: avaliable ? AppColors.pink : AppColors.grey,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
                              child: Text(
                                avaliable
                                    ? getTranslated(context, "available")
                                    : getTranslated(context, "notAvailable"),
                                style: GoogleFonts.cairo(
                                  fontSize: 14.0,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashboardScreen(),
                                ),
                              );
                            },
                            icon: Image.asset(
                              theme == "light"
                                  ? 'assets/applicationIcons/Iconly-Curved-Category.png'
                                  : 'assets/applicationIcons/dashbord.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ),
          ),
          SizedBox(
            height: 30,
          ),

          (fixed == true && load == false)
              ? Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.gridView,
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
              //Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return AppointmentWiget(
                    appointment:
                    AppAppointments.fromFirestore(documentSnapshot[index]),
                    loggedUser: currentUser == null ? null : user,
                    theme: theme);
              },
              query: FirebaseFirestore.instance
                  .collection(Paths.appAppointments)
                  .where('consult.uid', isEqualTo: user.uid)
                  .where('appointmentStatus', isEqualTo: "open")
                  .orderBy('timestamp', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          )
              : SizedBox(),
          (wait == true && load == false)
              ? Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.gridView,
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
              //Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return AppointmentWiget(
                    appointment:
                    AppAppointments.fromFirestore(documentSnapshot[index]),
                    loggedUser: currentUser == null ? null : user,
                    theme: theme);
              },
              query: FirebaseFirestore.instance
                  .collection(Paths.appAppointments)
                  .where('consult.uid', isEqualTo: user.uid)
                  .where('appointmentStatus', isEqualTo: "new")
                  .orderBy('timestamp', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          )
              : SizedBox(),
          load ? CircularProgressIndicator() : SizedBox()
        ],
      ),
      Positioned(
        right: 0.0,
        top: (size.height * .24), //140.0,
        left: 0,
        child: Center(
          child: user==null?loadVerificationCode():Container(
              height: 50,
              width: size.width * .9,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 0.0),
                    blurRadius: 15.0,
                    spreadRadius: 2.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      splashColor: AppColors.pink.withOpacity(0.5),
                      onTap: () {
                        setState(() {
                          wait = true;
                          fixed = false;
                          query = FirebaseFirestore.instance
                              .collection(Paths.appAppointments)
                              .where('consult.uid', isEqualTo: user.uid)
                              .where('appointmentStatus', isEqualTo: "new")
                              .orderBy('timestamp', descending: true);
                        });
                      },
                      child: Container(
                        height: 40,
                        width: size.width * .4,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: wait
                              ? theme == "light"
                              ? Theme.of(context).primaryColor
                              : Colors.black
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: Text(
                            getTranslated(context, "wait"),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              color: wait
                                  ? theme == "light"
                                  ? Colors.white
                                  : Colors.white
                                  : theme == "light"
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                            fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      splashColor: AppColors.pink.withOpacity(0.5),
                      onTap: () {
                        setState(() {
                          fixed = true;
                          wait = false;
                          query = FirebaseFirestore.instance
                              .collection(Paths.appAppointments)
                              .where('consult.uid', isEqualTo: user.uid)
                              .where('appointmentStatus', isEqualTo: "open")
                              .orderBy('timestamp', descending: true);
                        });
                      },
                      child: Container(
                        height: 40,
                        width: size.width * .4,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: fixed
                              ? theme == "light"
                              ? Theme.of(context).primaryColor
                              : Colors.black
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: Text(
                            getTranslated(context, "fixed"),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              color: fixed
                                  ? theme == "light"
                                  ? Colors.white
                                  : Colors.white
                                  : theme == "light"
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                            fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ])),
        ),
      ),
    ]);
  }
  Widget loadVerificationCode()
  {
    return Shimmer.fromColors(
        period: Duration(milliseconds: 800),
        baseColor: Colors.grey.withOpacity(0.5),
        highlightColor: Colors.black.withOpacity(0.5),
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width*.9,
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30.0),
          ),
        ));
  }


  @override
  bool get wantKeepAlive => true;
  registerUser() {
    print("voip- service init");
    register();
    TwilioVoice.instance.setOnDeviceTokenChanged((token) {
      print("voip-device token changed");
      register();
    });
  }
  register() async {
    print("voip-registtering with token ");
    print("voip-calling voice-accessToken");
    Map<dynamic, dynamic> callMap = {
      "platform": Platform.isIOS ? "iOS" : "Android",
      "userId": this.userId,
    };
    try {
      String url = "https://us-central1-app-jeras.cloudfunctions.net/accessToken";
      if (Platform.isIOS == true) {
        url = "https://us-central1-app-jeras.cloudfunctions.net/accessToken3"; //accessTokenIosDevelop";//accessToken3
      }
      var callIntentRes = await http.post(
        Uri.parse(url),
        body: callMap,
      );
      var callIntent = jsonDecode(callIntentRes.body);
      print(callIntent);

      if (callIntent['message'] != 'Success') {
        print("callError1" + callIntent['data']);
      } else {
        String token = callIntent['data'];
        String androidToken = null;
        if (Platform.isAndroid) {
          androidToken = await FirebaseMessaging.instance.getToken();
        } else {
          androidToken ="CachedDeviceToken"; //await FirebaseMessaging.instance.getAPNSToken();
        }
        TwilioVoice.instance
            .setTokens(accessToken: token, deviceToken: androidToken);
      }
    } catch (e) {
      print("callError" + e.toString());
    }
  }
  waitForLogin() {
    final auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((user) async {
      // print("authStateChanges $user");
      if (user == null) {
        print("user is anonomous");
        //await auth.signInAnonymously();
      } else if (!registered) {
        registered = true;
        this.userId = user.uid;
        registerUser();
        FirebaseMessaging.instance.requestPermission();
      }
    });
  }
  checkActiveCall() async {
    final isOnCall = await TwilioVoice.instance.call.isOnCall();
    print("checkActiveCall $isOnCall");
    if (isOnCall &&
        !hasPushedToCall &&
        TwilioVoice.instance.call.activeCall.callDirection ==
            CallDirection.incoming) {
      print("user is on call");
      pushToCallScreen();
      hasPushedToCall = true;
    }
  }
  void waitForCall() {
    checkActiveCall();
    TwilioVoice.instance.callEventsListener
      ..listen((event) {
        print("voip-onCallStateChanged $event");

        switch (event) {
          case CallEvent.answer:
            print("twillioAnsweredhome");

            //at this point android is still paused
            if (Platform.isIOS && state == null ||
                state == AppLifecycleState.resumed) {
              pushToCallScreen();
              hasPushedToCall = true;
            }
            break;
          case CallEvent.ringing:
            final activeCall = TwilioVoice.instance.call.activeCall;
            if (activeCall != null) {
              final customData = activeCall.customParams;
              if (customData != null) {
                print("voip-customData $customData");
              }
            }
            break;
        /* case CallEvent.declined:
            final activeCall = TwilioVoice.instance.call.activeCall;
            if(activeCall != null) {
              TwilioVoice.instance.call.hangUp().then((value) {
                hasPushedToCall = false;
              });
            } else {
              hasPushedToCall = false;
            }
            break;*/
          case CallEvent.connected:
            if (Platform.isAndroid &&
                TwilioVoice.instance.call.activeCall.callDirection ==
                    CallDirection.incoming) {
              if (state != AppLifecycleState.resumed) {
                TwilioVoice.instance.showBackgroundCallUI();
              } else if (state == null || state == AppLifecycleState.resumed) {
                pushToCallScreen();
                hasPushedToCall = true;
              }
            }
            break;
          case CallEvent.callEnded:
            hasPushedToCall = false;
            break;
          case CallEvent.returningCall:
            pushToCallScreen();
            hasPushedToCall = true;
            break;
          default:
            break;
        }
      });
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.state = state;
    print("didChangeAppLifecycleState");
    if (state == AppLifecycleState.resumed) {
      checkActiveCall();
    }
  }
  void pushToCallScreen() {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        fullscreenDialog: true, builder: (context) => VoiceCallScreen()));
  }
  checkAvaliable() async {
    var dateUtc = DateTime.now().toUtc();
    var strToDateTime = DateTime.parse(dateUtc.toString());
    final convertLocal = strToDateTime.toLocal();
    print(dateUtc);
    print(strToDateTime);
    print(convertLocal);
    print(convertLocal.hour);
    if (user != null &&
        user.userType == "CONSULTANT" &&
        user.profileCompleted) {
      String dayNow = _now.weekday.toString();
      int timeNow = _now.hour;
      if (user.workDays.contains(dayNow)) {
        if (int.parse(user.workTimes[0].from) <= timeNow &&
            int.parse(user.workTimes[0].to) > timeNow) {
          setState(() {
            avaliable = true;
          });
        }
      }
    }
   /* if (user != null) {
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(user.uid)
          .set({
        'userLang': getTranslated(context, "lang"),
      }, SetOptions(merge: true));
    }*/
  }
  Future<void> getTitle() async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(Paths.settingPath)
        .doc("pzBqiphy5o2kkzJgWUT7");
    final DocumentSnapshot documentSnapshot = await docRef.get();
    if (mounted)
      setState(() {
        setting = Setting.fromFirestore(documentSnapshot);
      });
  }
//---------------------------test methods-------------------------------
  Future<void> test() async {
    try {

    } catch (e) {
      print("ddeeesss" + e.toString());
    }
  }

  Future<void> updateData() async {
    try {
      int x123 = 0;
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where("Tahani2", isEqualTo: true)
          .get();
      print("startupdateData");
      print(querySnapshot.docs.length);
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        print(data['name']);
        print(doc.id);
        List<Map> intrList = [];
        List<String> indexList = [];
        if (data['timeAvailable'] != null) {
          print("gggggggdddddd");
          print(data['timeAvailable']['from']);
          print(double.parse(data['timeAvailable']['from'].toString())
              .toStringAsFixed(0));
          print("ggggggg");
          print(double.parse(data['timeAvailable']['to'].toString())
              .toStringAsFixed(0));

          Map tempAdd = Map();
          tempAdd.putIfAbsent(
              'from',
                  () => double.parse(data['timeAvailable']['from'].toString())
                  .toStringAsFixed(0));
          tempAdd.putIfAbsent(
              'to',
                  () => double.parse(data['timeAvailable']['to'].toString())
                  .toStringAsFixed(0));
          intrList.add(tempAdd);
        }
        List<dynamic> daysValue = [];
        if (data['selectedDays'] != null && data['selectedDays'].length > 0) {
          if (data['selectedDays'].toString().contains("Monday")) {
            daysValue.add("1");
          }
          if (data['selectedDays'].toString().contains("Tuesday")) {
            daysValue.add("2");
          }
          if (data['selectedDays'].toString().contains("Wednesday")) {
            daysValue.add("3");
          }
          if (data['selectedDays'].toString().contains("Thursday")) {
            daysValue.add("4");
          }
          if (data['selectedDays'].toString().contains("Saturday")) {
            daysValue.add("5");
          }
          if (data['selectedDays'].toString().contains("Sunday")) {
            daysValue.add("6");
          }
          if (data['selectedDays'].toString().contains("Friday")) {
            daysValue.add("7");
          }
        }
        if (data['name'] != null) {
          List<String> splitList = data['name'].split(" ");
          for (int i = 0; i < splitList.length; i++) {
            for (int y = 1; y < splitList[i].length; y++) {
              indexList.add(splitList[i].substring(0, y).toLowerCase());
            }
          }
          print(indexList);
        }
        var newUserData = {
          'accountStatus':
          data['accountActivated'] == true ? "Active" : "NotActive",
          'userLang': 'ar',
          'profileCompleted': true,
          'isBlocked': false,
          'uid': doc.id,
          'name': data['name'],
          'bio': data['bio'],
          'email': data['email'],
          'phoneNumber': data['phoneNumber'] == null ? "" : data['phoneNumber'],
          'photoUrl': data['photoUrl'],
          'tokenId': "",
          'loggedInVia': "mobile",
          "userType": data['userType'],
          "languages": data['languageSpeak'] == "both"
              ? ["English", "العربية"]
              : data['languageSpeak'] == "english"
              ? ["English"]
              : ["العربية"],
          'price': data["pricePerCall"] == null
              ? "0"
              : double.parse(data['pricePerCall'].toString())
              .toStringAsFixed(0),
          "rating": 0.0,
          "reviewsCount": 0,
          "balance": 0.0,
          "payedBalance": 0.0,
          "ordersNumbers": 0,
          "chat": true,
          "voice": true,
          "userConsultIds": null,
          "order": 0,
          "countryCode": "",
          "countryISOCode": "",
          'workDays': daysValue,
          'workTimes': intrList,
          'searchIndex': indexList,
          "createdDate": Timestamp.now(),
          "createdDateValue": DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .millisecondsSinceEpoch,
        };
        DocumentReference ref =
        FirebaseFirestore.instance.collection(Paths.usersPath).doc(doc.id);
        ref.set(newUserData, SetOptions(merge: true));
        final DocumentSnapshot currentDoc = await ref.get();
        var selecteduser = GroceryUser.fromFirestore(currentDoc);

        //create chat
        String SupportListId = Uuid().v4();
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(SupportListId)
            .set({
          'supportListId': SupportListId,
          'supportListStatus': true,
          'messageTime': FieldValue.serverTimestamp(),
          'owner': selecteduser.userType,
          'userUid': selecteduser.uid,
          'userName': selecteduser.name,
          'userMessageNum': 0,
          'supportMessageNum': 0,
          'lastMessage': ".",
        });
        //appanalysis
        await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(selecteduser.uid)
            .set({
          'supportListId': SupportListId,
        }, SetOptions(merge: true));
        if (selecteduser.userType == "CONSULTANT" &&
            selecteduser.accountStatus == "NotActive") {
          await FirebaseFirestore.instance
              .collection(Paths.appAnalysisPath)
              .doc("TgWCp3B22sbkl0Nm3wLx")
              .set({
            'allUsers': FieldValue.increment(1),
            'notActiveConsult': FieldValue.increment(1),
          }, SetOptions(merge: true));
        } else if (selecteduser.userType == "CONSULTANT" &&
            selecteduser.accountStatus == "Active") {
          await FirebaseFirestore.instance
              .collection(Paths.appAnalysisPath)
              .doc("TgWCp3B22sbkl0Nm3wLx")
              .set({
            'allUsers': FieldValue.increment(1),
            'activeConsult': FieldValue.increment(1),
          }, SetOptions(merge: true));
        } else if (selecteduser.userType == "USER") {
          await FirebaseFirestore.instance
              .collection(Paths.appAnalysisPath)
              .doc("TgWCp3B22sbkl0Nm3wLx")
              .set({
            'allUsers': FieldValue.increment(1),
            'usersNum': FieldValue.increment(1),
          }, SetOptions(merge: true));
        } else {
          await FirebaseFirestore.instance
              .collection(Paths.appAnalysisPath)
              .doc("TgWCp3B22sbkl0Nm3wLx")
              .set({
            'allUsers': FieldValue.increment(1),
            'supportNum': FieldValue.increment(1),
          }, SetOptions(merge: true));
        }

        //packages
        if (selecteduser.userType == "CONSULTANT" &&
            selecteduser.accountStatus == "Active" &&
            selecteduser.price != null &&
            selecteduser.price != "0") {
          var packageId1 = Uuid().v4();
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId1)
              .set({
            'price': int.parse(selecteduser.price.toString()),
            'discount': 0,
            'callNum': 1,
            'consultUid': selecteduser.uid,
            'Id': packageId1,
            'active': true,
          }, SetOptions(merge: true));
          print("kkkkkkk");
          //package2  3calls--5%discount
          var discount2 = ((3 * int.parse(selecteduser.price)) * 5) / 100;
          double price2 = (3 * int.parse(selecteduser.price)) - discount2;

          var packageId2 = Uuid().v4();
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId2)
              .set({
            'price': int.parse(price2.toStringAsFixed(0)),
            'discount': 5,
            'callNum': 3,
            'consultUid': selecteduser.uid,
            'Id': packageId2,
            'active': true,
          }, SetOptions(merge: true));

          //package3  5calls--10%discount
          var discount3 = ((5 * int.parse(selecteduser.price)) * 10) / 100;
          double price3 = (5 * int.parse(selecteduser.price)) - discount3;

          var packageId3 = Uuid().v4();
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId3)
              .set({
            'price': int.parse(price3.toStringAsFixed(0)),
            'discount': 10,
            'callNum': 5,
            'consultUid': selecteduser.uid,
            'Id': packageId3,
            'active': true,
          }, SetOptions(merge: true));

          //package4  20calls--25%discount
          var discount4 = ((20 * int.parse(selecteduser.price)) * 25) / 100;
          double price4 = (20 * int.parse(selecteduser.price)) - discount4;

          var packageId4 = Uuid().v4();
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId4)
              .set({
            'price': int.parse(price4.toStringAsFixed(0)),
            'discount': 25,
            'callNum': 20,
            'consultUid': selecteduser.uid,
            'Id': packageId4,
            'active': true,
          }, SetOptions(merge: true));
        }
        x123++;
      }
      print("updatefinsshed");
      print(x123);
    } catch (e) {
      print("tttttttttt" + e.toString());
    }
  }

  testAppointment() async {
    try {
      int x=0;
      var querySnapshot = await FirebaseFirestore.instance
          .collection('SupportList')
          .get();
      print(querySnapshot.docs.length);
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        print(data['supportListId']);
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(data['supportListId'])
            .set({ 'openingStatus': false,}, SetOptions(merge: true));
        x++;
      }
      print("usersssssss1finished");
      print(x);
    } catch (e) {
      print("jjjjjjj" + e.toString());
    }
  }

  count() async {
    try {
      var collection = FirebaseFirestore.instance.collection('users');
      var querySnapshot =
      await collection.where("filter3", isEqualTo: true).get();
      var x = querySnapshot.docs.length;
      print(x);
    } catch (e) {
      print("jjjjjjj" + e.toString());
    }
  }

  updateCountryCode() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where("filter3", isEqualTo: true)
          .get();
      print("usersssssss1");
      print(querySnapshot.docs.length);
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        print(data['name']);
        print(data['phoneNumber']);
        String phone = data['phoneNumber'];
        if (phone.contains('+20'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+20',
          }, SetOptions(merge: true));
        else if (phone.contains('+254')) //keny
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+254',
          }, SetOptions(merge: true));
        else if (phone.contains('+1')) //usa
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+1',
          }, SetOptions(merge: true));
        else if (phone.contains('+31'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+31',
          }, SetOptions(merge: true));
        else if (phone.contains('+33'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+33',
          }, SetOptions(merge: true));
        else if (phone.contains('+45'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+45',
          }, SetOptions(merge: true));
        else if (phone.contains('+46'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+46',
          }, SetOptions(merge: true));
        else if (phone.contains('+60'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+60',
          }, SetOptions(merge: true));
        else if (phone.contains('+61'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+61',
          }, SetOptions(merge: true));
        else if (phone.contains('+905'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+905',
          }, SetOptions(merge: true));
        else if (phone.contains('+919'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+919',
          }, SetOptions(merge: true));
        else if (phone.contains('+923'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+923',
          }, SetOptions(merge: true));
        else if (phone.contains('+965'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+965',
          }, SetOptions(merge: true));
        else if (phone.contains('+968'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+968',
          }, SetOptions(merge: true));
        else if (phone.contains('+971'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '‎+971',
          }, SetOptions(merge: true));
        else if (phone.contains('+973'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '‎+973',
          }, SetOptions(merge: true));
        else if (phone.contains('+974'))
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '‎+974',
          }, SetOptions(merge: true));
        else if (phone.contains('+44')) //uk
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+44',
          }, SetOptions(merge: true));
        else
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'countryCode': '+966',
          }, SetOptions(merge: true));
      }
    } catch (e) {
      print("jjjjjjj" + e.toString());
    }
  }

  updateZahem() async {
    try {
      print("doneeeee00");
      //===delete orders
      var querySnapshot = await FirebaseFirestore.instance
          .collection("SupportMessage")
         // .where('consult.phone', isEqualTo: "+201001066938")
          .where('supportId', isEqualTo: "596355a6-14e5-467e-b6d1-40ce37df9d88")
          .get();
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection("SupportMessage")
            .doc(doc.id)
            .delete();
      }
      ///////--------delete appointment
     /* var querySnapshot2 = await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .where('consult.phone', isEqualTo: "+201001066938")
          .get();
      for (var doc in querySnapshot2.docs) {
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(doc.id)
            .delete();
      }*/
      print("doneeeee");
    } catch (e) {
      print("jjjjjjjkkkk" + e.toString());
    }
  }
}
