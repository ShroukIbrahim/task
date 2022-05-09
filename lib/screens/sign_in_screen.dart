// @dart=2.9
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/sign_up_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'verification_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  //MaskedTextController phoneNumberController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String phoneNumber;
  bool inProgress, inProgressApple;
  SigninBloc signinBloc;
  String   mobileNo="",countryCode="+966",countryISOCode="SA";
  @override
  void initState() {
    super.initState();
    inProgress = false;
    inProgressApple = false;

   // phoneNumberController = MaskedTextController(mask: '0000000000');
    signinBloc = BlocProvider.of<SigninBloc>(context);

//TODO:Detect if signed up or not while signing in

    signinBloc.listen((state) {
      if (state is SignInWithGoogleInProgress) {
        print('sign in with google in progress');

        setState(() {
          inProgress = true;
        });
      }
      if (state is SigninWithGoogleFailed) {
        //failed
        print('sign in with google failed');
        setState(() {
          inProgress = false;
        });
        showFailedSnakbar('Sign in with Google failed!');
      }
      if (state is SigninWithGoogleCompleted) {
        print('sign in with google completed');
        //proceed

        setState(() {
          inProgress = false;
        });

        if (state.result.isEmpty) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        } else {
          showFailedSnakbar(state.result);
        }
      }
      if (state is CheckIfBlockedInProgress) {
        print('in progress');
      }
      if (state is CheckIfBlockedFailed) {
        //failed
        print('failed to check');
        setState(() {
          inProgress = false;
        });
        showFailedSnakbar('Failed to sign in!');
      }
      if (state is CheckIfBlockedCompleted) {
        setState(() {
          inProgress = false;
        });
        if (state.result.isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                phoneNumber: phoneNumber,
                isSigningIn: true,
              ),
            ),
          );
        } else {
          showFailedSnakbar(state.result);
        }
      }
    });
  }
  signInWithApple(){}
 /* signInWithApple() async {
    setState(() {
      inProgressApple = true;
    });

    try {
      final result = await AppleSignIn.performRequests([
        AppleIdRequest(
          requestedScopes: [
            Scope.fullName,
            Scope.email,
          ],
        )
      ]);

      // 2. check the result
      switch (result.status) {
        case AuthorizationStatus.authorized:
          final appleIdCredential = result.credential;
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken),
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode),
          );
          final authResult =
              await FirebaseAuth.instance.signInWithCredential(credential);
          // final firebaseUser = authResult.user;
          // final displayName =
          //     '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
          // await firebaseUser.updateProfile(displayName: displayName);

          User user = FirebaseAuth.instance.currentUser;

          DocumentSnapshot snapshot = await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(user.uid)
              .get();

          if (snapshot.exists) {
            Map<String, dynamic> data = snapshot.data();
            if (data['isBlocked']) {
              await FirebaseAuth.instance.signOut();
              setState(() {
                inProgressApple = false;
              });
              return showFailedSnakbar('Your account has been blocked');
            }
          } else {
            await FirebaseAuth.instance.signOut();
            setState(() {
              inProgressApple = false;
            });
            return showFailedSnakbar('Account does not exist');
          }

          // return firebaseUser;
          print('SIGNED IN');
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
          break;

        case AuthorizationStatus.error:
          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString(),
          );

        case AuthorizationStatus.cancelled:
          throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign in aborted by user',
          );
        default:
          throw UnimplementedError();
      }

      // final AuthCredential credential1 = OAuthProvider('apple.com').credential(
      //   accessToken: credential.authorizationCode,
      //   idToken: credential.identityToken,
      // );

      // await FirebaseAuth.instance.signInWithCredential(credential1);

      // User user = FirebaseAuth.instance.currentUser;

      // DocumentSnapshot snapshot = await FirebaseFirestore.instance
      //     .collection(Paths.usersPath)
      //     .doc(user.uid)
      //     .get();

      // if (snapshot.exists) {
      //   if (snapshot.data()['isBlocked']) {
      //     await FirebaseAuth.instance.signOut();
      //     return showFailedSnakbar('Your account has been blocked');
      //   }
      // } else {
      //   await FirebaseAuth.instance.signOut();
      //   return showFailedSnakbar('Account does not exist');
      // }

      //TODO: continue

    } catch (e) {
      print(e);
      setState(() {
        inProgressApple = false;
      });
      showFailedSnakbar('Sign in with Apple failed!');
    }
  }*/

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
    String lang=getTranslated(context,"lang");
    return Scaffold(
      key: _scaffoldKey,
      body:  ListView(
        children: <Widget>[
          Container(
            height: size.height*.4,
            width: size.width,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [

              SizedBox(height: 70,),
              Stack(alignment: Alignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/background.png',height: 150,width: 200,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0.0,
                      right: 0,
                      child:   Center(
                        child: Container(height: 100,width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35.0),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 0.0),
                                  blurRadius: 5.0,
                                  spreadRadius: 1.0,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                            child: Image.asset('assets/applicationIcons/whiteLogo.png',height: 100,width: 100)
                        ),
                      ),),
                  ]),
              SizedBox(height: 10,),
              Text(
                'DREAM0000',
                style: GoogleFonts.abrilFatface(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 5,
                ),
              ),
            ],)),
          ),
          Container(
            height: size.height*.6,
            width: size.width,
            padding:
            const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children:  [
                   Text(
                      getTranslated(context, "loginText"),
                      maxLines: 3,
                      textAlign:TextAlign.center,
                      overflow:TextOverflow.ellipsis,
                      style: GoogleFonts.laila(
                        color: Theme.of(context).primaryColor,
                        fontSize: 15.0,
                        //fontWeight: FontWeight.w600,
                      ),
                    ),
                  SizedBox(height: 20,),
                  Container(height: 40,
                    child: IntlPhoneField(textAlign: TextAlign.start,
                      //initialValue:widget.user.mobileNo,
                      initialCountryCode: "SA",
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      style: GoogleFonts.cairo(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                      validator: (String val) {
                        if (val.trim().isEmpty) {
                          return getTranslated(context, 'mobileReq');
                        }
                        return null;
                      },
                      //autoValidate: false,
                      dropdownDecoration:  BoxDecoration(color: Colors.grey[200],
                        borderRadius:lang=="ar"?BorderRadius.only(
                          topRight: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ):BorderRadius.only(
                          topLeft: Radius.circular(40),
                          bottomLeft: Radius.circular(40),
                        ),
                      ),
                     // countryCodeTextColor: Colors.black,
                      //dropDownArrowColor: Colors.black,
                      decoration: InputDecoration(
                      counterStyle: TextStyle(height: double.minPositive,),
                       counterText: "",
                        labelText: getTranslated(context, "mobileNo"),
                        labelStyle: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        fillColor: Colors.grey[200],filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: lang!="ar"?BorderRadius.only(
                            topRight: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ):BorderRadius.only(
                            topLeft: Radius.circular(40),
                            bottomLeft: Radius.circular(40),
                          ),
                          borderSide: BorderSide(
                            color: Colors.grey[200],
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: lang!="ar"?BorderRadius.only(
                            topRight: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ):BorderRadius.only(
                            topLeft: Radius.circular(40),
                            bottomLeft: Radius.circular(40),
                          ),
                          borderSide: BorderSide(
                            color: Colors.grey[200],
                          ),
                        ),
                        contentPadding: EdgeInsets.only(left: 5,right: 5),
                        helperStyle: GoogleFonts.cairo(
                          color: Colors.black.withOpacity(0.65),
                          letterSpacing: 0.5,
                        ),
                        hintStyle: GoogleFonts.cairo(
                          color: Colors.grey[400],
                          fontSize: 13.0,
                          letterSpacing: 0.5,
                        ),
                        hintText: getTranslated(context,'enterMobile'),

                      ),
                      onChanged: (phone) {
                        print(phone.completeNumber+"  "+phone.countryISOCode);
                        setState(() {
                          mobileNo=phone.number;
                          countryCode=phone.countryCode;
                          countryISOCode=phone.countryISOCode;
                        });
                      },
                      onCountryChanged: (phone) {
                       /* print('Country code changed to: ' + phone.countryCode+"  "+phone.countryISOCode);
                        setState(() {
                          countryCode=phone.countryCode;
                          countryISOCode=phone.countryISOCode;
                        });*/
                      },
                    ),
                  ),
                  SizedBox(height: 20,),
                  buildSignInButton(size,context),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        getTranslated(context, "notHaveAccount"),
                        style: GoogleFonts.cairo(
                          color: Colors.black54,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          _show(context,size);
                          //Navigator.pushNamed(context, '/Register_Type');
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          getTranslated(context,"register"),
                          style: GoogleFonts.cairo(
                            color: Colors.black54,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    ],
                  ),
                ],),
            ),
          ),
        ],
      ),
    );
  }
  void _show(BuildContext ctx,size) {
    showModalBottomSheet(
        elevation: 10,
        backgroundColor: Colors.transparent,
        context: ctx,
        builder: (ctx) =>  Container(
          height: size.height*.4,
          width: size.width,
          padding:
          const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
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
                    color: Colors.white,
                    fontSize: 15.0,
                    // fontWeight: FontWeight.w600,
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
                    color: Colors.white ,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      getTranslated(context, "registerAsClient"),
                      style: GoogleFonts.cairo(
                        color: Theme.of(context).primaryColor,
                        fontSize: 15.0,
                        // fontWeight: FontWeight.w600,
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
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(userType: "CONSULTANT"),
                        ),
                      );

                    },
                    color: Colors.white ,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      getTranslated(context, "registerAsConsultant"),
                      style: GoogleFonts.cairo(
                        color: Theme.of(context).primaryColor,
                        fontSize: 15.0,
                        //fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],),
          ),
        ),);
  }
  Widget build2(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 200.0,
              width: size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColorDark,
                    Theme.of(context).primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                ),
              ),
              child: SvgPicture.asset(
                'assets/banners/signin_top.svg',
                fit: BoxFit.fitWidth,
              ),
            ),
            Container(
              height: size.height - 200.0,
              width: size.width,
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Welcome',
                    style: GoogleFonts.cairo(
                      color: Colors.black.withOpacity(0.85),
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Sign in and get all the groceries at your doorstep',
                    style: GoogleFonts.cairo(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      // controller: phoneNumberController,
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String val) {
                        if (val.isEmpty) {
                          return 'Mobile No. is required';
                        }
                        // else if (val.length != 10) {
                        //   return 'Mobile No. is invalid';
                        // }
                        return null;
                      },
                      onSaved: (val) {
                        phoneNumber = val;
                      },
                     enableInteractiveSelection: true,
                      style: GoogleFonts.cairo(
                        color: Colors.black,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        helperStyle: GoogleFonts.cairo(
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        prefixText: '${Config().countryphoneNumberPrefix} ',
                        prefixStyle: GoogleFonts.cairo(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.5,
                        ),
                        errorStyle: GoogleFonts.cairo(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        hintStyle: GoogleFonts.cairo(
                          color: Colors.black54,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        prefixIcon: Icon(
                          Icons.phone,
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 50.0,
                        ),
                        labelText: 'Mobile no.',
                        labelStyle: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  buildSignInButton(size, context),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                    child: Center(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Divider(
                              color: Colors.black54,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text(
                              'OR',
                              style: GoogleFonts.cairo(
                                color: Colors.black54,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  buildGoogleSignInButton(size),
                  Platform.isIOS ? buildAppleSignInButton(size) : SizedBox(),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        'Don\'t have an account?',
                        style: GoogleFonts.cairo(
                          color: Colors.black54,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/sign_up');
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.cairo(
                            color: Colors.black54,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSignInButton(Size size, BuildContext context) {
    return Center(
      child: Container(
        width: size.width,
        height: 40.0,
        child: FlatButton(
          onPressed: () {
            signInWithMobile();
          },
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: Text(
            getTranslated(context, "sendCode"),
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGoogleSignInButton(Size size) {
    return Center(
      child: inProgress
          ? CircularProgressIndicator()
          : Container(
              width: size.width,
              height: 48.0,
              child: FlatButton(
                onPressed: () {
                  signinBloc.add(SignInWithGoogle());
                  setState(() {
                    inProgress = true;
                  });
                },
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Text(
                      'Sign in with Google',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildAppleSignInButton(Size size) {
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Center(
          child: inProgressApple
              ? CircularProgressIndicator()
              : Container(
                  width: size.width,
                  height: 48.0,
                  child: FlatButton(
                    onPressed: () async {
                      // signinBloc.add(SignInWithGoogle());

                      signInWithApple();
                    },
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.apple,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Text(
                          'Sign in with Apple',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void signInWithMobile() {
    if(mobileNo!="")
      {
        phoneNumber = countryCode+mobileNo;
      signinBloc.add(CheckIfBlocked(phoneNumber));
      inProgress = true;
      }
    else
      {
        showFailedSnakbar(getTranslated(context, "mobileReq"));
      }
  }
}
