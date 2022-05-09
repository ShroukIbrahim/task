// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/promoCode.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/promoListItem.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class InActivePromoScreen extends StatefulWidget {
  @override
  _InActivePromoScreenState createState() => _InActivePromoScreenState();
}

class _InActivePromoScreenState extends State<InActivePromoScreen>with SingleTickerProviderStateMixin {
  List<GroceryUser> activeList;
  final TextEditingController searchController = new TextEditingController();
  bool load=false;
  String lang,userImage,theme;
  String name ="";
  Query filterQuery;
  @override
  void initState() {
    super.initState();

    activeList = [];

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
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
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "notActivePromoCodes"),
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
            name==""?Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  PromoListItem(
                    code: PromoCode.fromFirestore(documentSnapshot[index]),
                  );

                },
                query: FirebaseFirestore.instance.collection(Paths.promoPath)
                    .where('promoCodeStatus', isEqualTo: false)
                    .orderBy('promoCodeTimestamp', descending: true),
                // to fetch real-time data
                isLive: true,
              ),
            ):SizedBox(),
            name!=""?Expanded(
              child: PaginateFirestore(
                key: ValueKey(filterQuery),
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  PromoListItem(
                    code: PromoCode.fromFirestore(documentSnapshot[index]),
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
            top: 100.0,
            left: 0,
            child:  Center(child: Container(height: 40,width: size.width*.8,child:
            Container(
              //height: 35.0,
              //width: size.width*.45,
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
                    prefixIcon: Image.asset(
                      'assets/applicationIcons/search.png',
                      width: 30,
                      height: 30,
                    ),
                    border: InputBorder.none,
                    // hintText: getTranslated(context, "nameSearch"),
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 14.5,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            ),)
        ),
      ]),
    );
  }

  void initiateSearch(String val) {
    setState(() {
      name = val.toLowerCase().trim();
      filterQuery=FirebaseFirestore.instance.collection(Paths.promoPath)
          .where('promoCodeStatus', isEqualTo: false)
          .orderBy('promoCodeTimestamp', descending: true);
    });
  }
}
