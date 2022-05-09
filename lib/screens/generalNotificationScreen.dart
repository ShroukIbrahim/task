// @dart=2.9
import 'package:grocery_store/localization/localization_methods.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:webview_flutter/webview_flutter.dart';

class GeneralNotificationScreen extends StatefulWidget {
final String title;
final String body;
final String image;
final String link;

  const GeneralNotificationScreen({Key key, this.title, this.body, this.image, this.link}) : super(key: key);
  @override
  _GeneralNotificationScreenState createState() => _GeneralNotificationScreenState();
}

class _GeneralNotificationScreenState extends State<GeneralNotificationScreen>with SingleTickerProviderStateMixin {
  bool isLoading=true;
  final _key = UniqueKey();

  @override
  void initState() {
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            height:100,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Text(
                        getTranslated(context, "notification"),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 3,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Column(children: [
            SizedBox(height: 20,),
            ( widget.image!=null&&widget.image!="noImage"&&widget.image.isEmpty==false)? Center(
              child: Container(
                height: size.height*.25,
                width: size.width*.9,
                decoration: BoxDecoration(
                 // border: Border.all(color: Colors.grey[200],width: 1),
                  shape: BoxShape.rectangle,
                 // color: Colors.white,
                ),
                child: widget.image.isEmpty ?
                Center(child: Icon( Icons.image,color:Colors.grey,size: 50.0, ))
                    :ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: FadeInImage.assetNetwork(
                      placeholder:
                      'assets/images/load.gif',
                      placeholderScale: 0.5,
                      imageErrorBuilder:(context, error, stackTrace) => Icon(
                        Icons.image,color:Colors.grey,size: 50.0,
                      ),
                      image: widget.image,
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
            ):SizedBox(),
            (widget.image!=null&&widget.image!="noImage"&&widget.image.isEmpty==false)?SizedBox(height: 20,):SizedBox(),
            Center(
              child: Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 3,
                style: GoogleFonts.cairo(
                  color: Theme.of(context).primaryColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(height: 10,),
            LinkWell(
              widget.body,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 5,
              style: GoogleFonts.cairo(
                color: Theme.of(context).primaryColor,
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.3,
              ),
              linkStyle: GoogleFonts.cairo(
                color: Colors.blue,
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.3,
              ),),
            /* Text(
                widget.body,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 5,
                style: GoogleFonts.cairo(
                  color: Theme.of(context).primaryColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.3,
                ),
              ),*/
            SizedBox(height: 10,),
          /*  (widget.link!=null&&widget.link!="noLink"&&widget.link!="")?  InkWell(splashColor: Colors.blue.withOpacity(0.5),
              onTap: () async {
                if (await canLaunch(widget.link)) {
                await launch(widget.link);
                } else {
                throw 'Could not launch link';
                }
              },
              child: Text(
                  "link",
                  style: TextStyle( decoration: TextDecoration.underline,
                    decorationColor:Colors.blue,
                    decorationThickness: 1,
                    color: Colors.blue,
                    fontSize: 12.0,
                  )
              ),
            ):SizedBox(),*/
          ],)
        ],
      ),
    );
  }
}
