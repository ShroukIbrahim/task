// @dart=2.9
import 'package:another_flushbar/flushbar.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/SupportList.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/supportMessagesScreen.dart';
import 'package:intl/intl.dart';

class SupportListItem extends StatelessWidget {
  final Size size;
  final SupportList item;
  final GroceryUser user;
  final String theme;
  const SupportListItem({
    @required this.size,
    @required this.item, this.user, this.theme,
    //@required this.index,
    //@required this.notificationList,
  });
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
  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('MM/dd/yy');
    //String date=DateTime.parse(item.messageTime.toDate().toString());
    //DateTime.parse(item.messageTime.toDate().toString()).toString();
    return GestureDetector(
      onTap: () {
        ( item.openingStatus&&user.userType=="SUPPORT")?
        showSnack(getTranslated(context, "otherSupport"),context):Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SupportMessageScreen(
              item: item,
              user:user,
              theme:theme,
            ),
          ),
        );


      },
      child: Column(
        children: [
          Container(
            width: size.width,
            padding: const EdgeInsets.only(
                left: 5.0, right: 5.0, bottom: 10.0, top: 10.0),
            decoration: BoxDecoration(
              color:   ( item.openingStatus&&user.userType=="SUPPORT")?Colors.grey:Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Icon( Icons.headset_mic_rounded,size: 40.0,color: theme=="light"?Colors.white:Colors.black, ),
                Padding(
                  padding: const EdgeInsets.only(left: 5,right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(width:size.width*.5,
                            child: Text(
                              user.userType=="SUPPORT"?item.userName==null?"Client":item.userName:'${getTranslated(context, "supportTeam")}',
                              style: GoogleFonts.cairo(
                                fontSize: 14.5,
                                color:  theme=="light"?Colors.white:Colors.black,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Text(
                             // date,
                              item.messageTime!=null? '${dateFormat.format(item.messageTime.toDate())}':'..',
                            style: GoogleFonts.cairo(
                              fontSize: 13.0,
                              color: theme=="light"?Colors.white:Colors.black,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(width: size.width*.6,
                            child: item.lastMessage==null?SizedBox():(item.lastMessage!="imageFile"&&item.lastMessage!="voiceFile")?Text(
                                item.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 13.0,
                                color: theme=="light"?Colors.white:Colors.black,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                              ),
                            ):Row(children: [
                              Icon( Icons.file_copy_outlined,size:15,color: theme=="light"?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5),),
                              Text(
                              getTranslated(context, "attatchment"),
                              style: GoogleFonts.cairo(
                                fontSize: 13.0,
                                color: theme=="light"?Colors.white:Colors.black,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                              ),),
                            ],),
                          ),
                         SizedBox(width: 2,),
                          (user.userType=="SUPPORT"&&item.supportMessageNum>0)?Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                    //border: Border.all(width: 1, color: Colors.red)
                                ),
                            child:   Center(
                              child: Text(
                                  user.userType=="SUPPORT"?'${item.supportMessageNum.toString()}':'${item.userMessageNum.toString()}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.0,
                                    color: theme=="light"?Colors.white:Colors.black,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                            ),
                          ):
                          (user.userType!="SUPPORT"&&item.userMessageNum>0)?Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              //border: Border.all(width: 1, color: Colors.red)
                            ),
                            child:   Center(
                              child: Text(
                                user.userType=="SUPPORT"?'${item.supportMessageNum.toString()}':'${item.userMessageNum.toString()}',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.0,
                                  color: theme=="light"?Colors.white:Colors.black,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ):
                          SizedBox(),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
        ],
      ),
    );
  }
}
