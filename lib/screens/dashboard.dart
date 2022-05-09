// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/setting.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/addFakeReview.dart';
import 'package:grocery_store/screens/myOrderScreen.dart';
import 'package:grocery_store/screens/privecy_screen.dart';
import 'package:grocery_store/screens/promoCodesScreens/allPromoCodesScreen.dart';
import 'package:grocery_store/screens/push_notifications_screens/AllSendedNotification.dart';
import 'package:grocery_store/screens/reviews_screen.dart';
import 'package:grocery_store/screens/techUserDetails/userDetailsScreen.dart';
import 'package:grocery_store/screens/technicalAppointment/allAppointmentScreen.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:grocery_store/screens/walletScreen.dart';
import 'package:grocery_store/widget/processing_dialog.dart';

import '../main.dart';
import 'DevelopTechSupport/allDevelopSupport.dart';
import 'aboutUsScreen.dart';
import 'account_screen.dart';
import 'addGrantsScreen.dart';
import 'consultPaymentHistoryScreen.dart';
import 'suggestionScreen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PageController _pageController = PageController(initialPage: 0);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController listScrollController = new ScrollController();
  bool load = false, wrongNumber = false;
  TextEditingController searchController = new TextEditingController();
  SigninBloc signinBloc;
  AccountBloc accountBloc;
  User currentUser;
  GroceryUser user;
  bool isSigningOut;
  String theme="light", lang, appTitle;
  ThemeData _theme;
  bool small = true;
  Setting setting;
  String userName = null, userImage = null;
  ThemeData _light = ThemeData.light().copyWith(
    primaryColor: Color(0xFF9D3A82),
  );
  ThemeData _dark = ThemeData.dark().copyWith(
    primaryColor: Color(0xFFFFFFFF),
  );

  @override
  void initState() {
    super.initState();
    print("DashboardScreen");
    signinBloc = BlocProvider.of<SigninBloc>(context);
    accountBloc = BlocProvider.of<AccountBloc>(context);
    getTitle();
    isSigningOut = false;

    signinBloc.listen((state) {
      if (state is GetCurrentUserCompleted) {
        if (mounted) {
          currentUser = state.firebaseUser;
          if (currentUser != null) {
            accountBloc.add(GetAccountDetailsEvent(currentUser.uid));
          } else {
            user = null;
          }
        }
      }
      if (state is GetCurrentUserInProgress) {
        showUpdatingDialog();
      }
      if (state is SignoutInProgress) {
        //show dialog
        if (isSigningOut) {
          showUpdatingDialog();
        }
      }
      if (state is SignoutFailed) {
        //show failed dialog
        if (isSigningOut) {
          showSnack('Failed to sign out!', context);
          isSigningOut = false;
        }
      }
      if (state is SignoutCompleted) {
        //take to splash screen
        print("settinglogout");
        if (isSigningOut) {
          isSigningOut = false;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/RegisterTypeScreen',
            (route) => false,
          );
          /* Navigator.pushNamedAndRemoveUntil(
            context, '/sign_in',(route) => false,
          );*/

        }
      }
    });

    accountBloc.listen((state) {
      print(state);
      if (state is GetAccountDetailsCompletedState) {
        print("dashbord GetAccountDetailsCompletedState");

        var result = state.user;
        if (result != null) {
          if (mounted) {
            setState(() {
              user = state.user;
            });
            if (user != null && user.name != "" && user.name != null)
              setState(() {
                userName = user.name;
              });
            if (user != null && user.photoUrl != "" && user.photoUrl != null)
              setState(() {
                userImage = user.photoUrl;
              });
          }
        } else {
          print("dashbord null user");
        }
        // Navigator.pop(context);
      }
    });
    signinBloc.add(GetCurrentUser());
    // accountBloc.add(getAllConsultationsEvent());
  }

  @override
  void didChangeDependencies() {
    getTheme().then((theme) {
      setState(() {
        this._theme = theme;
      });
    });
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
          message: getTranslated(context, "load"),
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme == "light" ? AppColors.white : AppColors.black,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        splashColor: Colors.white.withOpacity(0.5),
                        onTap: () {
                          if (user != null && user.userType == "CONSULTANT")
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountScreen(
                                    user: user, firstLogged: false),
                              ),
                            );
                          else if (user != null &&
                              user.userType != "CONSULTANT")
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserAccountScreen(
                                    user: user, firstLogged: false),
                              ),
                            );
                          else {}
                        },
                        child: Image.asset(
                          theme != "light"
                              ? 'assets/applicationIcons/whiteLogo.png'
                              : 'assets/applicationIcons/whiteLogo.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                      lang == "ar"
                          ? Row(
                              children: [
                                IconButton(
                                  iconSize: 30,
                                  onPressed: () async {
                                    if (lang == "ar") {
                                      await setLocale("en");
                                      Locale _temp = Locale("en", 'US');
                                      if (user != null) {
                                        await FirebaseFirestore.instance
                                            .collection(Paths.usersPath)
                                            .doc(user.uid)
                                            .set({
                                          'userLang': "en",
                                        }, SetOptions(merge: true));
                                        accountBloc.add(
                                            GetAccountDetailsEvent(user.uid));
                                      }
                                      MyApp.setLocale(context, _temp);
                                    } else {
                                      await setLocale("ar");
                                      Locale _temp = Locale("ar", 'AR');
                                      if (user != null) {
                                        await FirebaseFirestore.instance
                                            .collection(Paths.usersPath)
                                            .doc(user.uid)
                                            .set({
                                          'userLang': "ar",
                                        }, SetOptions(merge: true));
                                        accountBloc.add(
                                            GetAccountDetailsEvent(user.uid));
                                      }
                                      setState(() {
                                        lang = "ar";
                                      });
                                      MyApp.setLocale(context, _temp);
                                    }
                                  },
                                  icon: Image.asset(
                                    theme == "light"
                                        ? 'assets/applicationIcons/Group166.png'
                                        : 'assets/applicationIcons/whiteLang.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                                IconButton(
                                  iconSize: 30,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Image.asset(
                                    theme == "light"
                                        ? 'assets/applicationIcons/Iconly-Two-tone-Category.png'
                                        : 'assets/applicationIcons/Iconly-Curved-Category.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [

                                IconButton(
                                  iconSize: 30,
                                  onPressed: () async {
                                    if (lang == "ar") {
                                      await setLocale("en");
                                      Locale _temp = Locale("en", 'US');
                                      if (user != null) {
                                        await FirebaseFirestore.instance
                                            .collection(Paths.usersPath)
                                            .doc(user.uid)
                                            .set({
                                          'userLang': "en",
                                        }, SetOptions(merge: true));
                                        accountBloc.add(
                                            GetAccountDetailsEvent(user.uid));
                                      }
                                      MyApp.setLocale(context, _temp);
                                    } else {
                                      await setLocale("ar");
                                      Locale _temp = Locale("ar", 'AR');
                                      if (user != null) {
                                        await FirebaseFirestore.instance
                                            .collection(Paths.usersPath)
                                            .doc(user.uid)
                                            .set({
                                          'userLang': "ar",
                                        }, SetOptions(merge: true));
                                        accountBloc.add(
                                            GetAccountDetailsEvent(user.uid));
                                      }
                                      MyApp.setLocale(context, _temp);
                                    }
                                  },
                                  icon: Image.asset(
                                    theme == "light"
                                        ? lang != "ar"
                                            ? 'assets/applicationIcons/arabicPink.png'
                                            : 'assets/applicationIcons/Group166.png'
                                        : lang == "ar"
                                            ? 'assets/applicationIcons/whiteLang.png'
                                            : 'assets/applicationIcons/arabicWhite.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Image.asset(
                                    theme == "light"
                                        ? 'assets/applicationIcons/Iconly-Two-tone-Category.png'
                                        : 'assets/applicationIcons/Iconly-Curved-Category.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child:Image.asset('assets/applicationIcons/whiteLogo.png',width: 100,height: 100,),
                  ),
                  Center(
                    child: Text(
                      getTranslated(context, "welcomeBack"),
                      style: GoogleFonts.cairo(
                        color:
                            theme == "light" ? AppColors.pink : AppColors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  userName != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              userName,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.cairo(
                                color: Theme.of(context).primaryColor,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          appTitle, //getTranslated(context, "firstApp"),
                          maxLines: 7,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: GoogleFonts.cairo(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  SizedBox(
                    height: 30,
                  ),
                  (user != null && user.userType != "SUPPORT")
                      ? Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * .3,
                          child: Text(
                            getTranslated(context, "balance"),
                            style: TextStyle(
                              color: theme == "light"
                                  ? AppColors.pink
                                  : AppColors.orange,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                            height: 40.0,
                            width: size.width * .4,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 0.0),
                            decoration: BoxDecoration(
                              color: theme == "light"
                                  ? AppColors.lightGrey
                                  : AppColors.orange,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Text(
                                (double.parse(user.balance.toString()))
                                    .toStringAsFixed(1),
                                style: TextStyle(
                                  color: theme == "light"
                                      ? AppColors.pink
                                      : AppColors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ))
                      ],
                    ),
                  )
                      : SizedBox(),
                  SizedBox(
                    height: 20,
                  ),
                  (user != null && user.userType == "CONSULTANT")
                      ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: size.width * .3,
                                child: Text(
                                  getTranslated(context, "totalEarn"),
                                  style: TextStyle(
                                    color: theme == "light"
                                        ? AppColors.pink
                                        : AppColors.orange,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                  height: 40.0,
                                  width: size.width * .4,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 0.0),
                                  decoration: BoxDecoration(
                                    color: theme == "light"
                                        ? AppColors.lightGrey
                                        : AppColors.orange,
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.payedBalance == null
                                          ? '0'
                                          : (double.parse(
                                                  user.payedBalance.toString()))
                                              .toStringAsFixed(1),
                                      style: TextStyle(
                                        color: theme == "light"
                                            ? AppColors.pink
                                            : AppColors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        )
                      : SizedBox(),

                  SizedBox(
                    height: 20,
                  ),
                  (user != null)
                      ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: size.width * .3,
                                child: Text(
                                  getTranslated(context, "orderNum"),
                                  style: TextStyle(
                                    color: theme == "light"
                                        ? AppColors.pink
                                        : AppColors.orange,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                  height: 40.0,
                                  width: size.width * .4,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 0.0),
                                  decoration: BoxDecoration(
                                    color: theme == "light"
                                        ? AppColors.lightGrey
                                        : AppColors.orange,
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.userType=="SUPPORT"?user.answeredSupportNum.toString():user.ordersNumbers == null
                                          ? '0'
                                          : user.ordersNumbers.toString(),
                                      style: TextStyle(
                                        color: theme == "light"
                                            ? AppColors.pink
                                            : AppColors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 20,
                  ),
                  (user != null && user.userType == "CONSULTANT")
                      ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: size.width * .3,
                                child: Text(
                                  getTranslated(context, "reviewCount"),
                                  style: TextStyle(
                                    color: theme == "light"
                                        ? AppColors.pink
                                        : AppColors.orange,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                  height: 40.0,
                                  width: size.width * .4,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 0.0),
                                  decoration: BoxDecoration(
                                    color: theme == "light"
                                        ? AppColors.lightGrey
                                        : AppColors.orange,
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.reviewsCount == null
                                          ? "0"
                                          : user.reviewsCount.toString(),
                                      style: TextStyle(
                                        color: theme == "light"
                                            ? AppColors.pink
                                            : AppColors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
            NotificationListener<DraggableScrollableNotification>(
              // ignore: missing_return
              onNotification: (notification) {
                if (notification.extent < .30)
                  setState(() {
                    small = true;
                  });
                else
                  setState(() {
                    small = false;
                  });
              },
              child: SizedBox.expand(
                child: DraggableScrollableSheet(
                    initialChildSize: .25,
                    minChildSize: .25,
                    maxChildSize: .7,
                    //(user!=null&&user.userType!="SUPPORT")?0.6:0.8,//(user!=null&&user.userType=="SUPPORT")?0.4: 0.6,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 0.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(40.0),
                              topRight: const Radius.circular(40.0),
                            )),
                        child: ListView(
                          controller: scrollController,
                          children: [
                            Center(
                                child: Container(
                                    width: size.width * .2,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: theme == "light"
                                          ? Colors.white
                                          : Colors.black,
                                      borderRadius: BorderRadius.circular(1.5),
                                    ))),
                            SizedBox(
                              height: 2,
                            ),
                            (user != null && small)
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, left: 5, right: 5),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                showSignoutConfimationDialog(
                                                    size);
                                              },
                                              child: Container(
                                                width: size.width * .25,
                                                height: size.width * .25,
                                                decoration: BoxDecoration(
                                                    color: theme == "light"
                                                        ? AppColors.white
                                                        : AppColors.black,
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              25.0),
                                                    )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      theme == "light"
                                                          ? 'assets/applicationIcons/Iconly-Two-tone-Logout.png'
                                                          : 'assets/applicationIcons/Iconly-Two-tone-Logout1.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    SizedBox(
                                                      width: 1,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                          context, "logout"),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: theme == "light"
                                                            ? AppColors.pink
                                                            : AppColors.white,
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        user.userType=="SUPPORT"?AllDevelopTechScreen(loggedUser:user):user.userType=="USER"?AddGrantsScreen(loggedUser:user ,):AboutUsScreen(),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: size.width * .25,
                                                height: size.width * .25,
                                                decoration: BoxDecoration(
                                                    color: theme == "light"
                                                        ? AppColors.white
                                                        : AppColors.black,
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              25.0),
                                                    )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      theme == "light"
                                                          ? 'assets/applicationIcons/Iconly-Two-tone-User.png'
                                                          : 'assets/applicationIcons/Iconly-Two-tone-User1.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    SizedBox(
                                                      width: 1,
                                                    ),
                                                    Text(
                                                     user.userType=="SUPPORT"?getTranslated(context, "developNotes"):user.userType=="USER"?getTranslated(context, "grants"): getTranslated(context, "aboutUs"),
                                                      maxLines: 2,
                                                      softWrap:true,
                                                      overflow:TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: theme == "light"
                                                            ? AppColors.pink
                                                            : AppColors.white,
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                if (user.userType ==
                                                    "CONSULTANT")
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AccountScreen(
                                                              user: user,
                                                              firstLogged:
                                                                  false),
                                                    ),
                                                  );
                                                else
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          UserAccountScreen(
                                                              user: user,
                                                              firstLogged:
                                                                  false),
                                                    ),
                                                  );
                                              },
                                              child: Container(
                                                width: size.width * .25,
                                                height: size.width * .25,
                                                decoration: BoxDecoration(
                                                    color: theme == "light"
                                                        ? AppColors.white
                                                        : AppColors.black,
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              25.0),
                                                    )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      theme == "light"
                                                          ? 'assets/applicationIcons/Iconly-Two-tone-Profile.png'
                                                          : 'assets/applicationIcons/Iconly-Two-tone-Profile1.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    SizedBox(
                                                      width: 1,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                          context, "account"),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: theme == "light"
                                                            ? AppColors.pink
                                                            : AppColors.white,
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Center(
                                          child: Container(
                                            width: size.width * .8,
                                            height: 45.0,
                                            child: FlatButton(
                                              onPressed: () async {
                                                inviteAFriend();
                                              },
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40.0),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.share,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    getTranslated(
                                                        context, "share"),
                                                    style: GoogleFonts.cairo(
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                      // fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            (user != null && small == false)
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    child: Column(
                                      children: [
                                        (user != null &&
                                                user.userType == "SUPPORT")
                                            ? Column(
                                                children: [
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    getTranslated(context,
                                                        "searchByMobile"),
                                                    style: GoogleFonts.poppins(
                                                      color: theme == "light"
                                                          ? Colors.white
                                                          : Color(0xff3f3f3f),
                                                      fontSize: 19.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  TextField(
                                                    textAlignVertical:
                                                        TextAlignVertical
                                                            .center,
                                                    controller:
                                                        searchController,
                                                    enableInteractiveSelection:
                                                        true,
                                                    onChanged: (text) {
                                                      setState(() {
                                                        wrongNumber = false;
                                                      });
                                                    },
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.black,
                                                      fontSize: 14.5,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 0.5,
                                                    ),
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    keyboardType:
                                                        TextInputType.phone,
                                                    decoration: InputDecoration(
                                                      fillColor: theme ==
                                                              "light"
                                                          ? Colors.white
                                                          : Color(0xff3f3f3f),
                                                      filled: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15.0),
                                                      helperStyle:
                                                          GoogleFonts.poppins(
                                                        color: Colors.black
                                                            .withOpacity(0.65),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 0.5,
                                                      ),
                                                      errorStyle:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 0.5,
                                                      ),
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                        color: Colors.black54,
                                                        fontSize: 14.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 0.5,
                                                      ),
                                                      prefixIcon:
                                                          Icon(Icons.search),
                                                      prefixStyle:
                                                          GoogleFonts.poppins(
                                                        fontSize: 14.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 0.5,
                                                      ),
                                                      suffixIcon: InkWell(
                                                          child: Icon(
                                                              Icons
                                                                  .send_rounded,
                                                              size: 18),
                                                          onTap: () {
                                                            initiateSearch(
                                                                searchController
                                                                    .text);
                                                          }),
                                                      // labelText: getTranslated(context, "phoneNumber"),
                                                      labelStyle:
                                                          GoogleFonts.poppins(
                                                        fontSize: 14.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 0.5,
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.0),
                                                      ),
/*
                                    border: InputBorder.none,
*/
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  load
                                                      ? CircularProgressIndicator()
                                                      : SizedBox(),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  wrongNumber
                                                      ? Text(
                                                          getTranslated(context,
                                                              "noUser"),
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: Colors.red,
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              )
                                            : Center(
                                                child: InkWell(
                                                  splashColor: Colors.white
                                                      .withOpacity(0.5),
                                                  onTap: () {
                                                    if (user.userType ==
                                                        "CONSULTANT")
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AccountScreen(
                                                            user: user,
                                                            firstLogged: false,
                                                          ),
                                                        ),
                                                      );
                                                    else
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              UserAccountScreen(
                                                            user: user,
                                                            firstLogged: false,
                                                          ),
                                                        ),
                                                      );
                                                  },
                                                  child: Container(
                                                    width: size.width * .3,
                                                    height: size.width * .3,
                                                    decoration: BoxDecoration(
                                                        color: theme == "light"
                                                            ? AppColors.white
                                                            : AppColors.black,
                                                        borderRadius:
                                                            new BorderRadius
                                                                .only(
                                                          topLeft: const Radius
                                                              .circular(25.0),
                                                          topRight: const Radius
                                                              .circular(25.0),
                                                          bottomLeft:
                                                              const Radius
                                                                      .circular(
                                                                  25.0),
                                                          bottomRight:
                                                              const Radius
                                                                      .circular(
                                                                  25.0),
                                                        )),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                          theme == "light"
                                                              ? 'assets/applicationIcons/Iconly-Two-tone-Profile.png'
                                                              : 'assets/applicationIcons/Iconly-Two-tone-Profile1.png',
                                                          width: 30,
                                                          height: 30,
                                                        ),
                                                        SizedBox(
                                                          width: 1,
                                                        ),
                                                        Text(
                                                          getTranslated(context,
                                                              "account"),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: theme ==
                                                                    "light"
                                                                ? AppColors.pink
                                                                : AppColors
                                                                    .white,
                                                            fontSize: 15.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        //--------
                                        user.userType != "SUPPORT"
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  InkWell(
                                                    splashColor: Colors.white
                                                        .withOpacity(0.5),
                                                    onTap: () {
                                                      user.userType == "USER"
                                                          ? Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        WalletScreen(
                                                                  loggedUser:
                                                                      user,
                                                                ),
                                                              ),
                                                            )
                                                          : Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ConsultPaymentHistoryScreen(
                                                                  user: user,
                                                                ),
                                                              ),
                                                            );
                                                    }, //
                                                    child: Container(
                                                      width: size.width * .3,
                                                      height: size.width * .3,
                                                      decoration: BoxDecoration(
                                                          color: theme ==
                                                                  "light"
                                                              ? AppColors.white
                                                              : AppColors.black,
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .only(
                                                            topLeft: const Radius
                                                                .circular(25.0),
                                                            topRight: const Radius
                                                                .circular(25.0),
                                                            bottomLeft:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                            bottomRight:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                          )),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            user.userType == "USER"
                                                                ? Icons
                                                                    .account_balance_wallet_outlined
                                                                : Icons
                                                                    .money_outlined,
                                                            size: 30,
                                                            color: theme ==
                                                                    "light"
                                                                ? AppColors.pink
                                                                : AppColors
                                                                    .orange,
                                                          ),
                                                          SizedBox(
                                                            width: 1,
                                                          ),
                                                          Text(
                                                            user.userType ==
                                                                    "USER"
                                                                ? getTranslated(
                                                                    context,
                                                                    "wallet")
                                                                : getTranslated(
                                                                    context,
                                                                    "paymentHistory"),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: theme ==
                                                                      "light"
                                                                  ? AppColors
                                                                      .pink
                                                                  : AppColors
                                                                      .white,
                                                              fontSize: 15.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    splashColor: Colors.white
                                                        .withOpacity(0.5),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              SuggestionScreen(
                                                                  loggedUser:
                                                                      user),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: size.width * .3,
                                                      height: size.width * .3,
                                                      decoration: BoxDecoration(
                                                          color: theme ==
                                                                  "light"
                                                              ? AppColors.white
                                                              : AppColors.black,
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .only(
                                                            topLeft: const Radius
                                                                .circular(25.0),
                                                            topRight: const Radius
                                                                .circular(25.0),
                                                            bottomLeft:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                            bottomRight:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                          )),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          /* Image.asset(theme=="light"?
                                      'assets/applicationIcons/pinkStar.png':'assets/applicationIcons/orangStar.png',
                                        width: 30,
                                        height: 30,
                                      ),*/
                                                          Icon(
                                                            Icons
                                                                .lightbulb_outline,
                                                            size: 30,
                                                            color: theme ==
                                                                    "light"
                                                                ? AppColors.pink
                                                                : AppColors
                                                                    .orange,
                                                          ),
                                                          SizedBox(
                                                            width: 1,
                                                          ),
                                                          Text(
                                                            getTranslated(
                                                                context,
                                                                "suggestions"),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: theme ==
                                                                      "light"
                                                                  ? AppColors
                                                                      .pink
                                                                  : AppColors
                                                                      .white,
                                                              fontSize: 15.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox(),
                                        user.userType != "SUPPORT"
                                            ? SizedBox(
                                                height: 5,
                                              )
                                            : SizedBox(),
                                        //---------
                                        user.userType == "CONSULTANT"
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  InkWell(
                                                    splashColor: Colors.white
                                                        .withOpacity(0.5),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ReviewScreens(
                                                            consult: user,
                                                            reviewLength: 1,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: size.width * .3,
                                                      height: size.width * .3,
                                                      decoration: BoxDecoration(
                                                          color: theme ==
                                                                  "light"
                                                              ? AppColors.white
                                                              : AppColors.black,
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .only(
                                                            topLeft: const Radius
                                                                .circular(25.0),
                                                            topRight: const Radius
                                                                .circular(25.0),
                                                            bottomLeft:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                            bottomRight:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                          )),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          /* Image.asset(theme=="light"?
                                      'assets/applicationIcons/pinkStar.png':'assets/applicationIcons/orangStar.png',
                                        width: 30,
                                        height: 30,
                                      ),*/
                                                          Icon(
                                                            Icons.star,
                                                            size: 30,
                                                            color: theme ==
                                                                    "light"
                                                                ? AppColors.pink
                                                                : AppColors
                                                                    .orange,
                                                          ),
                                                          SizedBox(
                                                            width: 1,
                                                          ),
                                                          Text(
                                                            getTranslated(
                                                                context,
                                                                "Reviews"),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: theme ==
                                                                      "light"
                                                                  ? AppColors
                                                                      .pink
                                                                  : AppColors
                                                                      .white,
                                                              fontSize: 15.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    splashColor: Colors.white
                                                        .withOpacity(0.5),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              MyOrdersScreen(
                                                            user: user,
                                                            loggedType: user.userType,
                                                                fromSupport: false,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: size.width * .3,
                                                      height: size.width * .3,
                                                      decoration: BoxDecoration(
                                                          color: theme ==
                                                                  "light"
                                                              ? AppColors.white
                                                              : AppColors.black,
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .only(
                                                            topLeft: const Radius
                                                                .circular(25.0),
                                                            topRight: const Radius
                                                                .circular(25.0),
                                                            bottomLeft:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                            bottomRight:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                          )),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                            theme == "light"
                                                                ? 'assets/applicationIcons/Iconly-Two-tone-file.png'
                                                                : 'assets/applicationIcons/whiteFile.png',
                                                            width: 30,
                                                            height: 30,
                                                          ),
                                                          SizedBox(
                                                            width: 1,
                                                          ),
                                                          Text(
                                                            getTranslated(
                                                                context,
                                                                "orders"),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: theme ==
                                                                      "light"
                                                                  ? AppColors
                                                                      .pink
                                                                  : AppColors
                                                                      .white,
                                                              fontSize: 15.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox(),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        //,,,,,,
                                        //--------
                                        user.userType == "SUPPORT"
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  InkWell(
                                                    splashColor: Colors.white
                                                        .withOpacity(0.5),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AllAppointmentsScreen(loggedUser: user,
                                                              theme:theme),

                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: size.width * .3,
                                                      height: size.width * .3,
                                                      decoration: BoxDecoration(
                                                          color: theme ==
                                                                  "light"
                                                              ? AppColors.white
                                                              : AppColors.black,
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .only(
                                                            topLeft: const Radius
                                                                .circular(25.0),
                                                            topRight: const Radius
                                                                .circular(25.0),
                                                            bottomLeft:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                            bottomRight:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                          )),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          /* Image.asset(theme=="light"?
                                      'assets/applicationIcons/pinkStar.png':'assets/applicationIcons/orangStar.png',
                                        width: 30,
                                        height: 30,
                                      ),*/
                                                          Icon(
                                                            Icons
                                                                .calendar_today_rounded,
                                                            size: 30,
                                                            color: theme ==
                                                                    "light"
                                                                ? AppColors.pink
                                                                : AppColors
                                                                    .orange,
                                                          ),
                                                          SizedBox(
                                                            width: 1,
                                                          ),
                                                          Text(
                                                            getTranslated(
                                                                context,
                                                                "appointments"),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: theme ==
                                                                      "light"
                                                                  ? AppColors
                                                                      .pink
                                                                  : AppColors
                                                                      .white,
                                                              fontSize: 15.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    splashColor: Colors.white
                                                        .withOpacity(0.5),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddFakeReviewScreen(
                                                                  user: user),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: size.width * .3,
                                                      height: size.width * .3,
                                                      decoration: BoxDecoration(
                                                          color: theme ==
                                                                  "light"
                                                              ? AppColors.white
                                                              : AppColors.black,
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .only(
                                                            topLeft: const Radius
                                                                .circular(25.0),
                                                            topRight: const Radius
                                                                .circular(25.0),
                                                            bottomLeft:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                            bottomRight:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                          )),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          /* Image.asset(theme=="light"?
                                      'assets/applicationIcons/pinkStar.png':'assets/applicationIcons/orangStar.png',
                                        width: 30,
                                        height: 30,
                                      ),*/
                                                          Icon(
                                                            Icons
                                                                .add_circle_outline,
                                                            size: 30,
                                                            color: theme ==
                                                                    "light"
                                                                ? AppColors.pink
                                                                : AppColors
                                                                    .orange,
                                                          ),
                                                          SizedBox(
                                                            width: 1,
                                                          ),
                                                          Text(
                                                            getTranslated(
                                                                context,
                                                                "addReview"),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: theme ==
                                                                      "light"
                                                                  ? AppColors
                                                                      .pink
                                                                  : AppColors
                                                                      .white,
                                                              fontSize: 15.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : SizedBox(),
                                        user.userType == "SUPPORT"
                                            ? SizedBox(
                                                height: 5,
                                              )
                                            : SizedBox(),
                                        //---------
                                        //--------
                                        user.userType == "SUPPORT"
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  InkWell(
                                                    splashColor: Colors.white
                                                        .withOpacity(0.5),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AllPromoCodeScreen(),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: size.width * .3,
                                                      height: size.width * .3,
                                                      decoration: BoxDecoration(
                                                          color: theme ==
                                                                  "light"
                                                              ? AppColors.white
                                                              : AppColors.black,
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .only(
                                                            topLeft: const Radius
                                                                .circular(25.0),
                                                            topRight: const Radius
                                                                .circular(25.0),
                                                            bottomLeft:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                            bottomRight:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                          )),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.card_giftcard,
                                                            size: 30,
                                                            color: theme ==
                                                                    "light"
                                                                ? AppColors.pink
                                                                : AppColors
                                                                    .orange,
                                                          ),
                                                          SizedBox(
                                                            width: 1,
                                                          ),
                                                          Text(
                                                            getTranslated(
                                                                context,
                                                                "proCodes"),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: theme ==
                                                                      "light"
                                                                  ? AppColors
                                                                      .pink
                                                                  : AppColors
                                                                      .white,
                                                              fontSize: 15.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    splashColor: Colors.white
                                                        .withOpacity(0.5),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AllSendedNotificationSreen(),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: size.width * .3,
                                                      height: size.width * .3,
                                                      decoration: BoxDecoration(
                                                          color: theme ==
                                                                  "light"
                                                              ? AppColors.white
                                                              : AppColors.black,
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .only(
                                                            topLeft: const Radius
                                                                .circular(25.0),
                                                            topRight: const Radius
                                                                .circular(25.0),
                                                            bottomLeft:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                            bottomRight:
                                                                const Radius
                                                                        .circular(
                                                                    25.0),
                                                          )),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          /* Image.asset(theme=="light"?
                                      'assets/applicationIcons/pinkStar.png':'assets/applicationIcons/orangStar.png',
                                        width: 30,
                                        height: 30,
                                      ),*/
                                                          Icon(
                                                            Icons
                                                                .notifications_none_sharp,
                                                            size: 30,
                                                            color: theme ==
                                                                    "light"
                                                                ? AppColors.pink
                                                                : AppColors
                                                                    .orange,
                                                          ),
                                                          SizedBox(
                                                            width: 1,
                                                          ),
                                                          Text(
                                                            getTranslated(
                                                                context,
                                                                "notification"),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: theme ==
                                                                      "light"
                                                                  ? AppColors
                                                                      .pink
                                                                  : AppColors
                                                                      .white,
                                                              fontSize: 15.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox(),
                                        user.userType == "SUPPORT"
                                            ? SizedBox(
                                                height: 5,
                                              )
                                            : SizedBox(),
                                        //---------
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                showSignoutConfimationDialog(
                                                    size);
                                              },
                                              child: Container(
                                                width: size.width * .3,
                                                height: size.width * .3,
                                                decoration: BoxDecoration(
                                                    color: theme == "light"
                                                        ? AppColors.white
                                                        : AppColors.black,
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              25.0),
                                                    )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      theme == "light"
                                                          ? 'assets/applicationIcons/Iconly-Two-tone-Logout.png'
                                                          : 'assets/applicationIcons/Iconly-Two-tone-Logout1.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    SizedBox(
                                                      width: 1,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                          context, "logout"),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: theme == "light"
                                                            ? AppColors.pink
                                                            : AppColors.white,
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                    user.userType=="SUPPORT"?AllDevelopTechScreen(loggedUser:user):user.userType=="USER"?AddGrantsScreen(loggedUser: user,):AboutUsScreen(),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: size.width * .3,
                                                height: size.width * .3,
                                                decoration: BoxDecoration(
                                                    color: theme == "light"
                                                        ? AppColors.white
                                                        : AppColors.black,
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              25.0),
                                                    )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      theme == "light"
                                                          ? 'assets/applicationIcons/Iconly-Two-tone-User.png'
                                                          : 'assets/applicationIcons/Iconly-Two-tone-User1.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    SizedBox(
                                                      width: 1,
                                                    ),
                                                    Text(
                                                      user.userType=="SUPPORT"?getTranslated(context, "developNotes"):user.userType=="USER"?getTranslated(context, "grants"): getTranslated(context, "aboutUs"),
                                                      softWrap:true,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: theme == "light"
                                                            ? AppColors.pink
                                                            : AppColors.white,
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Center(
                                          child: Container(
                                            width: size.width * .8,
                                            height: 45.0,
                                            child: FlatButton(
                                              onPressed: () async {
                                                inviteAFriend();
                                              },
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40.0),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.share,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    getTranslated(
                                                        context, "share"),
                                                    style: GoogleFonts.cairo(
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                      // fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            (user == null && small)
                                ? Padding(padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                Navigator.pushNamed(context,
                                                    '/RegisterTypeScreen');
                                                // Navigator.pushNamed(context, '/sign_in');
                                              },
                                              child: Container(
                                                width: size.width * .25,
                                                height: size.width * .25,
                                                decoration: BoxDecoration(
                                                    color: theme == "light"
                                                        ? AppColors.white
                                                        : AppColors.black,
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              25.0),
                                                    )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      theme == "light"
                                                          ? 'assets/applicationIcons/Iconly-Two-tone-Logout.png'
                                                          : 'assets/applicationIcons/Iconly-Two-tone-Logout1.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    SizedBox(
                                                      width: 1,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                          context, "login"),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: theme == "light"
                                                            ? AppColors.pink
                                                            : AppColors.white,
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AboutUsScreen(),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: size.width * .25,
                                                height: size.width * .25,
                                                decoration: BoxDecoration(
                                                    color: theme == "light"
                                                        ? AppColors.white
                                                        : AppColors.black,
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              25.0),
                                                    )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      theme == "light"
                                                          ? 'assets/applicationIcons/Iconly-Two-tone-User.png'
                                                          : 'assets/applicationIcons/Iconly-Two-tone-User1.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    SizedBox(
                                                      width: 1,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                          context, "aboutUs"),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: theme == "light"
                                                            ? AppColors.pink
                                                            : AppColors.white,
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PrivecyScreen(),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: size.width * .25,
                                                height: size.width * .25,
                                                decoration: BoxDecoration(
                                                    color: theme == "light"
                                                        ? AppColors.white
                                                        : AppColors.black,
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              25.0),
                                                    )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      theme == "light"
                                                          ? 'assets/applicationIcons/Iconly-Two-tone-file.png'
                                                          : 'assets/applicationIcons/whiteFile.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    SizedBox(
                                                      width: 1,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                          context, "privcy"),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: theme == "light"
                                                            ? AppColors.pink
                                                            : AppColors.white,
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Center(
                                          child: Container(
                                            width: size.width * .8,
                                            height: 45.0,
                                            child: FlatButton(
                                              onPressed: () async {
                                                inviteAFriend();
                                              },
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40.0),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.share,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    getTranslated(
                                                        context, "share"),
                                                    style: GoogleFonts.cairo(
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                      // fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            (user == null && small == false)
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, left: 5, right: 5),
                                    child: Column(
                                      children: [
                                        Center(
                                          child: InkWell(
                                            splashColor:
                                                Colors.white.withOpacity(0.5),
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  '/RegisterTypeScreen');
                                              // Navigator.pushNamed(context, '/sign_in');
                                            },
                                            child: Container(
                                              width: size.width * .3,
                                              height: size.width * .3,
                                              decoration: BoxDecoration(
                                                  color: theme == "light"
                                                      ? AppColors.white
                                                      : AppColors.black,
                                                  borderRadius:
                                                      new BorderRadius.only(
                                                    topLeft:
                                                        const Radius.circular(
                                                            25.0),
                                                    topRight:
                                                        const Radius.circular(
                                                            25.0),
                                                    bottomLeft:
                                                        const Radius.circular(
                                                            25.0),
                                                    bottomRight:
                                                        const Radius.circular(
                                                            25.0),
                                                  )),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    theme == "light"
                                                        ? 'assets/applicationIcons/Iconly-Two-tone-Logout.png'
                                                        : 'assets/applicationIcons/Iconly-Two-tone-Logout1.png',
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                  SizedBox(
                                                    width: 1,
                                                  ),
                                                  Text(
                                                    getTranslated(
                                                        context, "login"),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: theme == "light"
                                                          ? AppColors.pink
                                                          : AppColors.white,
                                                      fontSize: 15.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AboutUsScreen(),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: size.width * .3,
                                                height: size.width * .3,
                                                decoration: BoxDecoration(
                                                    color: theme == "light"
                                                        ? AppColors.white
                                                        : AppColors.black,
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              25.0),
                                                    )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      theme == "light"
                                                          ? 'assets/applicationIcons/Iconly-Two-tone-User.png'
                                                          : 'assets/applicationIcons/Iconly-Two-tone-User1.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    SizedBox(
                                                      width: 1,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                          context, "aboutUs"),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: theme == "light"
                                                            ? AppColors.pink
                                                            : AppColors.white,
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor:
                                                  Colors.white.withOpacity(0.5),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PrivecyScreen(),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: size.width * .3,
                                                height: size.width * .3,
                                                decoration: BoxDecoration(
                                                    color: theme == "light"
                                                        ? AppColors.white
                                                        : AppColors.black,
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              25.0),
                                                    )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      theme == "light"
                                                          ? 'assets/applicationIcons/Iconly-Two-tone-file.png'
                                                          : 'assets/applicationIcons/whiteFile.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                    SizedBox(
                                                      width: 1,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                          context, "privcy"),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: theme == "light"
                                                            ? AppColors.pink
                                                            : AppColors.white,
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Center(
                                          child: Container(
                                            width: size.width * .8,
                                            height: 45.0,
                                            child: FlatButton(
                                              onPressed: () async {
                                                inviteAFriend();
                                              },
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40.0),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.share,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    getTranslated(
                                                        context, "share"),
                                                    style: GoogleFonts.cairo(
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                      // fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      );
                    }),
              ),
            ),
          ],
        ));
  }

  Future inviteAFriend() async {
    await FlutterShare.share(
        title: 'غراس  - Jeras',
        text: 'غراس  - Jeras \n يمكنك تحميل تطبيق غراس من خلال موقعنا الرسمي You can get Jeras app from our website ',
        linkUrl: 'https://www.jeras.io/',
        chooserTitle: 'غراس  - Jeras'
    );

  }

  showSignoutConfimationDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                getTranslated(context, "logout"),
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
                getTranslated(context, "doYouNeedToLogout"),
                style: GoogleFonts.cairo(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: Colors.black87,
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: 50.0,
                    child: FlatButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        getTranslated(context, 'no'),
                        style: GoogleFonts.cairo(
                          color: Colors.black87,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 50.0,
                    child: FlatButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () async {
                         await FirebaseFirestore.instance.collection(Paths.usersPath).doc(user.uid).set({
                          'tokenId': "",
                        }, SetOptions(merge: true));
                        signinBloc.add(SignoutEvent());
                        isSigningOut = true;
                        Navigator.pop(context);
                      },
                      child: Text(
                        getTranslated(context, 'yes'),
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
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
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

  initiateSearch(String text) async {
    setState(() {
      load = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .where(
          'phoneNumber',
          isEqualTo: text,
        )
        .limit(1)
        .get();
    if (querySnapshot != null && querySnapshot.docs.length != 0) {
      var userSearch = GroceryUser.fromFirestore(querySnapshot.docs[0]);
      setState(() {
        load = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailsScreen(
            user: userSearch,
            loggedUser: user,
          ),
        ),
      );
    } else {
      setState(() {
        load = false;
        wrongNumber = true;
      });
    }
  }
}
