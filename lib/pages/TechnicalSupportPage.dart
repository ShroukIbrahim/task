// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/SupportList.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/screens/account_screen.dart';
import 'package:grocery_store/screens/completeConsultProfileScreen.dart';
import 'package:grocery_store/screens/completeUserProfile.dart';
import 'package:grocery_store/screens/dashboard.dart';
import 'package:grocery_store/screens/notification_screen.dart';
import 'package:grocery_store/screens/searchScreen.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/widget/supportListItem.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class TechnicalSupportPage extends StatefulWidget {
  @override
  _TechnicalSupportPageState createState() => _TechnicalSupportPageState();
}

class _TechnicalSupportPageState extends State<TechnicalSupportPage> with AutomaticKeepAliveClientMixin<TechnicalSupportPage> {
  final TextEditingController searchController = new TextEditingController();
  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();

  SigninBloc signinBloc;
  User currentUser;
  AccountBloc accountBloc;
  GroceryUser user;
  bool load;
  bool avaliable=false;
  DateTime _now = DateTime.now();
 String lang,userImage,theme;
  String name ="";
  Query filterQuery;
  NotificationBloc notificationBloc;
  UserNotification userNotification;
  @override
  void initState() {
    super.initState();
    signinBloc = BlocProvider.of<SigninBloc>(context);
    accountBloc = BlocProvider.of<AccountBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    load=true;
    signinBloc.listen((state) {
      if (state is GetCurrentUserCompleted) {
        currentUser = state.firebaseUser;
        print(currentUser.uid);
        accountBloc.add(GetAccountDetailsEvent(currentUser.uid));
      }
    });
    accountBloc.listen((state) {
      print(state);
      print("user2");
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
        initiateSearch(name);
      }
    });
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
    lang=getTranslated(context, "lang");

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
                          else if(user!=null&&user.userType!="CONSULTANT")
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserAccountScreen(user:user,firstLogged:false), ),);
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
                          'assets/applicationIcons/whiteLogo.png':'assets/applicationIcons/whiteLogo.png',
                          )
                              :ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: FadeInImage.assetNetwork(
                              placeholder: theme=="light"?'assets/applicationIcons/whiteLogo.png':'assets/applicationIcons/whiteLogo.png',
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
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[

                        currentUser==null?ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor:
                              Colors.white.withOpacity(0.5),
                              onTap: () {
                                print('Notificationsssssss');
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
                            print("nnnnnn");
                            print(state);
                            if (state is GetAllNotificationsInProgressState) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: Colors.white.withOpacity(0.5),
                                    onTap: () {
                                      print('Notificationllllllll'); showNoNotifSnack(getTranslated(context, "noNotification"));
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
                                          print('Notificationddddd');
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
                                                        userNotification: userNotification,
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
                                      print('Notificationgggggg');
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
                        load?SizedBox(width: size.width*.3,):user.userType!="CONSULTANT"?  Container(
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
                        ):
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
            SizedBox(height: 20,),
            load?Center(child: CircularProgressIndicator(),):Expanded(
              child: RefreshIndicator(
                child: PaginateFirestore(
                  key: ValueKey(filterQuery),
                  itemBuilderType: PaginateBuilderType.listView,
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                  itemBuilder: ( context, documentSnapshot,index) {
                    return  SupportListItem(
                      size:size,
                      item: SupportList.fromFirestore(documentSnapshot[index]),
                      user:user,
                      theme:theme,
                    );

                  },
                  query: filterQuery,
                  listeners: [
                    refreshChangeListener,
                  ],
                  isLive: true,
                ),
                onRefresh: () async {
                  refreshChangeListener.refreshed = true;
                },
              ),
            )
          ],
        ),
        (user!=null&&user.userType=="SUPPORT")?  Positioned(
            right: 0.0,
            top: size.height*.24,
            left: 0,
            child:  Center(child: Container(height: 50,width: size.width*.9,child:
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 40,width: size.width*.15,
                  decoration: new BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,),
                  child: InkWell(
                      child: Icon(Icons.wifi_protected_setup, size: 18,color: AppColors.pink,), onTap: () {
                    closeAll();
                  }),
                ),
                Container(height: 40,width: size.width*.7,
                  padding: const EdgeInsets.symmetric( horizontal: 1.0, vertical: 0.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 0.0),
                        blurRadius: 15.0,
                        spreadRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      //onChanged: (val) => initiateSearch(val),
                      keyboardType: TextInputType.text,
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      enableInteractiveSelection: true,
                      readOnly:false,
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                        prefixIcon:Icon(Icons.search, size: 14,color:AppColors.pink),
                        suffixIcon: InkWell(
                            child: Icon(Icons.send_rounded, size: 14), onTap: () {
                          initiateSearch(searchController.text);
                        }),
                        border: InputBorder.none,
                        hintText: getTranslated(context, "name"),
                        hintStyle: GoogleFonts.cairo(
                          fontSize: 14.5,
                          color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),)
        ):SizedBox(),
      ]),
    );
  }
  closeAll() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.supportListPath)
          .where('openingStatus', isEqualTo: true)
          .get();
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection(Paths.supportListPath)
            .doc(doc.id)
            .update({
          'openingStatus': false,
        });
      }
    } catch (e) {
      print("jjjjjjjkkkk" + e.toString());
    }
  }
  void initiateSearch(String val) {
    if( user.userType=="SUPPORT"&&val=="")
      setState(() {
        filterQuery=FirebaseFirestore.instance.collection('SupportList')
            .orderBy('messageTime', descending: true);
      });
    else if( user.userType=="SUPPORT"&&val!="")
      setState(() {
        filterQuery=FirebaseFirestore.instance.collection('SupportList')
          .where('userName', isEqualTo: val)
        // .where('searchIndex', arrayContains: val)
        .orderBy('messageTime', descending: true);
      });
    else
      setState(() {
        filterQuery= FirebaseFirestore.instance.collection('SupportList')
            .where('userUid', isEqualTo: user.uid)
            .orderBy('messageTime', descending: true);
      });


  }

  checkAvaliable() async {

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
