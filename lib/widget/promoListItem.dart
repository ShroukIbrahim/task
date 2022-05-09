// @dart=2.9
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/promoCode.dart';
import 'package:grocery_store/screens/promoCodesScreens/editPromoCodeScreen.dart';



class PromoListItem extends StatelessWidget {
  final PromoCode code;
  final theme;
  PromoListItem({this.code, this.theme});
  @override
  Widget build(BuildContext context) {
    String lang=getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        InkWell(
          splashColor:
          Colors.red.withOpacity(0.5),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPromoCodeScreen(promoCode:code ), ),  );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child:   Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check,
                          size: 18,
                          color:code.promoCodeStatus?Colors.green:Colors.red,
                        ),
                        Text(
                          code.code,
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


                      ],
                    ),
                    Container(
                      height: 35.0,
                      child: FlatButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code.code));
                          showSnack(getTranslated(context, "copyDone"),context);
                        },
                        color:  code.promoCodeStatus?Colors.green:Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                         getTranslated(context,"copy"),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person,
                      size: 18,
                      color:AppColors.white,
                    ),
                    Text(
                      getTranslated(context, "owner")+": "+code.ownerName,
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
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      size: 18,
                      color: theme=="light"?Colors.white:Colors.black,
                    ),
                    Text(
                      getTranslated(context, "discount")+": "+code.discount.toString()+"%",
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
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.addchart_outlined,
                      size: 18,
                      color: theme=="light"?Colors.white:Colors.black,
                    ),
                    Text(
                      getTranslated(context, "usedNumber")+": "+code.usedNumber.toString(),
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

                  ],
                ),

              ],),


          ),
        ),
        SizedBox(height: 20,)
      ],
    );
  }
  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade500,
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
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.error,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

}
