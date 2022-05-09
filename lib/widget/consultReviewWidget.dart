// @dart=2.9
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/product.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConsultReviewWidget extends StatelessWidget {
  final ConsultReview review;
  ConsultReviewWidget({this.review});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(height:110,width: size.width,color:Colors.transparent,
        padding: const EdgeInsets.only(left: 10,right: 10,top:10),
        child: Row(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black,width: 2),
                shape: BoxShape.circle,
                //color: Colors.white,
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
            Expanded(flex:2,
              child: Column(crossAxisAlignment:CrossAxisAlignment.start,children: [
                      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                        Text(
                          review.name,
                          overflow:TextOverflow.ellipsis ,
                          style: GoogleFonts.cairo(
                            color:Theme.of(context).primaryColor,

                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),),
                        Row(mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.star,
                              size: 15,
                              color: AppColors.yellow,
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
                        )
                    ],),
                      Text(
                        review.review,
                        maxLines: 3,
                        textAlign:TextAlign.start ,
                        overflow:TextOverflow.ellipsis ,
                        style: GoogleFonts.cairo(
                          color: Theme.of(context).primaryColor,
                          fontSize: 13.0,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.5,
                        ),),
                    ],),
            ),
           /* Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2,right: 2),
                  child: Container(width: size.width*.5,
                    child: Column(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.name,
                          overflow:TextOverflow.ellipsis ,
                          style: GoogleFonts.cairo(
                            color:Theme.of(context).primaryColor,

                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),),
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
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.star,
                      size: 15,
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
                )
              ],
            ),*/

          ],)
    );
  }
}
