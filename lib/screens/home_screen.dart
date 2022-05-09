// @dart=2.9
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/pages/AppointmentsPage.dart';
import 'package:grocery_store/pages/home_page.dart';
import 'package:grocery_store/pages/TechnicalSupportPage.dart';
import 'package:grocery_store/pages/CallHistoryPage.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final int notificationPage;

  const HomeScreen({Key key, this.notificationPage}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPage;
  PageController _pageController;
  int cartCount;
  NotificationBloc notificationBloc;
  SigninBloc signinBloc;
  String userType="",theme;
  @override
  void initState() {
    super.initState();

    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    signinBloc = BlocProvider.of<SigninBloc>(context);
    signinBloc.add(CheckIfSignedIn());


    if(widget.notificationPage!=null)
        _selectedPage=widget.notificationPage;
    else
       _selectedPage = 0;
    _pageController = PageController(initialPage: _selectedPage);
   signinBloc.listen((state) {
      print("ddddd homescreen");
      print(state);

      if (state is CheckIfSignedInCompleted) {
        //proceed to home
       if(mounted){
         print('logged in');
         if (state.res.contains("userType")) {
           if(mounted)
             setState(() {
               if(state.res.contains("CONSULTANT"))
               userType="CONSULTANT";
               else
                 userType="USER";
             });
           print("ddffff"+state.res);
         } else {
           userType="";
         }
       }
      }
      if (state is NotLoggedIn) {
        //proceed to sign in
       if(mounted){
         print('not logged in');
         userType="";
       }
      }
      if (state is FailedToCheckLoggedIn) {
        //proceed to sign in
        if(mounted)
          {
            print('failed to check if logged in');
            userType="";
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
  /*@override
  void dispose() {
    cartCountBloc.close();
    //notificationBloc.close();
    super.dispose();
  }*/

  void showSnackAdding(String text) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.cyan.shade600,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: false,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1.0,
          blurRadius: 5.0,
          offset: Offset(0.0, 2.0),
        )
      ],
      shouldIconPulse: true,
      duration: Duration(milliseconds: 10000),
      icon: Icon(
        Icons.add_shopping_cart,
        color: Colors.white,
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.cyan.shade600,
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

  void showSnack(String text) {
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
        Icons.add_shopping_cart,
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
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        //cartCountBloc.close();
        //notificationBloc.close();
        return true;
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white54,
          ),
          height:Platform.isAndroid ? 65.0 : 100.0,
          width: size.width,
          child: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 6.0,
            child: (userType!="CONSULTANT")?Container(//width: size.width,height: Platform.isAndroid ? 100:85,
              decoration: BoxDecoration(
                color:Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(5.0),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _pageController.jumpToPage(
                          0,);
                        setState(() {
                          _selectedPage = 0;
                        });
                      },
                      child: Container(width: size.width*.33,color: _selectedPage == 0
                          ? theme=="light"?Colors.white:Colors.white
                          : theme=="light"?Theme.of(context).primaryColor:Colors.black,
                        child: Center(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _selectedPage == 0?Image.asset(theme=="light"?
                              'assets/applicationIcons/Group.png':'assets/applicationIcons/Group1.png',
                                width: 30,
                                height: 30,
                              ):Image.asset(theme=="light"?
                              'assets/applicationIcons/schedule2.png':'assets/applicationIcons/schedule2.png',
                                width: 30,
                                height: 30,
                              ),
                              Text(getTranslated(context,"schedule"),style: GoogleFonts.cairo(
                                color: _selectedPage == 0
                                    ?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        print('appointments');
                        if (FirebaseAuth.instance.currentUser == null) {
                          Navigator.pushNamed(context, '/Register_Type');
                        } else {
                          _pageController.jumpToPage(1, );
                        }

                        setState(() {
                          _selectedPage = 1;
                        });
                      },
                      child: Container(width: size.width*.33,color: _selectedPage == 1
                          ? theme=="light"?Colors.white:Colors.white
                          : theme=="light"?Theme.of(context).primaryColor:Colors.black,
                        child: Center(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _selectedPage == 1? Image.asset(theme=="light"?
                              'assets/applicationIcons/Iconly-Two-tone-Calendar-1.png':'assets/applicationIcons/Iconly-Two-tone-CalendarCons.png',
                                width: 30,
                                height: 30,
                              ):Image.asset(theme=="light"?
                              'assets/applicationIcons/Iconly-Two-tone-Calendar.png':'assets/applicationIcons/Iconly-Two-tone-Calendar.png',
                                width: 30,
                                height: 30,
                              ),
                              Text(getTranslated(context,"appointments") ,style: GoogleFonts.cairo(
                                color: _selectedPage == 1
                                    ?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        print('support');
                        if (FirebaseAuth.instance.currentUser == null) {
                          Navigator.pushNamed(context, '/Register_Type');
                        } else {
                          _pageController.jumpToPage( 2,);
                        }
                        setState(() {
                          _selectedPage = 2;
                        });
                      },
                      child: Container(width: size.width*.33,
                        color: _selectedPage == 2
                            ? theme=="light"?Colors.white:Colors.white
                            : theme=="light"?Theme.of(context).primaryColor:Colors.black,
                        child: Center(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _selectedPage == 2? Image.asset(theme=="light"?
                              'assets/applicationIcons/Path.png':'assets/applicationIcons/Group1711.png',
                                width: 30,
                                height: 30,
                              ):Image.asset(theme=="light"?
                              'assets/applicationIcons/Group171.png':'assets/applicationIcons/Group171.png',
                                width: 30,
                                height: 30,
                              ),
                              Text(getTranslated(context,"support") ,overflow: TextOverflow.ellipsis,style: GoogleFonts.cairo(
                                color: _selectedPage == 2
                                    ?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            )
                :Container(//width: size.width, height: Platform.isAndroid ? 100:85,
                  decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5.0),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                         Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              print('appointments');
                              if (FirebaseAuth.instance.currentUser == null) {
                                Navigator.pushNamed(context, '/Register_Type');
                              } else {
                                _pageController.jumpToPage(0, );
                              }

                              setState(() {
                                _selectedPage = 0;
                              });
                            },
                            child: Container(width: size.width*.33,color: _selectedPage == 0
                                ? theme=="light"?Colors.white:Colors.white
                                : theme=="light"?Theme.of(context).primaryColor:Colors.black,
                              child: Center(
                                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _selectedPage == 0? Image.asset(theme=="light"?
                                    'assets/applicationIcons/Iconly-Two-tone-Calendar-1.png':'assets/applicationIcons/Iconly-Two-tone-Calendar11.png',
                                      width: 30,
                                      height: 30,
                                    ):Image.asset(theme=="light"?
                                    'assets/applicationIcons/Iconly-Two-tone-Calendar.png':'assets/applicationIcons/Iconly-Two-tone-Calendar.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                    Text(getTranslated(context,"appointments") ,softWrap:true,overflow:TextOverflow.ellipsis,style: GoogleFonts.cairo(
                                      color: _selectedPage == 0
                                          ?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                         Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _pageController.jumpToPage(
                                3,);
                              setState(() {
                                _selectedPage = 3;
                              });
                            },
                            child: Container(width: size.width*.33,color: _selectedPage == 3
                                ? theme=="light"?Colors.white:Colors.white
                                : theme=="light"?Theme.of(context).primaryColor:Colors.black,
                              child: Center(
                                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _selectedPage == 3? Image.asset(theme=="light"?
                                    'assets/applicationIcons/Group172.png':'assets/applicationIcons/Group1722.png',
                                      width: 30,
                                      height: 30,
                                    ):Image.asset(theme=="light"?
                                    'assets/applicationIcons/Group172.png':'assets/applicationIcons/Group172.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                   Text(getTranslated(context,"callHistory"),softWrap:true,overflow:TextOverflow.ellipsis,style: GoogleFonts.cairo(
                                      color: _selectedPage == 3
                                          ?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                     Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          print('support');
                          if (FirebaseAuth.instance.currentUser == null) {
                            Navigator.pushNamed(context, '/Register_Type');
                          } else {
                            _pageController.jumpToPage( 2,);
                          }
                          setState(() {
                            _selectedPage = 2;
                          });
                        },
                        child: Container(width: size.width*.33,
                          color: _selectedPage == 2
                              ? theme=="light"?Colors.white:Colors.white
                              : theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          child: Center(
                            child: Column(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _selectedPage == 2? Image.asset(theme=="light"?
                                'assets/applicationIcons/Path.png':'assets/applicationIcons/Group1711.png',
                                  width: 30,
                                  height: 30,
                                ):Image.asset(theme=="light"?
                                'assets/applicationIcons/Group171.png':'assets/applicationIcons/Group171.png',
                                  width: 30,
                                  height: 30,
                                ),
                                Text(getTranslated(context,"support") ,softWrap:true,overflow:TextOverflow.ellipsis,style: GoogleFonts.cairo(
                                  color: _selectedPage == 2
                                      ?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              )
              )

        ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            HomePage(userType: userType,),//0
            AppointmentsPage(),//1
            TechnicalSupportPage(),//2
            CallHistoryPage(),//3
          ],
        ),
      ),
    );
  }
}
