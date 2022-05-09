// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/user.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:uuid/uuid.dart';

class AddReviewScreen extends StatefulWidget {
  final String consultId;
  final String userId;
  final String appointmentId;
  const AddReviewScreen({Key key, this.consultId, this.userId, this.appointmentId}) : super(key: key);
  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController controller = TextEditingController();
  String theme;
  bool load=true, adding=false;
  GroceryUser consult,user;
  dynamic rating=0.0,consultRating=0.0;
  String name="....",image="";
  RatingDialog _dialog ;
  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    print("gggsdsds");
    print(widget.appointmentId);
    print(widget.consultId);
    print(widget.userId);
    print("gggsdsdsqqqqqq");
    getConsultDetails();

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
Future<void> getConsultDetails() async {
  DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.consultId);
  final DocumentSnapshot documentSnapshot = await docRef.get();

  DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.userId);
  final DocumentSnapshot documentSnapshot2 = await docRef2.get();
  setState(() {
    consult= GroceryUser.fromFirestore(documentSnapshot);
    print("userdataqqq");
    print(consult.name);
    name=consult.name;
    image=consult.photoUrl;
    consultRating=(consult.rating==null)?0.0:consult.rating;
    user=GroceryUser.fromFirestore(documentSnapshot2);
    print("userdata");
    print(user.name);
    load=false;
  });

}
  @override
  Widget build(BuildContext context) {

    String star=getTranslated(context, "stars");
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset:false,
        body:Stack(children: [
          Column(children: [
              SizedBox(height: 200,),
              Center(
                child: Column(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: 15.0,
                        color:theme=="light"?AppColors.black:AppColors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 5,),
                    SmoothStarRating(
                      allowHalfRating: true,
                      starCount: 5,
                      rating: double.parse(consultRating.toString()),
                      size: 20.0,
                      isReadOnly: true,
                      color: AppColors.yellow,
                      borderColor:AppColors.yellow,
                      spacing: 1.0,
                    ),
                    SizedBox(height: 5,),
                    Text(
                      consultRating.toString()+star,
                      style: GoogleFonts.cairo(
                        fontSize: 13.0,
                        color:theme=="light"?AppColors.black:AppColors.white,
                        //fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
               Expanded(
                child:   Padding(
                  padding: const EdgeInsets.all(20.0),
                  child:Column(children: [

                    Row(
                      children: [
                        Text(
                          getTranslated(context, "rateConsult")+":-",
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Center(
                      child: SmoothStarRating(
                        allowHalfRating: true,
                        onRated: (v) {
                          setState(() {
                            rating = v;
                          });
                        },
                        starCount: 5,
                        rating: rating,
                        size: 38.0,
                        isReadOnly: false,
                        color: Colors.orange.shade500,
                        borderColor: Colors.orange.shade500,
                        spacing: 1.0,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        maxLines: 10,
                        controller: controller,

                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 11.0,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color:  Colors.grey[100],
                              width: 0.0,
                            ),
                          ),
                          /* border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:  BorderSide(color: Colors.white ),
                                ),*/
                          contentPadding: EdgeInsets.all(10),
                          helperStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.65),
                            letterSpacing: 0.5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: 11.0,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                          hintText: getTranslated(context,'rateConsult'),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 15.0,
                    ),
                    Center(
                      child: adding?CircularProgressIndicator():SizedBox(
                        height:50,
                        width: size.width * 0.7,
                        child: FlatButton(
                          onPressed: () {
                            //rate event
                            if (rating > 0.0) {
                              //proceed
                            addReview();
                            }
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                          getTranslated(context,"rate"),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],),
                ) ,
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
                                  color: Colors.white,
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
                            color: Colors.white,
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
                  color: Colors.purple[200],
                ),
                child: consult==null?CircularProgressIndicator():ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/applicationIcons/whiteLogo.png',
                    placeholderScale: 0.5,
                    imageErrorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,color:Colors.black,
                      size: 50.0,
                    ),
                    image: consult.photoUrl!=""?consult.photoUrl:"",
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
  Future<void> addReview()async {
    setState(() {
      adding=true;
    });
    String reviewId=Uuid().v4();
    try {
      await FirebaseFirestore.instance.collection(Paths.consultReviewsPath).doc(reviewId).set({
        'rating': double.parse((rating.toString())),
        'review': controller.text,
        'uid': user.uid,
        'name': user.name,
        'image': user.photoUrl,
        'consultUid': consult.uid,
        'appointmentId':widget.appointmentId,
        'reviewTime':Timestamp.now(),
        'consultName': consult.name,
        'consultImage': consult.photoUrl,
      }
      );
      //update user review
      List<ConsultReview> reviews;
      try {
        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection(Paths.consultReviewsPath)
            .where('consultUid', isEqualTo: consult.uid)
            .get();

        reviews = List<ConsultReview>.from(
          (snap.docs).map(
                (e) => ConsultReview.fromFirestore(e),
          ),
        );
        double _rating=0;
        if (reviews.length > 0) {
          for (var review in reviews) {
            _rating = _rating + double.parse(review.rating.toString());
          }
          _rating = _rating / reviews.length;
          _rating=double.parse((_rating.toStringAsFixed(1)));
          await FirebaseFirestore.instance.collection(Paths.usersPath).doc(consult.uid).set({
            'rating': _rating,
            'reviewsCount':reviews.length,

          }, SetOptions(merge: true));
        }
        setState(() {
          adding=false;
        });
        Navigator.pop(context);
      } catch (e) {
        print("reviewwwwww"+e.toString());
      }
    } catch (e) {
      print("reviewwwwww222"+e.toString());
    }
  }

}
