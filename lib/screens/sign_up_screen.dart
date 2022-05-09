// @dart=2.9

import 'package:flutter/services.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/screens/privecy_screen.dart';
import 'package:grocery_store/screens/term_screen.dart';
import 'package:grocery_store/screens/verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  final String userType;

  const SignUpScreen({Key key, this.userType}) : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignupBloc signupBloc;
  String   mobileNo="",countryCode="+966",countryISOCode="SA";
  //MaskedTextController phoneNumberController;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String phoneNumber, email="example@example.com", name="name";
  bool inProgress, inProgressApple;
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'SA',theme;
  PhoneNumber number = PhoneNumber(isoCode: 'SA');

  @override
  void initState() {
    super.initState();
    inProgress = false;
    inProgressApple = false;

    //phoneNumberController = MaskedTextController(mask: '0000000000');
    signupBloc = BlocProvider.of<SignupBloc>(context);

    signupBloc.listen((state) {
      if (state is SignupWithGoogleInitialCompleted) {
        //proceed to save details
        name = state.firebaseUser.displayName;
        email = state.firebaseUser.email;

        signupBloc.add(SaveUserDetails(
         // name: name,
          phoneNumber: '',
          //email: email,
          firebaseUser: state.firebaseUser,
          loggedInVia: 'GOOGLE',
        ));
      }
      if (state is SignupWithGoogleInitialFailed) {
        //failed to sign in with google
        print('failed to sign in with google');
        showFailedSnakbar('Failed to sign in');
        setState(() {
          inProgress = false;
        });
      }
      if (state is CompletedSavingUserDetails) {
        print(state.user.email);
        //proceed to home
        //close signupBloc

        //signupBloc.close();

       //if(mounted)
         //Navigator.popAndPushNamed(context, '/home');
      }
      if (state is FailedSavingUserDetails) {
        //failed saving user details
        print('failed to save');
        if(mounted)
       { //showFailedSnakbar('Failed to save user details!');
       setState(() {
         inProgress = false;
       });}
      }
      if (state is SavingUserDetails) {
        //saving user details
        print('Saving user details');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // signupBloc.close();
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
  signUpWithphoneNumber() async {
    print("gggggg");
    print(mobileNo);
    if(mobileNo==null||mobileNo=="")//||nameController.text==null||nameController.text=="")
        {
      showFailedSnakbar(getTranslated(context, "enterAll"));
    }
    else
    {
      /*if(mobileNo[0]=="0")
        mobileNo=mobileNo.substring(1,mobileNo.length);
      phoneNumber = countryCode + mobileNo;*/
      phoneNumber =  mobileNo;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            email: email,
            phoneNumber: phoneNumber,
            name: nameController.text,
            userType:widget.userType,
            countryCode:countryCode,
            countryISOCode:countryISOCode,
            isSigningIn: false,
          ),
        ),
      );
    }
  }
  signUpWithphoneNumber2() async {
    if(mobileNo==null||mobileNo=="")//||nameController.text==null||nameController.text=="")
      {
        showFailedSnakbar(getTranslated(context, "enterAll"));
      }
    else
      {
        //mobileNo=replaceFarsiNumber(mobileNo);

        phoneNumber = countryCode + mobileNo;
        print("gggggg");
        print(phoneNumber);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              email: email,
              phoneNumber: phoneNumber,
              name: nameController.text,
              userType:widget.userType,
              countryCode:countryCode,
              countryISOCode:countryISOCode,
              isSigningIn: false,
            ),
          ),
        );
      }
  }

  signUpWithGoogle() {
    signupBloc.add(SignupWithGoogle());
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
          final firebaseUser = authResult.user;
          final displayName =
              '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
          await firebaseUser.updateProfile(displayName: displayName);

          User user = FirebaseAuth.instance.currentUser;

          name = firebaseUser.displayName;
          email = firebaseUser.email;

          signupBloc.add(SaveUserDetails(
            //name: '',
            phoneNumber: '',
           // email: email,
            firebaseUser: firebaseUser,
            loggedInVia: 'APPLE',
          ));

          // DocumentSnapshot snapshot = await FirebaseFirestore.instance
          //     .collection(Paths.usersPath)
          //     .doc(user.uid)
          //     .get();

          // if (snapshot.exists) {
          //   if (snapshot.data()['isBlocked']) {
          //     await FirebaseAuth.instance.signOut();
          //     setState(() {
          //       inProgressApple = false;
          //     });
          //     return showFailedSnakbar('Your account has been blocked');
          //   }
          // } else {
          //   await FirebaseAuth.instance.signOut();
          //   setState(() {
          //     inProgressApple = false;
          //   });
          //   return showFailedSnakbar('Account already exists');
          // }

          // return firebaseUser;
          print('SIGNED IN');
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
      backgroundColor: Theme.of(context).primaryColor,
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
            // color: Colors.white,
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
              SizedBox(height: 70,),
              Center(
                child:  Image.asset('assets/applicationIcons/whiteLogo.png',width: 100,height: 100,)
              ),
              SizedBox(height: 10,),
              Text(
                'لتعليم  القرآن الكريم',
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
          Column(mainAxisAlignment:MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: size.height*.4,
                width: size.width,
                padding:
                const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
               /* decoration: BoxDecoration(
                  color: Colors.white,
                ),*/
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
                        style: GoogleFonts.cairo(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20,),
                      Container(height: 50,
                        child: InternationalPhoneNumberInput(

                          searchBoxDecoration:InputDecoration(
                            counterStyle: TextStyle(height: double.minPositive,),
                            counterText: "",
                            labelText: getTranslated(context, "countrySearch"),
                            labelStyle: GoogleFonts.cairo(
                              fontSize: 13,
                              color:Colors.black,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            fillColor: Colors.grey[350],filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                                topLeft: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                              ),
                              borderSide: BorderSide(
                                color: Colors.grey[350],
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                                topLeft: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                              ),
                              borderSide: BorderSide(
                                color: Colors.grey[350],
                              ),
                            ),
                            contentPadding: EdgeInsets.only(left: 5,right: 5),
                            helperStyle: GoogleFonts.cairo(
                              color: Colors.black.withOpacity(0.65),
                              letterSpacing: 0.5,
                            ),
                            hintStyle: GoogleFonts.cairo(
                              color: Colors.black,//[400],
                              fontSize: 14.5,
                              letterSpacing: 0.5,
                            ),
                            hintText: getTranslated(context,'enterMobile'),

                          ),
                          inputDecoration: InputDecoration(
                            counterStyle: TextStyle(height: double.minPositive,),
                            counterText: "",
                            labelText: getTranslated(context, "mobileNo"),
                            labelStyle: GoogleFonts.cairo(
                              fontSize: 13,
                              color:  theme=="light"?Colors.black:Colors.black,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            fillColor: Colors.grey[350],filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                                topLeft: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                              ),
                              borderSide: BorderSide(
                                color: Colors.grey[350],
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                                topLeft: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                              ),
                              borderSide: BorderSide(
                                color: Colors.grey[350],
                              ),
                            ),
                            contentPadding: EdgeInsets.only(left: 5,right: 5),
                            helperStyle: GoogleFonts.cairo(
                              color: Colors.black.withOpacity(0.65),
                              letterSpacing: 0.5,
                            ),
                            hintStyle: GoogleFonts.cairo(
                              color: Colors.grey[400],
                              fontSize: 14.5,
                              letterSpacing: 0.5,
                            ),
                            hintText: getTranslated(context,'enterMobile'),

                          ),
                          onInputChanged: (PhoneNumber number) {
                            print("numberphoneNumber");
                            print(number.phoneNumber);
                            print(number.isoCode);
                            print(number.dialCode);
                            setState(() {
                              mobileNo=number.phoneNumber;
                              countryCode=number.dialCode;
                              countryISOCode=number.isoCode;
                            });
                          },
                          onInputValidated: (bool value) {
                            print(value);
                          },
                          locale:getTranslated(context,'lang') ,
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: TextStyle(color: theme=="light"?Colors.black:Colors.white),
                          initialValue: number,
                          textFieldController: controller,
                          formatInput: false,
                          keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                          inputBorder: OutlineInputBorder(),
                          onSaved: (PhoneNumber number) {
                            print('On Saved: $number');
                          },
                        ),
                      ),
                      SizedBox(height: 20,),

                      Center(
                        child: Container(
                          width: size.width,
                          height: 40.0,
                          child: FlatButton(
                            onPressed: () {
                              //validate inputs
                              signUpWithphoneNumber();
                            },
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            child: Text(
                              getTranslated(context, "sendCode"),
                              style: GoogleFonts.cairo(
                                color: theme=="light"?Colors.white:Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),

                    ],),
                ),
              ),
              Container(
                height: size.height*.2,
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
                        getTranslated(context, "registerNote1"),
                        style: GoogleFonts.cairo(
                          color:  theme=="light"?Colors.white:Colors.black,
                          fontSize: 15.0,
                          // fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 1,),
                      InkWell(splashColor: Colors.blue.withOpacity(0.5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivecyScreen(),//TermScreen(),
                            ),);
                        },
                        child: Text(
                          getTranslated(context, "registerNote2"),
                            style: TextStyle( decoration: TextDecoration.underline,
                              decorationColor:  theme=="light"?Colors.white:Colors.black,
                              decorationThickness: 1,
                              color:  theme=="light"?Colors.white:Colors.black,
                              fontSize: 12.0,
                            )
                        ),
                      ),
                      SizedBox(height: 1,),
                      InkWell(splashColor: Colors.blue.withOpacity(0.5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivecyScreen(),
                            ),);
                        },
                        child: Text(
                            getTranslated(context, "registerNote3"),
                            style: TextStyle( decoration: TextDecoration.underline,
                              decorationColor:  theme=="light"?Colors.white:Colors.black,
                              decorationThickness: 1,
                              color:  theme=="light"?Colors.white:Colors.black,
                              fontSize: 12.0,
                            )
                        ),
                      ),
                    ],),
                ),
              ),
            ],
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
        height: size.height*.2,
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
                getTranslated(context, "registerNote1"),
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15.0,
                  // fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 5,),
              Text(
                getTranslated(context, "registerNote2"),
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 13.0,
                  // fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

              SizedBox(height: 5,),
              Text(
                getTranslated(context, "registerNote3"),
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 12.0,
                  // fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],),
        ),
      ),);
  }


  Widget buildGoogleSignupButton(Size size) {
    return Center(
      child: inProgress
          ? CircularProgressIndicator()
          : Container(
              width: size.width,
              height: 48.0,
              child: FlatButton(
                onPressed: () {
                  signUpWithGoogle();
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
                      'Sign up with Google',
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
                          'Sign up with Apple',
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
  String replaceFarsiNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(farsi[i], english[i]);
    }
print("ressssss");
    print(input);
    return input;
  }

}
