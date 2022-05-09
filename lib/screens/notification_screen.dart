// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/widget/notification_item.dart';
import 'package:grocery_store/widget/review_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_notification.dart' as prefix;

class NotificationScreen extends StatefulWidget {
  final UserNotification userNotification;

  const NotificationScreen({Key key, this.userNotification}) : super(key: key);
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>with SingleTickerProviderStateMixin {
  NotificationBloc notificationBloc;
  bool isLoading=true;
 String theme;
  String url="https://www.jeras.io/dream-app/?lang=ar",lang;
  @override
  void initState() {
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<prefix.Notification> notificationList =
    widget.userNotification.notifications.reversed.toList();
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
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
                      getTranslated(context, "notification"),
                      style: GoogleFonts.cairo(
                        color: theme=="light"?Colors.white:Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: () {
                            deleteUser();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: 38.0,
                            height: 35.0,
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
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
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              itemBuilder: (context, index) {
                return NotificationItem(
                  size: size,
                  userNotification: widget.userNotification,
                  notificationList: notificationList,
                  index: index,
                  theme:theme,
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 15.0,
                );
              },
              itemCount: notificationList.length,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> deleteUser() {
    String userUid=FirebaseAuth.instance.currentUser.uid;
    FirebaseFirestore.instance.collection('UserNotifications').doc(userUid).delete();
    notificationBloc.add(GetAllNotificationsEvent(userUid));
    Navigator.pop(context);

  }
}
