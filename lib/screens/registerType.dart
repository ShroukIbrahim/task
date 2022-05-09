// @dart=2.9
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/sign_up_screen.dart';
import '../main.dart';

class RegisterTypeScreen extends StatefulWidget {
  @override
  _RegisterTypeScreenState createState() => _RegisterTypeScreenState();
}

class _RegisterTypeScreenState extends State<RegisterTypeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
   String theme;
  @override
  void initState() {
    super.initState();
  }
  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
      });
    });
    super.didChangeDependencies();
  }
  void showFailedSnakbar(String s) {
    SnackBar snackbar = SnackBar(
      content: Text(
        s,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.red,
      action: SnackBarAction(
          label: 'OK', textColor: Colors.white, onPressed: () {}),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body:  Column(
        children: <Widget>[
          Container(
            height: size.height*.6,
            width: size.width,
           // color: Colors.white,
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
              SizedBox(height: 70,),
              Center(
                child:  Image.asset('assets/applicationIcons/whiteLogo.png',width: 100,height: 100,)
              ),
              SizedBox(height: 10,),
             Text(
                'لتعليم القرآن الكريم',
                style: GoogleFonts.almarai(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0,
                ),
              ),
            ],)),
          ),
          Container(
            height: size.height*.4,
            width: size.width,
            padding:const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(40.0),
                  topRight: const Radius.circular(40.0),
                )
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children:  [
                  Text(
                   getTranslated(context, "howToRegister"),
                    style: GoogleFonts.cairo(
                      color: theme=="light"?Colors.white:Colors.black,
                      fontSize: 15.0,
                     fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 40,),
                  Container(
                    width: size.width*.8,
                    height: 45.0,
                    child: FlatButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(//CONSULTANT
                            builder: (context) => SignUpScreen(userType: "USER"),
                          ),
                        );

                      },
                      color: theme=="light"?Colors.white:Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Text(
                        getTranslated(context, "registerAsClient"),
                        style: GoogleFonts.cairo(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40,),
                  Container(
                    width: size.width*.8,
                    height: 45.0,
                    child: FlatButton(
                      onPressed: () async {

                        Navigator.push(
                          context,
                          MaterialPageRoute(//CONSULTANT
                            builder: (context) => SignUpScreen(userType: "CONSULTANT"),
                          ),
                        );
                      },
                      color: theme=="light"?Colors.white:Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Text(
                        getTranslated(context, "registerAsConsultant"),
                        style: GoogleFonts.cairo(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],),
            ),
          ),
        ],
      ),
    );
  }

}
