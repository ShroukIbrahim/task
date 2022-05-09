// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/userPaymentHistory.dart';
import 'package:grocery_store/widget/techAppointmentWidget.dart';
import 'package:grocery_store/widget/userPaymentHistoryListItem.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class UserPaymentHistoryScreen extends StatefulWidget {
  final GroceryUser user;

  const UserPaymentHistoryScreen({Key key, this.user}) : super(key: key);
  @override
  _UserPaymentHistoryScreenState createState() => _UserPaymentHistoryScreenState();
}

class _UserPaymentHistoryScreenState extends State<UserPaymentHistoryScreen>with SingleTickerProviderStateMixin {
String theme;
  @override
  void initState() {
    super.initState();
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
    Size size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                  child: Container(height: 80,
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
                                  color:theme=="light"? Colors.white:Colors.black,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "paymentHistory"),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 19.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
                //Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  UserPaymentHistoryListItem(
                    history: UserPaymentHistory.fromFirestore(documentSnapshot[index]),);
                },
                query: FirebaseFirestore.instance.collection(Paths.userPaymentHistory)
                    .where('userUid', isEqualTo: widget.user.uid)
                    .orderBy('payDateValue', descending: true),
                isLive: true,
              ),
            )

          ],
        ),

      ]),
    );
  }
}
