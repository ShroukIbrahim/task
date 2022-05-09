// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/consultPackage.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/promoCode.dart';
import 'package:grocery_store/models/user.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class OrderDetails extends StatefulWidget {
  final Orders order;
  final String type;
  final bool fromSupport;
  const OrderDetails({Key key, this.order, this.type, this.fromSupport}) : super(key: key);
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  consultPackage package;
  PromoCode promo;ConsultReview review;
  bool loadPackage=true,loadPromo=true,loadAppointments=true,loadReview=true;
  DateFormat dateFormat = DateFormat('MM/dd/yy');
  List<AppAppointments> appointmentList=[];
  bool cancel=false;
  String theme="";
  @override
  void initState() {
    super.initState();
    getPackageDetails();
    getOrderAppointment();
    if(widget.order.promoCodeId!=null)
      getPromoDetails();
    else
      loadPromo=false;

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
  Future<void> getPackageDetails() async {
    try{
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.packagesPath).doc(widget.order.packageId).get();
      setState(() {
        package = consultPackage.fromFirestore(documentSnapshot);
        loadPackage=false;
      });
    }catch(e){
      print("orderDetails"+e.toString());
    }
  }
  Future<void> getPromoDetails() async {
    try{
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.promoPath).doc(widget.order.promoCodeId).get();
      setState(() {
        promo = PromoCode.fromFirestore(documentSnapshot);
        loadPromo=false;
      });
    }catch(e){
      print("orderDetails"+e.toString());
    }
  }
  @override
  void dispose() {
    super.dispose();

  }

  void showSnakbar(String s,bool status) {
    SnackBar snackbar = SnackBar(
      content: Text(
        s,
        style: GoogleFonts.cairo(
          color: theme=="light"?Colors.white:Colors.black,
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

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key:_scaffoldKey,
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
                                  color: theme=="light"?Colors.white:Colors.black,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "details"),
                          style: GoogleFonts.poppins(
                            color: theme=="light"?Colors.white:Colors.black,
                            fontSize: 19.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        (widget.fromSupport&&widget.order.orderStatus!="closed"&&widget.order.orderStatus!="cancel")?cancel?CircularProgressIndicator():
                        InkWell(
                          splashColor:
                          Colors.white.withOpacity(0.5),
                          onTap: () async {
                               cancelDialog(size);
                          },
                          child: Container(height: 35,width: size.width*.3,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color:  Colors.red,
                                borderRadius: BorderRadius.circular(35.0),

                              ),child:  Center(
                                child: Text(
                                  getTranslated(context, "cancel"),
                                  style: GoogleFonts.cairo(
                                    color: theme=="light"?Colors.white:Colors.black,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),),
                              ),
                            ),
                        ):SizedBox(),

                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(physics:  AlwaysScrollableScrollPhysics(),children: [
                  Center(
                    child: Container(height: 395,width: size.width*.9,
                      decoration: BoxDecoration(
                        color: theme=="light"?Colors.white:Colors.grey[400],
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.white,width: 2),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 0.0),
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),child:Column(
                        children: [
                          Container(height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(25.0),

                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, "orderDetails"),
                                    style: GoogleFonts.cairo(
                                      color: theme=="light"?Colors.white:Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(),

                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .5,
                                      child: Text(
                                        getTranslated(context, "date"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        '${dateFormat.format(widget.order.orderTimestamp.toDate())}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .5,
                                      child: Text(
                                        getTranslated(context, "price"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                          widget.order.price==null?"0": widget.order.price.toString()+"\$",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .5,
                                      child: Text(
                                        getTranslated(context, "callprice"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        double.parse( widget.order.callPrice.toString()).toStringAsFixed(3)+"\$",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .5,
                                      child: Text(
                                        getTranslated(context, "packageCall"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        widget.order.packageCallNum.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .5,
                                      child: Text(
                                        getTranslated(context, "answeredCall"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        widget.order.answeredCallNum.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .5,
                                      child: Text(
                                        getTranslated(context, "remainingCall"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        widget.order.remainingCallNum.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .5,
                                      child: Text(
                                        getTranslated(context, "status"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        widget.order.orderStatus,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),



                        ],
                      ),),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: Container(height: 150,width: size.width*.9,
                      decoration: BoxDecoration(
                        color: theme=="light"?Colors.white:Colors.grey[400],
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.white,width: 2),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 0.0),
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),child:Column(
                        children: [
                          Container(height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(25.0),

                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, "consultDetails"),
                                    style: GoogleFonts.cairo(
                                      color: theme=="light"?Colors.white:Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(),

                                ],
                              ),
                            ),
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5,left: 5,right: 5),
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black,width: 1),
                                    shape: BoxShape.circle,
                                    color: theme=="light"?Colors.white:Colors.black,
                                  ),
                                  child: widget.order.consult.image.isEmpty ?
                                  Icon( Icons.person,color:Colors.black,size: 50.0, )
                                      :ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: FadeInImage.assetNetwork(
                                      placeholder:
                                      'assets/icons/icon_person.png',
                                      placeholderScale: 0.5,
                                      imageErrorBuilder:(context, error, stackTrace) => Icon(
                                        Icons.person,color:Colors.black,
                                        size: 50.0,
                                      ),
                                      image: widget.order.consult.image,
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
                              Expanded(flex:2,
                                child: Column(
                                  children: [
                                    Text(
                                      widget.order.consult.name,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Text(
                                      widget.order.consult.phone,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: Container(height: 150,width: size.width*.9,
                      decoration: BoxDecoration(
                        color: theme=="light"?Colors.white:Colors.grey[400],
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.white,width: 2),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 0.0),
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),child:Column(
                        children: [
                          Container(height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(25.0),

                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, "clientDetails"),
                                    style: GoogleFonts.cairo(
                                      color: theme=="light"?Colors.white:Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(),

                                ],
                              ),
                            ),
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5,left: 5,right: 5),
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black,width: 1),
                                    shape: BoxShape.circle,
                                    color: theme=="light"?Colors.white:Colors.black,
                                  ),
                                  child: widget.order.user.image.isEmpty ?
                                  Icon( Icons.person,color:Colors.black,size: 50.0, )
                                      :ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: FadeInImage.assetNetwork(
                                      placeholder:
                                      'assets/icons/icon_person.png',
                                      placeholderScale: 0.5,
                                      imageErrorBuilder:(context, error, stackTrace) => Icon(
                                        Icons.person,color:Colors.black,
                                        size: 50.0,
                                      ),
                                      image: widget.order.user.image,
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
                              Expanded(flex:2,
                                child: Column(
                                  children: [
                                    Text(
                                      widget.order.user.name,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Text(
                                      widget.order.user.phone,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: Container(height: 200,width: size.width*.9,
                      decoration: BoxDecoration(
                        color: theme=="light"?Colors.white:Colors.grey[400],
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.white,width: 2),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 0.0),
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),child:Column(
                        children: [
                          Container(height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(25.0),

                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, "package"),
                                    style: GoogleFonts.cairo(
                                      color: theme=="light"?Colors.white:Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(),

                                ],
                              ),
                            ),
                          ),
                          loadPackage?Center(child: CircularProgressIndicator()):Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .3,
                                      child: Text(
                                        getTranslated(context, "call"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        package.callNum.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .3,
                                      child: Text(
                                        getTranslated(context, "discount"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        package.discount.toString()+"%",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .3,
                                      child: Text(
                                        getTranslated(context, "price"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        package.price.toString()+"\$",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),


                        ],
                      ),),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: Container(height: 230,width: size.width*.9,
                      decoration: BoxDecoration(
                        color: theme=="light"?Colors.white:Colors.grey[400],
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.white,width: 2),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 0.0),
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),child:Column(
                        children: [
                          Container(height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(25.0),

                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, "proCodes"),
                                    style: GoogleFonts.cairo(
                                      color: theme=="light"?Colors.white:Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(),

                                ],
                              ),
                            ),
                          ),
                          widget.order.promoCodeId!=null?
                          loadPromo?Center(child: CircularProgressIndicator()):Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .3,
                                      child: Text(
                                        getTranslated(context, "proCodes"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        promo.code,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .3,
                                      child: Text(
                                        getTranslated(context, "discount"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        promo.discount.toString()+"%",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: size.width * .3,
                                      child: Text(
                                        getTranslated(context, "owner"),
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                    Container(width: size.width * .3,
                                      child: Text(
                                        promo.ownerName,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ):
                          Center(
                            child: Text(
                              getTranslated(context, "noData"),
                              style: GoogleFonts.cairo(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: Text(
                      getTranslated(context, "appointments"),
                      style: GoogleFonts.cairo(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(height:10,),
                  if (loadAppointments==false&&appointmentList.length==0)
                    Center(
                      child: Text(
                        getTranslated(context, "noData"),
                        style: GoogleFonts.cairo(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.3,
                        ),
                      ),
                    )
                  else ListView.separated(
                    itemCount: appointmentList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(0),
                    itemBuilder: (context, index) {
                      return Container(height: 50,width: size.width*.8,
                          padding: const EdgeInsets.only(left: 10,right: 10),
                          decoration: BoxDecoration(
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.grey[400],
                            borderRadius: BorderRadius.circular(25.0),
                            border: Border.all(color: Colors.grey[300],width: 2),

                          ),child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                           /* Text(
                              DateFormat.yMMMd().format(DateTime.parse( appointmentList[index].appointmentTimestamp.toDate().toString())).toString(), // Apr
                              style: GoogleFonts.cairo(
                                color: theme=="light"?Colors.white:Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),),*/
                            Row(mainAxisAlignment: MainAxisAlignment.start,children: [
                              Image.asset('assets/applicationIcons/Iconly-Two-tone-Calendar.png',
                                width: 25,
                                height: 25,
                              ),
                              SizedBox(width: 5,),
                              Text(
                                '${dateFormat.format(appointmentList[index].appointmentTimestamp.toDate())}: '+appointmentList[index].time.hour.toString()+":"+appointmentList[index].time.minute.toString(),
                                //appointmentList[index].appointmentTimestamp.toString().replaceAll("UTC+2", ""),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: theme=="light"?Colors.white:Colors.black,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],),
                            Text(
                              appointmentList[index].appointmentStatus,
                              style: GoogleFonts.cairo(
                                color:Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),),
                            appointmentList[index].appointmentStatus=="closed"? InkWell(
                              splashColor: Colors.white.withOpacity(0.5),
                              onTap: () {
                               showReview(size,appointmentList[index].appointmentId);
                              },
                              child: Icon(
                                Icons.star,
                                color: AppColors.yellow,
                              ),
                            ):SizedBox(width: 10,),
                          ],)
                      );
                    },
                    separatorBuilder:
                        (BuildContext context, int index) {
                      return SizedBox(
                        height: 8.0,
                      );
                    },
                  ),
                  SizedBox(height: 40,),

                ],),
              ),
            )


          ],
        ),


      ]),
    );
  }
  cancelDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
        backgroundColor:Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: Container(color:Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                getTranslated(context, "cancel"),
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
                getTranslated(context, "cancelOrder"),
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
                        Navigator.pop(context);
                       setState(() {
                         cancel=true;
                       });
                        QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection(Paths.usersPath)
                                       .where( 'uid', isEqualTo: widget.order.user.uid, ).limit(1).get();
                        if(querySnapshot!=null&&querySnapshot.docs.length!=0&&widget.order.orderStatus!="cancel") {
                          var userSearch = GroceryUser.fromFirestore(querySnapshot.docs[0]);
                          var price=0.0;
                          if(widget.order.consultType=="vocal"||widget.order.consultType=="glorified"){
                            await FirebaseFirestore.instance
                                .collection(Paths.appAppointments)
                                .where( 'orderId', isEqualTo: widget.order.orderId,)
                                .where( 'appointmentStatus', isEqualTo: "closed",)
                                .get().then((value) async {
                              if(value.docs.length>0) {
                                if(mounted)
                                  setState(() {
                                    //print()
                                    print((widget.order.packageCallNum - value.docs.length)*widget.order.callPrice);
                                    price =(widget.order.packageCallNum - value.docs.length)*widget.order.callPrice;
                                  });
                              }
                              else {
                                if(mounted)
                                  setState(() {
                                    price =(widget.order.packageCallNum)*widget.order.callPrice;
                                  });
                              }
                            }).catchError((err) {

                            });
                          }
                          else
                          {
                            await FirebaseFirestore.instance
                                .collection(Paths.forEverAppointmentsPath)
                                .where( 'orderId', isEqualTo: widget.order.orderId,)
                                .get().then((value) async {
                                  print(value.docs.length);
                                  print((widget.order.packageCallNum - value.docs.length)*widget.order.callPrice);
                              if(value.docs.length>0) {
                                  setState(() {
                                    price =(widget.order.packageCallNum - value.docs.length)*widget.order.callPrice;
                                  });

                              }
                              else {
                                  setState(() {
                                    price =(widget.order.packageCallNum)*widget.order.callPrice;
                                  });
                              }
                            }).catchError((err) {
                                print("fffferror"+err.toString());
                            });
                          }

                          dynamic balance=double.parse(price.toString());
                          if(userSearch.balance!=null)
                          {
                            balance=userSearch.balance+balance;
                             userSearch.balance=balance;
                          }
                          await FirebaseFirestore.instance.collection(Paths.usersPath).doc(userSearch.uid).set({
                            'balance': balance,
                          }, SetOptions(merge: true));
                          //update payment history
                          await FirebaseFirestore.instance.collection(Paths.userPaymentHistory).doc(Uuid().v4()).set({
                            'userUid': userSearch.uid,
                            'payType': "refund",
                            'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
                            'payDateValue':Timestamp.now().millisecondsSinceEpoch,
                            'amount':price.toString(),
                            'otherData': {
                              'uid': "fuHfYYjTmRf7rjkyIhxrqp1pPJ32",
                              'name': "jeras Application",
                              'image': "",
                              'phone': "..",
                            },
                          });
                          //cancel order
                          await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(widget.order.orderId).set({
                            'orderStatus': "cancel",
                          }, SetOptions(merge: true));
                          //cancel allAppontment
                          var querySnapshot2 = await FirebaseFirestore.instance.collection(Paths.appAppointments)
                              .where('orderId', isEqualTo:widget.order.orderId)
                              .where('appointmentStatus', whereIn:['new','open'])
                              .get();
                          for (var doc in querySnapshot2.docs) {
                            await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(doc.id).set({
                              'appointmentStatus':'cancel',
                            }, SetOptions(merge: true));
                          }

                        }
                       setState(() {
                          cancel=false;
                          widget.order.orderStatus="cancel";
                        });
                       //
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
      ), barrierDismissible: false,
      context: context,
    );
  }
  void showNoNotifSnack(String text,bool status) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: status?Colors.green.shade500:Colors.red.shade500,
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
        color: theme=="light"?Colors.white:Colors.black,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.cairo(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: theme=="light"?Colors.white:Colors.black,
        ),
      ),
    )..show(context);
  }
  Future<void> getOrderAppointment() async {
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .where( 'orderId', isEqualTo: widget.order.orderId)
          .get();
      if(querySnapshot.docs.length>0)
      {
        setState(() {
          appointmentList = List<AppAppointments>.from(
            querySnapshot.docs.map(
                  (snapshot) => AppAppointments.fromFirestore(snapshot),  ),);
          loadAppointments=false;
        });
      }
      else
        setState(() {
          appointmentList=[];
          loadAppointments=false;
        });

    }catch(e){
      print("getnumbererror"+e.toString());
    }
  }
  showReview(Size size,String appointmentId) async {

     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
         .collection(Paths.consultReviewsPath)
         .where( 'appointmentId', isEqualTo: appointmentId)
         .get();
      if(querySnapshot.docs.length>0)
      {
        setState(() {
          review = List<ConsultReview>.from(
            querySnapshot.docs.map(
                  (snapshot) => ConsultReview.fromFirestore(snapshot),  ),)[0];
          loadReview=false;
        });
      }
      else
        setState(() {
          review=null;
          loadReview=false;
        });

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
              getTranslated(context, "Reviews"),
              style: GoogleFonts.cairo(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            (loadReview==true)?Center(child: CircularProgressIndicator()):
            (loadReview==false&&review!=null)?Container(//height: 90,width: size.width,
                padding: const EdgeInsets.only(left: 10,right: 10,top:10),
                color: theme=="light"?Colors.white:Colors.black,child: Row(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black,width: 2),
                        shape: BoxShape.circle,
                        color: theme=="light"?Colors.white:Colors.black,
                      ),
                      child: review.image.isEmpty ?
                      Icon( Icons.person,color:Colors.black,size: 45.0, )
                          :ClipRRect( borderRadius: BorderRadius.circular(100.0),
                        child: FadeInImage.assetNetwork(
                          placeholder:
                          'assets/icons/icon_person.png',
                          placeholderScale: 0.5,
                          imageErrorBuilder:(context, error, stackTrace) => Icon(
                            Icons.person,color:Colors.black,
                            size: 45.0,
                          ),
                          image: review.image,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 2,right: 2),
                      child:  Column(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.name,
                            overflow:TextOverflow.ellipsis ,
                            style: GoogleFonts.cairo(
                              color: Theme.of(context).primaryColor,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),),
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.star,
                                size: 13,
                                color: Colors.orange,
                              ),
                              Text(
                                review.rating.toStringAsFixed(1),
                                textAlign: TextAlign.start,
                                style: GoogleFonts.cairo(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            review.review,
                            maxLines: 3,
                            overflow:TextOverflow.ellipsis ,
                            style: GoogleFonts.cairo(
                              color: Theme.of(context).primaryColor,
                              fontSize: 13.0,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 0.5,
                            ),),
                        ],),
                    ),

                  ],)
            ):Center(
              child: Text(
                getTranslated(context, "noReviews"),
                style: GoogleFonts.cairo(
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
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
