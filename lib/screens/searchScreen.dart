// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:grocery_store/widget/consultantListItem.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'account_screen.dart';
import 'notification_screen.dart';

class SearchScreen extends StatefulWidget {
  final GroceryUser loggedUser;
  
  const SearchScreen({Key key, this.loggedUser}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  NotificationBloc notificationBloc;
  UserNotification userNotification;
  final TextEditingController searchController = new TextEditingController();
 
  AccountBloc accountBloc;
  bool load=false;
  String lang,userImage,theme;
  String name ="";
  Query filterQuery;
  @override
  void initState() {
    super.initState();
   
    accountBloc = BlocProvider.of<AccountBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
   // initiateSearch(name);
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
  lang=getTranslated((context), "lang");
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key:_scaffoldKey,
      body:Stack(children: <Widget>[
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
              child: Container(width: size.width,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: userImage==null ?//whiteLogo.png
                          //Image.asset('assets/applicationIcons/whiteLogo.png')
                          Image.asset(theme=="light"?
                          'assets/applicationIcons/whiteLogo.png':'assets/applicationIcons/whiteLogo.png',
                            width: 70,
                            height: 70,
                          )
                              :ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: FadeInImage.assetNetwork(
                              placeholder:
                              theme=="light"?
                              'assets/applicationIcons/whiteLogo.png':'assets/applicationIcons/whiteLogo.png',
                              placeholderScale: 0.5,
                              imageErrorBuilder:(context, error, stackTrace) => Icon(
                                Icons.person,color:Colors.black,
                                size: 50.0,
                              ),
                              width: 70,
                              height: 70,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[

                          widget.loggedUser==null?ClipRRect(
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
                                                        widget.loggedUser.uid),
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
                          Container(width: size.width*.65,
                            child: Center(
                              child: Text(
                               getTranslated(context, "search"),
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
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
          ),
          SizedBox(height: 25,),
          name==""?Expanded(
            child: Center(
              child: SizedBox()
            ),
          ):Expanded(
            child: PaginateFirestore(
              key: ValueKey(filterQuery),
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  ConsultantListItem(
                    consult: GroceryUser.fromFirestore(documentSnapshot[index]),
                    loggedUser: widget.loggedUser,
                    theme:theme
                );
              },

              query:filterQuery,
              isLive: true,
            ),
          )


        ],
      ),
        Positioned(
            right: 0.0,
            top: size.height*.24,
            left: 0,
            child:  Center(child: Container(height: 50,width: size.width*.9,child:
               Container(
                  //height: 35.0,
                  //width: size.width*.45,
                  padding: const EdgeInsets.symmetric( horizontal: 1.0, vertical: 0.0),
                  decoration: BoxDecoration(
                    color: theme=="light"?Colors.white:Color(0xff3f3f3f),
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
                  child: TextField(
                    onChanged: (val) => initiateSearch(val),
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
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                        size: 25.0,
                      ),
                      border: InputBorder.none,
                      hintText: getTranslated(context, "nameSearch"),
                      hintStyle: GoogleFonts.cairo(
                        fontSize: 14.5,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ),)
        ),
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
  void initiateSearch(String val) {
    setState(() {
      name = val.toLowerCase().trim();
      filterQuery=FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('userType', isEqualTo: "CONSULTANT" )
          .where('accountStatus', isEqualTo: "Active" )
          .where('searchIndex', arrayContains: name)
          .orderBy('rating', descending: true);
    });
  }
}
