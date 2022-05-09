// @dart=2.9
import 'package:another_flushbar/flushbar.dart';
import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/SupportMessage.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/playAudio.dart';
import 'package:intl/intl.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointChatMessageItem extends StatelessWidget {

  final SupportMessage message;
  final GroceryUser user;
  const AppointChatMessageItem({
    this.message,
    this.user,
  });

  @override
  Widget build(BuildContext context) {

    return  Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
          child: Align(
            alignment: (message.owner!= "USER"?Alignment.topLeft:Alignment.topRight),
            child:  message.type=="image"?
            chatImage(context,message.message,message.owner):
            message.type=="voice"?
            RemotePlayer(voiceUrl:message.message ,):
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (message.owner!= "USER"?Colors.grey.shade200:Colors.purple[50]),
              ),
              padding: EdgeInsets.all(16),
              child: Column( mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,children: [
                InkWell(
                  splashColor: Colors.white.withOpacity(0.5),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message.message));
                    showSnack(getTranslated(context, "textCopy"),context);
                  },
                  child: AutoDirection(
                    text: message.message,
                    child: LinkWell(
                      message.message,
                      linkStyle: GoogleFonts.cairo(
                        color: Colors.blue,
                        fontSize: 15.0,
                      ),
                      textAlign:TextAlign.start ,
                      style: GoogleFonts.cairo(
                        color: Colors.black,
                        fontSize: 15.0,
                      ),),
                  ),
                ),
                message.messageTimeUtc!=null?Text(
                  // DateTime.parse(message.messageTimeUtc).toLocal().toString(),
                  '${new DateFormat('dd MMM yyyy, hh:mm a').format( DateTime.parse(message.messageTimeUtc).toLocal())}',
                  textAlign:TextAlign.end ,
                  style: GoogleFonts.cairo(
                    fontSize: 11.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ):SizedBox(),
              ],),
            ),
          ),
        ),
        SizedBox(height: 5,),

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
  launchURL(String url) async {
    if (!url.contains('http')) url = 'https://$url';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // showSnakbar('Could not launch $url', false);

      throw 'Could not launch $url';
    }

  }
  static Widget chatImage(BuildContext context, String chatContent,String type) {
    return Container(
        padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
        child: Align(
          alignment: (type!= "USER"?Alignment.topLeft:Alignment.topRight),
          child: Container(
            child: ElevatedButton(
                child: Material(
                  child: kIsWeb
                      ? widgetShowImages(chatContent, 250)
                      : widgetShowImages(chatContent, 150),//100
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  //clipBehavior: Clip.hardEdge,
                ),
                onPressed: ()  async {
                  // launchURL(chatContent);
                  var url=chatContent;
                  if (!url.contains('http')) {
                    url = 'https://$url';
                  }
                  await launch(url);
                },
                style: ElevatedButton.styleFrom(padding: EdgeInsets.all(0.0))),
            margin: type=="USER"
                ? EdgeInsets.only(
                bottom:  10.0,
                right: 10.0)
                : EdgeInsets.only(left: 10.0),
          ),)
    );
  }

  // Show Images from network
  static Widget widgetShowImages(String imageUrl, double imageSize) {
    return  FadeInImage.assetNetwork(
      placeholder:'assets/images/load.gif',
      placeholderScale: 0.5,
      imageErrorBuilder: (context, error, stackTrace) => Icon(
        Icons.image_not_supported,
        size: 50.0,
      ),
      height: imageSize,
      width: imageSize,
      image: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: Duration(milliseconds: 250),
      fadeInCurve: Curves.easeInOut,
      fadeOutDuration: Duration(milliseconds: 150),
      fadeOutCurve: Curves.easeInOut,
    );

  }
}
