// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/user.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:uuid/uuid.dart';

import 'package:webview_flutter/webview_flutter.dart';

class AddFakeReviewScreen extends StatefulWidget {
final GroceryUser user;

  const AddFakeReviewScreen({Key key, this.user}) : super(key: key);
  @override
  _AddFakeReviewScreenState createState() => _AddFakeReviewScreenState();
}

class _AddFakeReviewScreenState extends State<AddFakeReviewScreen>with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  GroceryUser consult;
  bool saving=false;
  String userName,consultPhone;
  dynamic rating=0.0,consultRating=0.0;
  String name="....",image="",theme;
  @override
  void initState() {
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            height:100,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Text(
                       "Add Fake Review",
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 3,
                        style: GoogleFonts.cairo(
                          color: theme=="light"?Colors.white:Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        validator: (String val) {
                          if (val.trim().isEmpty) {
                            return getTranslated(context, 'required');
                          }
                          return null;
                        },
                        onSaved: (val) {
                          userName=val;
                        },
                       enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        minLines: 1,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 15.0),
                          helperStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            // color: Colors.black54,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          //prefixIcon: Icon(Icons.title),
                          labelText: getTranslated(context, "userName"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        validator: (String val) {
                          if (val.trim().isEmpty) {
                            return getTranslated(context, 'required');
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consultPhone=val;
                        },
                       enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        minLines: 1,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 15.0),
                          helperStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            // color: Colors.black54,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          //prefixIcon: Icon(Icons.title),
                          labelText: getTranslated(context, "consultPhone"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
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
                        height: 25,
                      ),
                      Container(
                        height: 45.0,
                        width: double.infinity,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 0.0),
                        child: saving?Center(child: CircularProgressIndicator()):FlatButton(
                          onPressed: () {
                            save();
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.send,
                                color: theme=="light"?Colors.white:Colors.black,
                                size: 20.0,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                getTranslated(context, "save"),
                                style: GoogleFonts.poppins(
                                  color: theme=="light"?Colors.white:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                    ],
                  ),
                ),
              ),]
            ),
          ),
        ],
      ),
    );
  }
  Future<void> save222()async {

    try {
      String reviewId=Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.consultReviewsPath).doc(reviewId).set({
        'rating': double.parse((rating.toString())),
        'review': controller.text,
        'uid': widget.user.uid,
        'name': userName,
        //'image': user.photoUrl,
        'consultUid': consult.uid,
        'appointmentId':Uuid().v4(),
        'reviewTime':Timestamp.now(),
        'consultName': consult.name,
        'consultImage': consult.photoUrl,
        'type':'fake'
      } );
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

        Navigator.pop(context);
      } catch (e) {
        print("reviewwwwww"+e.toString());
        return null;
      }
      return true;
    } catch (e) {
      print("reviewwwwww222"+e.toString());
    }
  }
  save() async {
    List<GroceryUser> consults=[];
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try{
        setState(() {
          saving=true;
        });
        //get consultdata
        QuerySnapshot querySnapshot2 = await  FirebaseFirestore.instance.collection(Paths.usersPath)
            .where( 'phoneNumber', isEqualTo: consultPhone, ).get();

        for (var doc in querySnapshot2.docs) {
          consults.add(GroceryUser.fromFirestore(doc));
        }
        if(consults.length>0)
          consult=consults[0];

        if(consult!=null&&controller.text!=null&&rating!=0.0) {
          String reviewId=Uuid().v4();
          await FirebaseFirestore.instance.collection(Paths.consultReviewsPath).doc(reviewId).set({
            'rating': double.parse((rating.toString())),
            'review': controller.text,
            'uid': widget.user.uid,
            'name': userName,
            'image': "",
            'consultUid': consult.uid,
            'appointmentId':Uuid().v4(),
            'reviewTime':Timestamp.now(),
            'consultName': consult.name,
            'consultImage': consult.photoUrl,
            'type':'fake'
          } );
          List<ConsultReview> reviews;
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
          appointmentDialog(MediaQuery.of(context).size,"add done successfully",true);
        }
        else
        {
          appointmentDialog(MediaQuery.of(context).size,"something goes wrong",false);
        }
        setState(() {
          saving=false;
        });
      }catch(e)
      {print("rrrrrrrrrr"+e.toString());}
    }

  }
  appointmentDialog(Size size,String data,bool status) {

    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
             " Fake review",
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
              status?"Success":"Error",
              style: GoogleFonts.cairo(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: status?Colors.black87:Colors.red,
              ),
            ),
            Text(
              data,
              style: GoogleFonts.cairo(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Center(
              child: Container(
                width: size.width*.5,
                child: FlatButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: GoogleFonts.cairo(
                      color: Colors.black87,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ), barrierDismissible: false,
      context: context,
    );
  }
}
