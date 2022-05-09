// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/userPaymentHistory.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:uuid/uuid.dart';



class UserPaymentHistoryListItem extends StatelessWidget {
  final UserPaymentHistory history;
  final String theme;
  UserPaymentHistoryListItem({this.history, this.theme});
  @override
  Widget build(BuildContext context) {
    String lang=getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    String languages="";
    return Stack(children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 35,),
          Container(
            // padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 0.0),
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30,),
                Text(
                  history.otherData.name,
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
                SizedBox(height: 10,),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 18,
                      color:theme=="light"?Colors.white:Colors.black,
                    ),
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(history.payDateValue).toString(),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: GoogleFonts.cairo(
                        color: theme=="light"?Colors.white:Colors.black,
                        fontSize: 15.0,
                        // fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Center(
                  child: Container(height: 35,width: size.width*.5,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color:  history.payType!="send"?Colors.green:Colors.red,
                      borderRadius: BorderRadius.circular(35.0),

                    ),child:  Center(
                      child: Text(
                        history.payType=="send"?getTranslated(context, "send"):history.payType=="refund"?getTranslated(context, "refund"):getTranslated(context, "receive"),
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),),
                    ),
                  ),
                ),

                SizedBox(height: 20,),
                InkWell(
                  splashColor:
                  Colors.white.withOpacity(0.5),
                  onTap: () async {

                  },
                  child: Container(
                    width: size.width,height: 50,
                    decoration: BoxDecoration(
                        color: theme=="light"?Colors.white:Colors.grey[200],
                        borderRadius: new BorderRadius.only(
                          bottomLeft: const Radius.circular(25.0),
                          bottomRight: const Radius.circular(25.0),
                        )
                    ),
                    child: Center(
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            double.parse(history.amount.toString()).toStringAsFixed(3)+"\$",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,)
        ],
      ),
      Center(
        child:    Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor,width: 3),
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: history.otherData.image.isEmpty ?
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
              image: history.otherData.image,
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
    ]);
  }

}
