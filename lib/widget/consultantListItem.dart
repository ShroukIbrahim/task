// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/consultantDetailsScreen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ConsultantListItem extends StatelessWidget {
  final GroceryUser loggedUser;
  final GroceryUser consult;
  final String theme;

  ConsultantListItem({this.consult, this.loggedUser, this.theme});

  @override
  Widget build(BuildContext context) {
    String lang = getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    String languages = "";
    bool avaliable = false;
    DateTime _now = DateTime.now();
    String dayNow = _now.weekday.toString();
    int timeNow = _now.hour;
    if (consult.workDays.contains(dayNow)) {
      int localFrom = DateTime.parse(consult.fromUtc).toLocal().hour;
      int localTo = DateTime.parse(consult.toUtc).toLocal().hour;
      if (localTo == 0) localTo = 24;
      if (localFrom <= timeNow && localTo > timeNow) {
        avaliable = true;
      }
    }
    if (consult.languages.length > 0)
      consult.languages.forEach((element) {
        languages = languages + " " + element;
      });
    return InkWell(

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsultantDetailsScreen(
                consultant: consult, loggedUser: loggedUser, theme: theme),
          ),
        );
      },
      child:

                  Container(
                    height: size.height * 0.36
                    ,
                    width: size.width * 0.45,
                    decoration: BoxDecoration(
                      color: theme == "light"
                          ? AppColors.white
                          : Theme.of(context).primaryColor,
                      //Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 0.0),
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top:0,
                          right: 5,
                          left: 5,

                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: InkWell(
                                          splashColor: Colors.white.withOpacity(0.5),
                                          onTap: () {},
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border:
                                              Border.all(color: Colors.white, width: 2),
                                              shape: BoxShape.circle,
                                              color:
                                              avaliable ? AppColors.brown : Colors.red,
                                            ),
                                            width: 15.0,
                                            height: 15.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      avaliable?"online":"ofline",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color:  Colors.black26,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                DottedBorder(
                                  color: AppColors.yellow,
                                  dashPattern: [8, 4],
                                  borderType: BorderType.Circle,
                                  radius: Radius.circular(50),
                                  padding: EdgeInsets.all(6),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                    child: Container(

                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey, width: 1),
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: consult.photoUrl.isEmpty
                                          ? Image.asset(
                                        'assets/applicationIcons/whiteLogo.png',
                                        width: 60,
                                        height: 60,
                                      )
                                      //Icon( Icons.person,color:Colors.black,size: 50.0, )
                                          : ClipRRect(
                                        borderRadius: BorderRadius.circular(100.0),
                                        child: FadeInImage.assetNetwork(
                                          placeholder: 'assets/images/load.gif',
                                          placeholderScale: 0.5,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                              Image.asset(
                                                'assets/applicationIcons/whiteLogo.png',
                                                width: 60,
                                                height: 60,
                                              ),
                                          image: consult.photoUrl,
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
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, 0.0),
                                            blurRadius: 5.0,
                                            spreadRadius: 1.0,
                                            color: Colors.black.withOpacity(0.1),
                                          ),
                                        ],

                                      ),

                                      child:
                                      IconButton(
                                        onPressed: () {

                                        },
                                        icon:Icon(Icons.share_rounded,color :Colors.black,),
                                        // Image.asset(widget.theme=="light"?
                                        // 'assets/applicationIcons/Iconly-Curved-Category.png' : 'assets/applicationIcons/dashbord.png',


                                      ),


                                    ),
                                    Text(
                                      'share',
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        color:  Colors.black,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
//-----------------------rate------------------
                         Positioned(
                           top: 80,
                           left: 5,
                           right: 5,

                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RatingBar.builder(
                                  initialRating:
                                  consult.rating == null ? 0 : consult.rating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 20,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: AppColors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {
                                    rating=consult.rating;
                                  },
                                ),
                                // Row(mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     Icon(
                                //       Icons.star,
                                //       color: AppColors.yellow,
                                //     ),
                                //     Text(
                                //       consult.rating==null?"0": consult.rating.toStringAsFixed(1),
                                //       textAlign: TextAlign.start,
                                //       overflow: TextOverflow.ellipsis,
                                //       softWrap: false,
                                //       maxLines: 1,
                                //       style: GoogleFonts.cairo(
                                //         color: theme=="light"?Colors.white:Colors.black,
                                //         fontSize: 11.0,
                                //         fontWeight: FontWeight.bold,
                                //         letterSpacing: 0.3,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Text(
                                  consult.name,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: GoogleFonts.cairo(
                                    color: theme == "light"
                                        ? Theme.of(context).primaryColor
                                        : Colors.white,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                    Icon(
                                      Icons.mic_none,
                                      size: 20,
                                      color: theme=="light"?AppColors.pink:AppColors.black,
                                    ),
                                Row(mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 25,
                                      width: size.width * .15,
                                      padding: const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: theme == "light"
                                            ? AppColors.lightGrey
                                            : AppColors.pink,
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          getTranslated(context, "arabic"),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.cairo(
                                            color:  theme == "light"
                                                ? AppColors.grey//Theme.of(context).primaryColor
                                                : Colors.black,
                                            fontSize: 11.0,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    Container(
                                      height: 25,
                                      width: size.width * .15,
                                      padding: const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: theme == "light"
                                            ? AppColors.lightGrey
                                            : AppColors.pink,
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          getTranslated(context, "english"),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.cairo(
                                            color:  theme == "light"
                                                ? AppColors.grey//Theme.of(context).primaryColor
                                                : Colors.black,
                                            fontSize: 11.0,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10,),
                                Positioned(
                                  bottom: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                consult.ordersNumbers == null
                                                    ? {'0' + '+'}
                                                    : consult.ordersNumbers < 100
                                                    ? consult.ordersNumbers.toString() + '+'
                                                    : consult.ordersNumbers < 1000
                                                    ? "+100"
                                                    : "+1000",
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                maxLines: 1,
                                                style: GoogleFonts.cairo(
                                                  color: theme == "light"
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              Image.asset(
                                                theme == "light"
                                                    ? 'assets/applicationIcons/greenCall.png'
                                                    : 'assets/applicationIcons/blackCall.png',
                                                width: 12,
                                                height: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          width: 50,
                                          height: 35,
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(30),
                                                  bottomRight: Radius.circular(30)),
                                              gradient: LinearGradient(
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                  colors: [
                                                    Color(0XFFF283792),
                                                    Color.fromRGBO(200, 50, 100, 75)
                                                  ])),
                                          child: Center(
                                            child: Text(
                                              consult.price + "\$",
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: GoogleFonts.cairo(
                                                color: AppColors.white,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.3,
                                              ),
                                              // Image.asset('assets/applicationIcons/v-w.png',
                                              //   width: 15,
                                              //   height: 15,
                                              // ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                         ),


                      ],
                    ),
                  ),






    );
  }
}
