// @dart=2.9

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/screens/orderDetailsScreen.dart';
import 'package:intl/intl.dart';



class OrderListItem extends StatelessWidget {
  final Orders order;
  final String type;
  final String theme;
  final bool fromSupport;
  OrderListItem({this.order, this.type, this.theme, this.fromSupport});
  @override
  Widget build(BuildContext context) {
    String lang=getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat('MM/dd/yy');
    return Column(
      children: [
        InkWell(
          splashColor: Colors.green.withOpacity(0.5),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetails(
                  order: order,
                  type:type,
                    fromSupport:fromSupport,
                ), ),);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              
                Expanded(flex:3,
                  child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10,right: 10),
                        child: Text(
                          //type!="USER"?order.user.name==null?getTranslated(context, "noName"):order.user.name:order.consult.name,
                          type!="USER"?order.user.name:order.consult.name,

                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.cairo(
                            color: theme=="light"?Colors.white:Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Row( mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.call_sharp,
                            size: 18,
                            color:theme=="light"?Colors.white:Colors.black,
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                getTranslated(context, "packageCall")+": ",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: theme=="light"?Colors.white:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                order.packageCallNum.toString(),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: theme=="light"?Colors.white:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20,),

                        ],
                      ),
                      Row( mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.call_sharp,
                            size: 18,
                            color:theme=="light"?Colors.white:Colors.black,
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                getTranslated(context, "answeredCall")+": ",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: theme=="light"?Colors.white:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                order.answeredCallNum.toString(),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: Colors.green,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20,),

                        ],
                      ),
                      Row( mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.call_sharp,
                            size: 18,
                            color:theme=="light"?Colors.white:Colors.black,
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                getTranslated(context, "remainingCall")+": ",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: theme=="light"?Colors.white:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                order.remainingCallNum.toString(),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: Colors.red,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20,),

                        ],
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.attach_money_sharp,
                            size: 18,
                            color:theme=="light"?Colors.white:Colors.black,
                          ),
                          Text(
                            getTranslated(context, "callprice")+": ",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: 15.0,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            double.parse(order.callPrice.toString()).toStringAsFixed(3)+"\$",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                    ],),
                ),
                Expanded(flex:1,
                  child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${dateFormat.format(order.orderTimestamp.toDate())}',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.cairo(
                          color: theme=="light"?Colors.white:Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        double.parse(order.price.toString()).toStringAsFixed(0)+"\$",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.cairo(
                          color: theme=="light"?Colors.white:Colors.black,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Icon(
                        Icons.arrow_forward,
                        size: 25,
                        color:theme=="light"?Colors.white:Colors.black,
                      ),

                    ],),
                ),

              ],
            ),


          ),
        ),
        SizedBox(height: 20,)
      ],
    );
  }

}
