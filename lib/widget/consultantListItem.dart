// @dart=2.9
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/consultantDetailsScreen.dart';



class ConsultantListItem extends StatelessWidget {
  final GroceryUser loggedUser;
  final GroceryUser consult;
  final String theme;
  ConsultantListItem({this.consult,this.loggedUser, this.theme});
  @override
  Widget build(BuildContext context) {
    String lang=getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    String languages="";
    bool avaliable=false;
    DateTime _now = DateTime.now();
    String dayNow=_now.weekday.toString();
    int timeNow=_now.hour;
    if(consult.workDays.contains(dayNow)){
      int   localFrom= DateTime.parse(consult.fromUtc).toLocal().hour;
      int localTo=DateTime.parse(consult.toUtc).toLocal().hour;
      if(localTo==0)localTo=24;
      if (localFrom<=timeNow&&localTo>timeNow) {
        avaliable=true;

      }
    }
    if(consult.languages.length>0)
      consult.languages.forEach((element) { languages=languages+" "+element;});
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsultantDetailsScreen(
                consultant: consult,
                loggedUser: loggedUser,
                theme:theme
            ), ),);
      },
      child:Column(
        children: [
          Container(height: 80,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white,width: 1),
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: consult.photoUrl.isEmpty ?Image.asset('assets/applicationIcons/whiteLogo.png',width: 60,height: 60,)
                        //Icon( Icons.person,color:Colors.black,size: 50.0, )
                            :ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: FadeInImage.assetNetwork(
                            placeholder:'assets/images/load.gif',
                            placeholderScale: 0.5,
                            imageErrorBuilder:(context, error, stackTrace) => Image.asset('assets/applicationIcons/whiteLogo.png',width: 60,height: 60,),
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
                      Positioned(
                        bottom: 5,
                        left: 5.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Material(
                            color: Theme.of(context).primaryColor,
                            child: InkWell(
                              splashColor: Colors.white.withOpacity(0.5),
                              onTap: () {

                              },
                              child: Container(
                                decoration:  BoxDecoration(
                                  border: Border.all(color: Colors.white,width: 2),
                                  shape: BoxShape.circle,
                                  color: avaliable?AppColors.brown:Colors.red,
                                ),
                                width: 10.0,
                                height: 10.0,

                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(flex:2,
                  child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        consult.name,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.cairo(
                          color: theme=="light"?Colors.white:Colors.black,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: theme=="light"?AppColors.white:AppColors.black,
                          ),
                          Expanded(flex: 2,
                            child: Text(
                              consult.location,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              maxLines: 1,
                              style: GoogleFonts.cairo(
                                color: theme=="light"?Colors.white:Colors.black,
                                fontSize: 11.0,
                                // fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),

                      //SizedBox(height: 2,),
                      Row( mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: AppColors.yellow,
                              ),
                              Text(
                                consult.rating==null?"0": consult.rating.toStringAsFixed(1),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: theme=="light"?Colors.white:Colors.black,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20,),
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(theme=="light"?
                              'assets/applicationIcons/greenCall.png':'assets/applicationIcons/blackCall.png',
                                width: 12,
                                height: 12,
                              ),


                              Text(
                                consult.ordersNumbers==null?'0':consult.ordersNumbers<100?consult.ordersNumbers.toString():consult.ordersNumbers<1000?"+100":"+1000",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: GoogleFonts.cairo(
                                  color: theme=="light"?Colors.white:Colors.black,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        consult.price+"\$",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.cairo(
                          color:  AppColors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 20,),
                      Image.asset('assets/applicationIcons/v-w.png',
                        width: 15,
                        height: 15,
                      ),
                    ],),
                ),
              ],
            ),


          ),
          SizedBox(height: 10,)
        ],
      ),
    );
  }

}
