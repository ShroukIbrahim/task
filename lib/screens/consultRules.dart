// @dart=2.9
import 'package:grocery_store/localization/localization_methods.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/UnorderedList.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/completeConsultProfileScreen.dart';

import 'package:webview_flutter/webview_flutter.dart';

import '../config/colorsFile.dart';

class consultRuleScreen extends StatefulWidget {
  final GroceryUser user;

  const consultRuleScreen({Key key, this.user}) : super(key: key);

  @override
  _consultRuleScreenState createState() => _consultRuleScreenState();
}

class _consultRuleScreenState extends State<consultRuleScreen>with SingleTickerProviderStateMixin {
  bool isLoading=true,accept=false;
  @override
  void initState() {
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
                        getTranslated(context, "terms"),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(children: [
                UnorderedList([
                  getTranslated(context, "rule1"),
                  getTranslated(context, "rule2"),
                  getTranslated(context, "rule3"),
                  getTranslated(context, "rule4"),
                  getTranslated(context, "rule5"),
                  getTranslated(context, "rule6")
                ]),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Checkbox(
                      value: accept,
                      onChanged: (value) {
                        setState(() {
                          accept = !accept;
                        });
                      },
                    ),
                    Text(
                      getTranslated(context, "agree"),
                      style: GoogleFonts.cairo(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                accept==true?Container(
                  width: size.width*.6,
                  height: 45.0,
                  child: FlatButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompleteConsultProfileScreen(user: widget.user),),);
                    },
                    color: AppColors.brown ,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      getTranslated(context, "saveAndContinue"),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ):SizedBox(),
              ],),
            ),
          ),
        ],
      ),
    );
  }
}
