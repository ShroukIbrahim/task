// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/consultReviewWidget.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ReviewScreens extends StatefulWidget {
  final GroceryUser consult;
  final int reviewLength;
  const ReviewScreens({Key key, this.consult, this.reviewLength}) : super(key: key);
  @override
  _ReviewScreensState createState() => _ReviewScreensState();
}

class _ReviewScreensState extends State<ReviewScreens> {
  List<ConsultReview>reviews;
  String theme;
  @override
  void dispose() {
    super.dispose();
  }
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
    dynamic rating=0.0;
   String star=getTranslated(context, "stars");
   rating=(widget.consult.rating==null)?0.0:widget.consult.rating;
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body:Stack(children: [
          Column(children: [
            SizedBox(height: 200,),

            Center(
              child: Column(
                children: [
                  Text(
                    widget.consult.name,
                    style: GoogleFonts.cairo(
                      fontSize: 15.0,
                      color:theme=="light"?AppColors.black:AppColors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  widget.consult.userType=="CONSULTANT"?SizedBox(height: 5,):SizedBox(),
                  widget.consult.userType=="CONSULTANT"?SmoothStarRating(
                    allowHalfRating: true,
                    starCount: 5,
                    rating: double.parse(rating.toString()),
                    size: 20.0,
                    isReadOnly: true,
                    color: AppColors.yellow,
                    borderColor:AppColors.yellow,
                    spacing: 1.0,
                  ):SizedBox(),
                  widget.consult.userType=="CONSULTANT"?SizedBox(height: 5,):SizedBox(),
                  widget.consult.userType=="CONSULTANT"?Text(
                    '$rating  $star',
                    style: GoogleFonts.cairo(
                      fontSize: 13.0,
                      color:theme=="light"?AppColors.black:AppColors.white,
                      //fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ):SizedBox(),
                ],
              ),
            ),
            widget.reviewLength!=0? Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  ConsultReviewWidget(
                    review: ConsultReview.fromFirestore(documentSnapshot[index]), );
                },
                query: widget.consult.userType=="CONSULTANT"? FirebaseFirestore.instance.collection('ConsultReview')
                    .where('consultUid', isEqualTo: widget.consult.uid)
                    .orderBy("reviewTime", descending: true):
                FirebaseFirestore.instance.collection('ConsultReview')
                    .where('uid', isEqualTo: widget.consult.uid)
                    .orderBy("reviewTime", descending: true),
                // to fetch real-time data
                isLive: true,
              ),
            ):
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/cancel_order.png',
                      width: size.width * 0.6,
                      height: 200,
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      getTranslated(context, "noReviews"),
                      style: GoogleFonts.cairo(
                        color: Colors.black87,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],),
          Container(
              width: size.width,
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(00.0),
                  bottomRight: Radius.circular(00.0),
                ),
              ),
              child: SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 5.0, right: 5.0, top: 0.0, bottom: 16.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
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
                            getTranslated(context, "Reviews"),
                            textAlign:TextAlign.left,

                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 10,),
                        ],
                      ),
                  ))),
          Positioned(
            right: 0.0,
            top: 110.0,
            left: 0,
            child: Center(
              child: Container(
                padding:const EdgeInsets.all(5),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:theme=="light"? Colors.purple[200]:Colors.orange[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/applicationIcons/whiteLogo.png',
                    placeholderScale: 0.5,
                    imageErrorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,color:Colors.black,
                      size: 50.0,
                    ),
                    image: widget.consult.photoUrl!=""?widget.consult.photoUrl:"",
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 250),
                    fadeInCurve: Curves.easeInOut,
                    fadeOutDuration: Duration(milliseconds: 150),
                    fadeOutCurve: Curves.easeInOut,
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }


}
