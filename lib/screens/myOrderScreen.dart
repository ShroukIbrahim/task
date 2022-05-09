// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/orderListItem.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class MyOrdersScreen extends StatefulWidget {
  final GroceryUser user;
  final String loggedType;
  final bool fromSupport;
  const MyOrdersScreen({Key key, this.user, this.loggedType, this.fromSupport}) : super(key: key);
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>with SingleTickerProviderStateMixin {
  List<GroceryUser> activeList;
  final TextEditingController searchController = new TextEditingController();
  bool load=false,open=true,closed=false,summary=false;
  String lang,userImage,theme;
  String name ="";
  Query filterQuery;
  String from,to;
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  bool  loadingNumber=false,loadingEarn=false;
  String filterEarn,filterOrders;
  @override
  void initState() {
    super.initState();
    from="From";//DateTime(2020,01, 01 ).toString().substring(0,10);
    to="To";//DateTime.now().toString().substring(0,10);
    filterEarn="0";
    filterOrders="0";
    activeList = [];

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
                          getTranslated(context, "orders"),
                          style: GoogleFonts.poppins(
                            color: theme=="light"?Colors.white:Colors.black,
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
            open?Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  OrderListItem(
                      order: Orders.fromFirestore(documentSnapshot[index]),
                      type:widget.loggedType,//widget.user.userType,//.user.userType
                      fromSupport:widget.fromSupport,
                      theme:theme
                  );

                },
                query: widget.user.userType=="CONSULTANT"?FirebaseFirestore.instance.collection(Paths.ordersPath)
                    .where('consult.uid', isEqualTo: widget.user.uid)
                    .where('orderStatus', whereIn: ["open","completed"])
                    .orderBy('orderTimestamp', descending: true):
                FirebaseFirestore.instance.collection(Paths.ordersPath)
                    .where('user.uid', isEqualTo: widget.user.uid)
                    .where('orderStatus', whereIn: ["open","completed"])
                    .orderBy('orderTimestamp', descending: true),
                isLive: true,
              ),
            ):SizedBox(),
            closed?Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  OrderListItem(
                      order: Orders.fromFirestore(documentSnapshot[index]),
                      type:widget.loggedType,//widget.user.userType,
                      fromSupport:widget.fromSupport,
                      theme:theme
                  );
                },

                query: widget.user.userType=="CONSULTANT"?FirebaseFirestore.instance.collection(Paths.ordersPath)
                    .where('consult.uid', isEqualTo: widget.user.uid)
                    .where('orderStatus', isEqualTo: "closed")
                    .orderBy('orderTimestamp', descending: true):
                FirebaseFirestore.instance.collection(Paths.ordersPath)
                    .where('user.uid', isEqualTo: widget.user.uid)
                    .where('orderStatus', isEqualTo: "closed")
                    .orderBy('orderTimestamp', descending: true),
                isLive: true,
              ),
            ):SizedBox(),
            summary?Column(children: [
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  getTranslated(context, "summary"),
                  style: GoogleFonts.poppins(
                    color: theme=="light"?Colors.black87:Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.blue.withOpacity(0.3),
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.01),
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                  color: Colors.black.withOpacity(0.08),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    getTranslated(context, "ordersNum"),
                                    overflow: TextOverflow.clip,
                                    style: GoogleFonts.poppins(
                                      color: theme=="light"?Colors.black87:Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          widget.user.ordersNumbers==null?'0':widget.user.ordersNumbers.toString(),
                                          style: GoogleFonts.poppins(
                                            color: theme=="light"?Colors.black87:Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.blue.withOpacity(0.3),
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.01),
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                  color: Colors.black.withOpacity(0.08),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    widget.user.userType=="USER"?getTranslated(context, "payed"): getTranslated(context, "totalEarn"),
                                    overflow: TextOverflow.clip,
                                    style: GoogleFonts.poppins(
                                      color: theme=="light"?Colors.black87:Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                      widget.user.payedBalance==null?"0":'\$'+double.parse( widget.user.payedBalance.toString()).toStringAsFixed(2),
                                          style: GoogleFonts.poppins(
                                            color: theme=="light"?Colors.black87:Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25,),
              Center(
                child: Text(
                  getTranslated(context, "filter"),
                  style: GoogleFonts.poppins(
                    color: theme=="light"?Colors.black87:Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    splashColor:
                    Colors.white.withOpacity(0.5),
                    onTap: () {
                      _selectFromDate(context);
                    },
                    child: Container(height: 40,width: size.width*.4,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.purple, //                   <--- border color
                          width: 1.0,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child:Center(
                        child: Text(
                          from,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color:Colors.grey,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5,),
                  InkWell(
                    splashColor:
                    Colors.white.withOpacity(0.5),
                    onTap: () {
                      _selectToDate(context);
                    },
                    child: Container(height: 40,width: size.width*.4,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.purple, //                   <--- border color
                          width: 1.0,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child:Center(
                        child: Text(
                          to,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color:Colors.grey,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                height: 40.0,

                child:FlatButton(
                  onPressed: () {
                    calculateOrderNumbers();
                    if(widget.user.userType=="USER")
                      setState(() {
                        loadingEarn=false;
                      });
                    else
                      calculateTotalEarn();
                  },
                  color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Text(
                    getTranslated(context, "results"),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              (loadingNumber==false&&loadingEarn==false)?Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.blue.withOpacity(0.3),
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.01),
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                  color: Colors.black.withOpacity(0.08),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    getTranslated(context, "ordersNum"),
                                    overflow: TextOverflow.clip,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    filterOrders,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.blue.withOpacity(0.3),
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.01),
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                  color: Colors.black.withOpacity(0.08),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    getTranslated(context, "totalEarn"),
                                    overflow: TextOverflow.clip,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    filterEarn,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ):Center(child: CircularProgressIndicator()),
              SizedBox(
                height: 15.0,
              ),
            ],):SizedBox(),
          ],
        ),
        Positioned(
            right: 0.0,
            top: 100.0,
            left: 0,
            child:  Center(
              child:  Container(height: 60,width: size.width*.9,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 0.0),
                        blurRadius: 15.0,
                        spreadRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                  child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          splashColor: Colors.green.withOpacity(0.5),
                          onTap: () {
                            setState(() {
                              open=true;
                              closed=false;
                              summary=false;
                            });
                          },
                          child: Container(height: 40,width: size.width*.25,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: open?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "openOrders"),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  color: open?theme=="light"?Colors.white:Colors.white:theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),),
                        ),
                        SizedBox(width: 5,),
                        InkWell(
                          splashColor: Colors.green.withOpacity(0.5),
                          onTap: () {
                            setState(() {
                              closed=true;
                              open=false;
                              summary=false;
                            });
                          },
                          child: Container(height: 40,width: size.width*.25,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: closed?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "closedOrders"),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  color: closed?theme=="light"?Colors.white:Colors.white:theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),),
                        ),
                        SizedBox(width: 5,),
                        InkWell(
                          splashColor: Colors.green.withOpacity(0.5),
                          onTap: () {
                            setState(() {
                              closed=false;
                              open=false;
                              summary=true;
                            });
                          },
                          child: Container(height: 40,width: size.width*.25,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: summary?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "summary"),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  color: summary?theme=="light"?Colors.white:Colors.white:theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),),
                        ),
                      ])
              ),
            )
        ),
      ]),
    );
  }

  calculateOrderNumbers() async {
    setState(() {
      loadingNumber=true;
    });
    QuerySnapshot querySnapshot;
    if(widget.user.userType=="USER")
      querySnapshot = await FirebaseFirestore.instance.collection(Paths.ordersPath)
          .where('user.uid', isEqualTo: widget.user.uid)
          .where('orderTimeValue', isGreaterThanOrEqualTo: selectedFromDate.millisecondsSinceEpoch)
          .where('orderTimeValue', isLessThanOrEqualTo: selectedToDate.millisecondsSinceEpoch)
          .get();
    else
      querySnapshot = await FirebaseFirestore.instance.collection(Paths.ordersPath)
          .where('consult.uid', isEqualTo: widget.user.uid)
          .where('orderTimeValue', isGreaterThanOrEqualTo: selectedFromDate.millisecondsSinceEpoch)
          .where('orderTimeValue', isLessThanOrEqualTo: selectedToDate.millisecondsSinceEpoch)
          .get();
    if(querySnapshot.docs.length>0)
    {
      if(widget.user.userType=="USER")
      {
        double total=0;
        for (var item in querySnapshot.docs) {
          total=total+double.parse(item['price'].toString());
        }
        setState(() {
          filterEarn=total.toString()+"\$";
          loadingEarn=false;
        });
      }
      setState(() {
        filterOrders=querySnapshot.docs.length.toString();
        loadingNumber=false;
      });
    }
    else
    {
      setState(() {
        filterOrders="0";
        loadingNumber=false;
      });
    }
  }
  calculateTotalEarn() async {
    setState(() {
      loadingEarn=true;
    });
    double total=0;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.payHistoryPath)
        .where('consultUid',  isEqualTo: widget.user.uid)
        .where('payDate', isGreaterThanOrEqualTo: selectedFromDate.millisecondsSinceEpoch)
        .where('payDate', isLessThanOrEqualTo: selectedToDate.millisecondsSinceEpoch)
        .get();
    if(querySnapshot.docs.length>0)
    {
      for (var item in querySnapshot.docs) {
        total=total+double.parse(item['balance'].toString());
      }
      setState(() {
        filterEarn=total.toString()+"\$";
        loadingEarn=false;
      });
    }
    else
    {
      setState(() {
        filterEarn="0";
        loadingEarn=false;
      });
    }
  }
  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedFromDate)
      setState(() {
        selectedFromDate = picked;
        from = selectedFromDate.toString().substring(0, 10);
      });
  }
  Future<void> _selectToDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedToDate)
      setState(() {
        selectedToDate = picked;
        to=selectedToDate.toString().substring(0,10);
      });
  }
}
