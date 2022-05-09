// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/screens/completeUserProfile.dart';
import 'package:grocery_store/screens/dashboard.dart';
import 'package:grocery_store/screens/notification_screen.dart';
import 'package:grocery_store/screens/searchScreen.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:grocery_store/widget/userAppointmentWiget.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:shimmer/shimmer.dart';

class AppointmentsPage extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with AutomaticKeepAliveClientMixin<AppointmentsPage> {
  final TextEditingController searchController = new TextEditingController();

  SigninBloc signinBloc;
  User currentUser;
  AccountBloc accountBloc;
  GroceryUser user;
  bool load=true;
  String lang, userImage, theme;
  NotificationBloc notificationBloc;
  UserNotification userNotification;
  bool fixed = true,wait = false,closed=false;
  bool active = false;
  Query query;

  @override
  void initState() {
    super.initState();
    signinBloc = BlocProvider.of<SigninBloc>(context);
    accountBloc = BlocProvider.of<AccountBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    load = true;
    signinBloc.listen((state) {
      if (state is GetCurrentUserCompleted) {
        currentUser = state.firebaseUser;
        accountBloc.add(GetAccountDetailsEvent(currentUser.uid));
      }
    });
    accountBloc.listen((state) {
      print(state);
      if (state is GetAccountDetailsCompletedState) {
        user = state.user;
        if (mounted)
          setState(() {
            load = false;
          });
        if (user != null && user.photoUrl != null && user.photoUrl != "")
          if (mounted)
          setState(() {
            userImage = user.photoUrl;
          });
      }
    });
    signinBloc.add(GetCurrentUser());
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Signing out..\nPlease wait!',
        );
      },
    );
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

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.red.shade500,
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
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
              height: size.height*.28,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child:  Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
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
                            else {}
                          },
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: userImage == null
                                ? //whiteLogo.png
                            //Image.asset('assets/applicationIcons/whiteLogo.png')
                            Image.asset(
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
                                placeholderScale: 0.5,
                                imageErrorBuilder:
                                    (context, error, stackTrace) => Icon(
                                  Icons.person,
                                  color: Colors.black,
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
                          )),
                    ),
                    SizedBox(height: 5,),
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
                            if (state
                            is GetAllNotificationsInProgressState) {
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
                                      child: Image.asset(theme == "light"
                                          ? 'assets/applicationIcons/lightNotification.png'
                                          : 'assets/applicationIcons/darkNotification.png'),
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
                                    borderRadius:
                                    BorderRadius.circular(50.0),
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
                                          child: Image.asset(theme ==
                                              "light"
                                              ? 'assets/applicationIcons/lightNotification.png'
                                              : 'assets/applicationIcons/darkNotification.png'),
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
                                            splashColor: Colors.white
                                                .withOpacity(0.5),
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
                                              child: Image.asset(theme ==
                                                  "light"
                                                  ? 'assets/applicationIcons/lightNotification.png'
                                                  : 'assets/applicationIcons/darkNotification.png'),
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
                                      showNoNotifSnack(getTranslated(
                                          context, "noNotification"));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      width: 25.0,
                                      height: 25.0,
                                      child: Image.asset(theme == "light"
                                          ? 'assets/applicationIcons/lightNotification.png'
                                          : 'assets/applicationIcons/darkNotification.png'),
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
                                    child: Image.asset(theme == "light"
                                        ? 'assets/applicationIcons/lightNotification.png'
                                        : 'assets/applicationIcons/darkNotification.png'),
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
                            color: theme=="light"?Colors.white:Color(0xff3f3f3f),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: TextField(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SearchScreen(loggedUser: user),
                                ),
                              );
                            },
                            keyboardType: TextInputType.text,
                            controller: searchController,
                            textInputAction: TextInputAction.search,
                            enableInteractiveSelection: true,
                            readOnly: true,
                            style: GoogleFonts.cairo(
                              fontSize: 14.5,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 8.0),
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
            SizedBox(
              height: 30,
            ),
            load
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SizedBox(),
            (load == false && fixed)
                ? Expanded(
                    child: PaginateFirestore(
                      itemBuilderType: PaginateBuilderType.listView,
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
                      //Change types accordingly
                      itemBuilder: ( context, documentSnapshot,index) {
                        return UserAppointmentWiget(
                          appointment:
                              AppAppointments.fromFirestore(documentSnapshot[index]),
                          loggedUser: currentUser == null ? null : user,
                          theme: theme,
                        );
                      },
                      query: FirebaseFirestore.instance
                          .collection(Paths.appAppointments)
                          .where('user.uid', isEqualTo: user.uid)
                          .where('appointmentStatus', isEqualTo: "open")
                          .orderBy('secondValue', descending: true),
                      isLive: true,
                    ),
                  )
                : SizedBox(),
            (load == false && wait)
                ? Expanded(
                    child: PaginateFirestore(
                      itemBuilderType: PaginateBuilderType.listView,
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
                      //Change types accordingly
                      itemBuilder: ( context, documentSnapshot,index) {
                        return UserAppointmentWiget(
                          appointment:
                              AppAppointments.fromFirestore(documentSnapshot[index]),
                          loggedUser: currentUser == null ? null : user,
                          theme: theme,
                        );
                      },
                      query: FirebaseFirestore.instance
                          .collection(Paths.appAppointments)
                          .where('user.uid', isEqualTo: user.uid)
                          .where('appointmentStatus', isEqualTo: "new")
                          .orderBy('secondValue', descending: true),
                      isLive: true,
                    ),
                  )
                : SizedBox(),
            (load == false && closed)
                ? Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
                //Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return UserAppointmentWiget(
                    appointment:
                    AppAppointments.fromFirestore(documentSnapshot[index]),
                    loggedUser: currentUser == null ? null : user,
                    theme: theme,
                  );
                },
                query: FirebaseFirestore.instance
                    .collection(Paths.appAppointments)
                    .where('user.uid', isEqualTo: user.uid)
                    .where('appointmentStatus', isEqualTo: "closed")
                    .orderBy('secondValue', descending: true),
                isLive: true,
              ),
            )
                : SizedBox(),
          ],
        ),
        Positioned(
          right: 0.0,
          top: (size.height * .24),
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
                      blurRadius: 5.0,
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
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            fixed = true;
                            wait = false;
                            closed=false;
                            query = FirebaseFirestore.instance
                                .collection(Paths.appAppointments)
                                .where('user.uid', isEqualTo: user.uid)
                                .where('appointmentStatus', isEqualTo: "open")
                                .orderBy('secondValue', descending: true);
                          });
                        },
                        child: Container(
                          height: 40,
                          width: size.width * .25,
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
                                fontSize: 15.0,
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
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            wait = true;
                            fixed = false;
                            closed=false;
                            query = FirebaseFirestore.instance
                                .collection(Paths.appAppointments)
                                .where('user.uid', isEqualTo: user.uid)
                                .where('appointmentStatus', isEqualTo: "new")
                                .orderBy('secondValue', descending: true);
                          });
                        },
                        child: Container(
                          height: 40,
                          width: size.width * .25,
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
                                fontSize: 15.0,
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
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            wait = false;
                            fixed = false;
                            closed=true;
                            query = FirebaseFirestore.instance
                                .collection(Paths.appAppointments)
                                .where('user.uid', isEqualTo: user.uid)
                                .where('appointmentStatus', isEqualTo: "closed")
                                .orderBy('secondValue', descending: true);
                          });
                        },
                        child: Container(
                          height: 40,
                          width: size.width * .25,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: closed
                                ? theme == "light"
                                ? Theme.of(context).primaryColor
                                : Colors.black
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "closed"),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: closed
                                    ? theme == "light"
                                    ? Colors.white
                                    : Colors.white
                                    : theme == "light"
                                    ? Theme.of(context).primaryColor
                                    : Colors.black,
                                fontSize: 15.0,
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
      ]),
    );
  }
  Widget loadVerificationCode()
  {
    return Shimmer.fromColors(
        period: Duration(milliseconds: 800),
        baseColor: Colors.grey.withOpacity(0.5),
        highlightColor: Colors.black.withOpacity(0.5),
        child: Container(
          height: 50,
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
  checkAvaliable() async {
    if (user != null &&
        user.profileCompleted == false &&
        user.userType != "CONSULTANT") {
      {
        print("profileCompleted3");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteUserProfileScreen(user: user),
          ),
        );
      }
    } else {}
  }

  @override
  bool get wantKeepAlive => true;
}
