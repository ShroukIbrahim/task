// @dart=2.9
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/generalNotifications.dart';
import 'package:intl/intl.dart';
import 'package:linkwell/linkwell.dart';

class GeneralNotificationItem extends StatelessWidget {
  final GeneralNotifications item;

  const GeneralNotificationItem({
    @required this.item,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Column(
      children: [
        Container(
          width: size.width,
          padding: const EdgeInsets.only(
              left: 10.0, right: 10.0, bottom: 10.0, top: 10.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
               item.title,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              LinkWell(
                item.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                linkStyle: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),),
             /* Text(
                item.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),*/
              SizedBox(
                height: 5.0,
              ),
              Text(
                getTranslated(context, "sendTo")+": "+item.notificationType,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                getTranslated(context, "selectLanguage")+": "+item.notificationLang,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                getTranslated(context, "selectCountry")+": "+item.notificationCountry,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                '${dateFormat.format(item.notificationTimestamp.toDate())}',
                style: GoogleFonts.poppins(
                  fontSize: 13.0,
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15,)
      ],
    );
  }
}
