// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/screens/account_screen.dart';
import 'package:grocery_store/screens/completeConsultProfileScreen.dart';
import 'package:grocery_store/screens/dashboard.dart';
import 'package:grocery_store/screens/notification_screen.dart';
import 'package:grocery_store/widget/historyAppointmentWidget.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:shimmer/shimmer.dart';

class CallHistoryPage extends StatefulWidget {
  @override
  _CallHistoryPageState createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage>
    with AutomaticKeepAliveClientMixin<CallHistoryPage> {
  final TextEditingController searchController = new TextEditingController();

  SigninBloc signinBloc;
  User currentUser;
  AccountBloc accountBloc;
  GroceryUser user;
  bool load;
  String lang,userImage,theme;
  NotificationBloc notificationBloc;
  UserNotification userNotification;
  DateTime selectedDate = DateTime.now();
  bool avaliable=false;
  DateTime _now = DateTime.now();
   bool filter=false;
   String time;
   Query filterQuery;
  @override
  void initState() {
    super.initState();
    signinBloc = BlocProvider.of<SigninBloc>(context);
    accountBloc = BlocProvider.of<AccountBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    load=true;
    time="التصفية بحسب التاريخ";
    signinBloc.listen((state) {
      if (state is GetCurrentUserCompleted) {
        currentUser = state.firebaseUser;
        print(currentUser.uid);
        accountBloc.add(GetAccountDetailsEvent(currentUser.uid));
      }
    });
    accountBloc.listen((state) {
      print(state);
      if (state is GetAccountDetailsCompletedState) {
        user = state.user;
        if(mounted){
          checkAvaliable();
          setState(() {
            load=false;
          });
        }

        if(user!=null&&user.photoUrl!=null&&user.photoUrl!="")
          if(mounted)
            setState(() {
              userImage=user.photoUrl;
            });
        print(user.name);
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: InkWell(
                        splashColor:
                        Colors.white.withOpacity(0.5),
                        onTap: () {
                          if(user!=null&&user.userType=="CONSULTANT")
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountScreen(user:user,firstLogged:false), ),);
                          else{}
                        },
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: userImage==null ?
                          Image.asset(theme=="light"?
                          'assets/applicationIcons/whiteLogo.png':'assets/applicationIcons/whiteLogo.png',)
                              :ClipRRect(
                            borderRadius: BorderRadius.circular(70.0),
                            child: FadeInImage.assetNetwork(
                              placeholder:
                              theme=="light"?
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
                    ),
                    SizedBox(height:5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                        currentUser==null?ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor:
                              Colors.white.withOpacity(0.5),
                              onTap: () {
                                print('Notification11');
                                showNoNotifSnack(getTranslated(context, "noNotification"));
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
                        ):
                        BlocBuilder(
                          bloc: notificationBloc,
                          buildWhen: (previous, current) {
                            if (current is GetAllNotificationsInProgressState ||
                                current is GetAllNotificationsFailedState ||
                                current is GetAllNotificationsCompletedState ||
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
                                    splashColor: Colors.white.withOpacity(0.5),
                                    onTap: () {
                                      print('Notification');
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
                                if (state.userNotification.notifications.length ==
                                    0) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(50.0),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.5),
                                        onTap: () {
                                          print('Notification');
                                          showNoNotifSnack(getTranslated(context, "noNotification"));

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
                                userNotification = state.userNotification;
                                return Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Positioned(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50.0),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            splashColor:
                                            Colors.white.withOpacity(0.5),
                                            onTap: () {
                                              print('Notification');
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
                                                        userNotification:userNotification,
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
                                              child: Image.asset(theme == "light"
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
                                      print('Notification');
                                      showNoNotifSnack(getTranslated(context, "noNotification"));
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
                                    showNoNotifSnack(getTranslated(context, "noNotification"));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    width: 38.0,
                                    height: 35.0,
                                    child: Image.asset(theme=="light"?
                                    'assets/applicationIcons/Iconly-Two-tone-Notification.png':'assets/applicationIcons/Iconly-Two-tone-Notification.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        Container(
                          height: 35.0,
                          width: size.width*.50,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 1.0, vertical: 0.0),
                          decoration: BoxDecoration(
                            color: avaliable?AppColors.brown:AppColors.grey,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child:Center(
                            child: Text(
                              avaliable?getTranslated(context, "available"):getTranslated(context, "notAvailable"),
                              style: GoogleFonts.cairo(
                                fontSize: 14.0,
                                color:AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardScreen(), ),  );
                          },
                          icon: Image.asset(theme=="light"?
                          'assets/applicationIcons/Iconly-Curved-Category.png' : 'assets/applicationIcons/dashbord.png',
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
            SizedBox(height: 50,),
            InkWell(
              splashColor:
              Colors.white.withOpacity(0.5),
              onTap: () {
               setState(() {
                 filter=false;
                 time= getTranslated(context, "filter");
               });
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20),
                    child: Container(height: 35,width: size.width*.4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child:Center(
                        child: Text(
                          getTranslated(context, "allAppointment"),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color:theme=="light"?AppColors.white:Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            load?Center(child: CircularProgressIndicator(),):SizedBox(),
            (load)==false&&filter==false? Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  HistoryAppointmentWiget(
                    appointment: AppAppointments.fromFirestore(documentSnapshot[index]),
                    loggedUser: currentUser==null?null:user,
                    theme:theme,
                  );
                },
                query:FirebaseFirestore.instance.collection(Paths.appAppointments)
                    .where('consult.uid', isEqualTo: user.uid)
                    .where('appointmentStatus', isEqualTo: "closed")
                    .orderBy('secondValue', descending: true),
                isLive: true,
              ),
            ):SizedBox(),
            (load)==false&&filter? Expanded(
              child: PaginateFirestore(
                key: ValueKey(filterQuery),
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  HistoryAppointmentWiget(
                    appointment: AppAppointments.fromFirestore(documentSnapshot[index]),
                    loggedUser: currentUser==null?null:user,
                    theme:theme
                  );
                },
                query:filterQuery,
                isLive: true,
              ),
            ):SizedBox(),

          ],
        ),
        Positioned(
          right: 0.0,
          top: (size.height * .24) ,
          left: 0,
          child:  Center(child: user==null?loadVerificationCode():Container(height: 60,width: size.width*.9,child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 50,width: size.width*.7,
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
                child:Center(
                  child: Text(
                   time,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color:Colors.grey,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              InkWell(
                splashColor:
                Colors.white.withOpacity(0.5),
                onTap: () {
                  _selectDate(context);
                },
                child: Container(
                    height: 40,width:40,
                    decoration: new BoxDecoration(
                      color: AppColors.brown,

                      //color: Colors.white,
                      shape: BoxShape.circle,
                    ),child:Icon( Icons.date_range,size:25,
                  color: Colors.white,)
                  /*Container(height: 20,width:20,
                      child: Image.asset(theme=="light"?
                'assets/applicationIcons/Iconly-Two-tone-Calendar-1.png':'assets/applicationIcons/Iconly-Two-tone-Calendar.png',

                ),
                    )*/
                ),
               /* Icon( Icons.calendar_today_outlined,size:25,
                  color: Colors.black,)
                ),*/
              ),
            ],
          ),),)
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
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        print("_selectDate");
        print(selectedDate);
        int month=selectedDate.month;
        int day=selectedDate.day;
        print(month);
        print(day);
        filterQuery=FirebaseFirestore.instance.collection(Paths.appAppointments)
            .where('consult.uid', isEqualTo: user.uid)
            .where('appointmentStatus', isEqualTo: "closed")
            .where('date.month', isEqualTo:month)
            .where('date.day', isEqualTo:day)
            .orderBy('secondValue', descending: true);
        time= selectedDate.toString().substring(0,10);
        filter=true;
      });
  }
  checkAvaliable() async {
/*    if(user!=null&&user.profileCompleted==false&&user.userType=="CONSULTANT") {
      print("profileCompleted2");
      Navigator.push( context, MaterialPageRoute(
        builder: (context) => CompleteConsultProfileScreen(user: user),),);
    }

    else*/
    if(user!=null&&user.userType=="CONSULTANT"&&user.profileCompleted)
    {
      String dayNow=_now.weekday.toString();
      int timeNow=_now.hour;
      if(user.workDays.contains(dayNow))
      {
        if (int.parse(user.workTimes[0].from )<=timeNow&&int.parse(user.workTimes[0].to )>timeNow) {
          setState(() {
            avaliable=true;
          });

        }
      }
    }

  }
  @override
  bool get wantKeepAlive => true;
}
