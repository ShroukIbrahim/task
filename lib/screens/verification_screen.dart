
// @dart=2.9
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:uuid/uuid.dart';

import '../config/colorsFile.dart';
import 'account_screen.dart';
import 'completeConsultProfileScreen.dart';
import 'completeUserProfile.dart';
import 'consultRules.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String email;
  final bool isSigningIn;
  final String userType;
  final String countryCode;
  final String countryISOCode;
  const VerificationScreen({
    this.phoneNumber,
    this.email,
    this.name,
    this.isSigningIn,
    this.userType,
    this.countryCode,
    this.countryISOCode,
  });

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int _timer;
  SignupBloc signupBloc;
  MaskedTextController otpController = MaskedTextController(mask: '000000');
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer timer;
  String _code="";
  bool inProgress;
  AccountBloc accountBloc;
  String smsCode,theme;
   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String _verificationCode = '';
  @override
  void initState() {
    super.initState();

    signupBloc = BlocProvider.of<SignupBloc>(context);
    accountBloc = BlocProvider.of<AccountBloc>(context);
    inProgress = false;

    signupBloc.listen((state) {
      if (state is VerifyphoneNumberCompleted) {
        //proceed and save the data
        print('USER IDsssssss: ${state.user.uid} ${state.user.phoneNumber}');
         if(mounted)
        checkUser(widget.phoneNumber,widget.userType,state.user.uid);
        /*signupBloc.add(
          SaveUserDetails(
            name: widget.name,
            phoneNumber: widget.phoneNumber,
            countryCode: widget.countryCode,
            countryISOCode: widget.countryISOCode,
            userType:widget.userType,
            firebaseUser: state.user,
            loggedInVia: 'MOBILE_NO',
          ),
        );*/
      }
      if (state is VerifyphoneNumberInProgress) {
        //show progress bar
        print('verification in progress');
        if(mounted)
        setState(() {
          inProgress = true;
        });
      }
      if (state is VerifyphoneNumberFailed) {
        //failed
        print('verification failed');
        if (mounted){
          showFailedSnakbar('Verification failed!');
        setState(() {
          inProgress = false;
        });
      }
      }
      if (state is VerificationCompleted) {
        //proceed and save the data
        print('sent otp');
       if(mounted)
         setState(() {
           inProgress = false;
         });
      }
      if (state is VerificationInProgress) {
        //show progress bar
        print('verification in progress');
       if(mounted)
         setState(() {
           inProgress = true;
         });
      }
      if (state is VerificationFailed) {
        //failed
        print('verification failed');
       // if(mounted) {
          showFailedSnakbar('Failed to send otp! tray again later');
          setState(() {
            inProgress = false;
          });
       // }
      }
      if (state is CompletedSavingUserDetails) {
        print("yarabsavedone");
        print(state.user.phoneNumber);
        print(state.user.profileCompleted);
        print(state.user.userType);

      if(mounted){
         if(state.user.profileCompleted==true) {
           print("profileCompleted1");
           Navigator.pushNamedAndRemoveUntil(
             context,
             '/home',
                 (route) => false,
           );
         }
         else if(state.user.userType=="CONSULTANT") {
           print("profileCompleted2");
           Navigator.push(
             context,
             MaterialPageRoute(
               builder: (context) => consultRuleScreen(user: state.user),),);
         }
         else
         {
           print("profileCompleted3");
         Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => CompleteUserProfileScreen(user:state.user), ),);}
       }
      }
      if (state is FailedSavingUserDetails) {
        //failed saving user details
        print('failed to save');
        if(mounted)
          {
            //showFailedSnakbar('Failed to save user details!');

            setState(() {
              inProgress = false;
            });
          }
      }
      if (state is SavingUserDetails) {
        //saving user details
        print('Saving user details');
      }
    });
    listOPT();
   /* signupBloc.add(SignupWithphoneNumber(
        name: widget.name,
        phoneNumber: widget.phoneNumber,
        email: widget.email,
      ), );*/
    signInWithphoneNumber(widget.phoneNumber);
    startTimer();
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
  Future<String> checkUser(String phoneNumber,String userType,String uid) async {
    try {
      print("checkUser");
      //check if blocked
      //QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('phoneNumber', isEqualTo: phoneNumber).get().then((value) async {
        if (value!=null&&value.size > 0&&phoneNumber!=null) {
          for (var item in value.docs) {
            Map<String, dynamic> data = item.data();
            if (data['profileCompleted']!=null&&data['profileCompleted']) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                    (route) => false,
              );
            }
            else {
              DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(uid);
              final DocumentSnapshot documentSnapshot = await docRef.get();
              var user= GroceryUser.fromFirestore(documentSnapshot);
              if(user.userType=="CONSULTANT") {
                print("CONSULTANTProfileNotCompleted");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => consultRuleScreen(user:user),),);
              }
              else{
                print("userProfileNotCompleted");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompleteUserProfileScreen(user:user), ),);
              }
            }


          }
        }
        else {//user nit found-create user and save it
          print("logginStep3");
          DocumentReference ref = await FirebaseFirestore.instance.collection(Paths.usersPath).doc(uid);
          var data = {
            'accountStatus': 'NotActive',
            'userLang':'ar',
            'profileCompleted':false,
            'isBlocked': false,
            'uid': uid,
            'name': " ",
            'email': " ",
            'phoneNumber': phoneNumber,
            'photoUrl': '',
            'tokenId': "",
            'loggedInVia': "mobile",
            "userType":userType,
            "languages":[],
            "countryCode":widget.countryCode,
            "countryISOCode":widget.countryISOCode,
            "createdDate": Timestamp.now(),
            "createdDateValue":DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day ).millisecondsSinceEpoch,
          };
          ref.set(data, SetOptions(merge: true));
          final DocumentSnapshot currentDoc = await ref.get();
          var user = GroceryUser.fromFirestore(currentDoc);
          if(user.userType=="CONSULTANT") {
            print("CONSULTANTProfileNotCompleted");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => consultRuleScreen(user:user),),);
          }
          else
          {
            print("userProfileNotCompleted");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompleteUserProfileScreen(user:user), ),);
          }

        }
      }).catchError((err) {
      });

    } catch (e) {
      print(e);
      return null;
    }
  }
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
  listOPT()async {
    try{
    await SmsAutoFill().listenForCode;
    }catch(e){
      print("ffffffss"+e.toString());

    }
  }
  void startTimer() {
    _timer = 60;

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timer--;
      });
      if (_timer == 0) {
        timer.cancel();
      }
    });
  }

  void showFailedSnakbar(String s) {
    SnackBar snackbar = SnackBar(
      content: Text(
        s,
        style: GoogleFonts.cairo(
          color: theme=="light"?Colors.white:Colors.black,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      duration: Duration(seconds: 7),
      backgroundColor: Theme.of(context).primaryColor,
      action: SnackBarAction(
          label: getTranslated(context, "Ok"), textColor: Colors.white, onPressed: () {}),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
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
                                    color: theme=="light"?Colors.white:Colors.black,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            getTranslated(context,"Verification"),
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              height: size.height * 0.35,
              child:Image.asset( 'assets/applicationIcons/otplight.png'
                /* width: 50,
                          height: 50,*/
              )
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              getTranslated(context, 'enterCode'),
              style: GoogleFonts.cairo(
                color: theme=="light"?Colors.black.withOpacity(0.85):Colors.white,
                fontSize: 17.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(
              height: 12.0,
            ),
            Text(
             _timer>50?getTranslated(context,"otpSending"): getTranslated(context,"otpSend"),
              style: GoogleFonts.cairo(
                color: AppColors.grey,
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(
              height: 25.0,
            ),
            _timer>50?loadVerificationCode():Container(
              height: 52.0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              child: TextFormField(
                controller: otpController,
                textAlignVertical: TextAlignVertical.center,
                validator: (String val) {
                  if (val.isEmpty) {
                    return getTranslated(context, "optRequired");
                  } else if (val.length < 6) {
                    return getTranslated(context, "invalidOtp");
                  }
                  return null;
                },
                onChanged: (val) {
                  print(val);
                  smsCode = val;
                  print(val.trim().length);
                  if(val.trim().length==6)
                    {
                      signInWithSmsCode(val);
                     // signupBloc.add(VerifyphoneNumber(val));
                      setState(() {
                        inProgress = true;
                      });
                    }
                },
               enableInteractiveSelection: true,
                style: GoogleFonts.cairo(
                  color: theme=="light"?Colors.black.withOpacity(0.85):Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  helperStyle: GoogleFonts.cairo(
                    color: theme=="light"?Colors.black.withOpacity(0.85):Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  errorStyle: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  hintStyle: GoogleFonts.cairo(
                    // color: Colors.black54,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  hintText: 'OTP',
                  // labelText: 'OTP',
                  labelStyle: GoogleFonts.cairo(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  contentPadding: const EdgeInsets.all(0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Container(
              height: 40.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      '$_timer sec',
                      style: GoogleFonts.cairo(
                        color: theme=="light"?Colors.black.withOpacity(0.85):Colors.white,

                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _timer == 0
                      ? FlatButton(
                        onPressed: () {
                          print('Resend OTP');
                          print('Resend OTP222');
                          print(widget.phoneNumber);
                          signInWithphoneNumber(widget.phoneNumber);
                         /* signupBloc.add(
                            SignupWithphoneNumber(
                              name: widget.name,
                              phoneNumber: widget.phoneNumber,
                              email: widget.email,
                            ),
                          );*/
                          startTimer();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          getTranslated(context, "resendOtp"),
                          style: GoogleFonts.cairo(
                            color: theme=="light"?Colors.black.withOpacity(0.85):Colors.white,

                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                          : SizedBox(),
                ],
              ),
            ),
            //===========
            PinFieldAutoFill(
              decoration: UnderlineDecoration(
                textStyle: TextStyle(fontSize: 20, color: Colors.transparent),
                colorBuilder: FixedColorBuilder(Colors.transparent),
              ),
              codeLength: 6,
              onCodeSubmitted: (code) {
              },
              onCodeChanged: (code) {
                if (code.length == 6) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  otpController.text=code;
                  print(code);
                  signInWithSmsCode(code);
                  //signupBloc.add(VerifyphoneNumber(code));
                  setState(() {
                    inProgress = true;
                    smsCode=code;
                  });
                }
              },
            ),
            //===============

            SizedBox(
              height: 15.0,
            ),
            _timer>50?Center(child: CircularProgressIndicator()):buildVerificationBtn(context, inProgress),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVerificationBtn(BuildContext context, bool inProgress) {
    return inProgress
        ? Center(child: CircularProgressIndicator())
        : Container(
            width: double.infinity,
            height: 48.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FlatButton(
              onPressed: () {
                VerifyphoneNumber(smsCode);
                  //signupBloc.add(VerifyphoneNumber(smsCode));
                  setState(() {
                    inProgress = true;
                  });
              },
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(
                getTranslated(context, "Verify"),
                style: GoogleFonts.cairo(
                  color: theme=="light"?Colors.white:Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
  }
  Widget loadVerificationCode()
  {
    return Shimmer.fromColors(
      period: Duration(milliseconds: 800),
      baseColor: Colors.grey.withOpacity(0.5),
      highlightColor: Colors.black.withOpacity(0.5),
      child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width*.8,
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(
          horizontal: 16.0,
          ),
          decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15.0),
            ),
            ));
  }
  //================
  //send code
  Future<bool> signInWithphoneNumber(String phoneNumber) async {
    try {
      print("signInWithphoneNumber222");
      int forceResendToken;
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (authCredential) => phoneVerificationCompleted(authCredential),
        verificationFailed: (authException) => phoneVerificationFailed(authException,phoneNumber),
        codeSent: (verificationId, [code]) => phoneCodeSent(verificationId, [code]),
        codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout,
        forceResendingToken: forceResendToken,
      );
      print("dreamphonesendotpSuccess");
      return true;
    } catch (e) {
      print("dreamphonesendotpfailed");
      print(e);
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath).doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.phoneNumber,
        'screen': "otp",
        'function': "signInWithphoneNumber",
      });

      setState(() {
        inProgress = false;
      });
      showFailedSnakbar(getTranslated(context, "error"));
      return false;
    }
  }
  phoneVerificationCompleted(PhoneAuthCredential authCredential) {
    print("verification completed ${authCredential.smsCode}");
   // otpController.text=authCredential.smsCode;
    showFailedSnakbar("verification completed ${authCredential.smsCode}");
    signInWithSmsCodeStep2(authCredential);
    print('verified');
  }
  phoneVerificationCompleted2(AuthCredential authCredential) {

    print('verified');
  }

  phoneVerificationFailed(FirebaseException authException,String phone) async {
    print('failedssssssss111');
    String id = Uuid().v4();
    await FirebaseFirestore.instance.collection(Paths.errorLogPath).doc(id).set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': authException.message.toString(),
      'phone': phone,
      'screen': "otp",
      'function': authException.code.toString(),
    });
    print('Message: ${authException.message}');
    print('Code: ${authException.code}');
    setState(() {
      inProgress = false;
    });
    showFailedSnakbar(getTranslated(context, "tooMany"));
  }

  phoneCodeAutoRetrievalTimeout(String verificationCode) {
    print("verificationCode");
    print(verificationCode);
    this._verificationCode = verificationCode;
  }

  phoneCodeSent(String verificationCode, List<int> code) {
    print("otp sent");
    print(verificationCode);
    print(code.toString());
    this._verificationCode = verificationCode;
  }

  Future<void> signInWithSmsCode(String smsCode) async {
    try {
      setState(() {
        inProgress = true;
      });
      AuthCredential authCredential = PhoneAuthProvider.credential( verificationId: _verificationCode, smsCode: smsCode);
      signInWithSmsCodeStep2(authCredential);
    } catch (e) {
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath).doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.phoneNumber,
        'screen': "otp",
        'function': "signInWithSmsCode",
      });

      print('Code: ${e.toString()}');
      setState(() {
        inProgress = false;
      });
      showFailedSnakbar(getTranslated(context, "tooMany"));
      print("phonenumber11error "+e.toString());
      return null;
    }
  }
  Future<void> signInWithSmsCodeStep2(PhoneAuthCredential authCredential) async {
    try {
      setState(() {
        inProgress = true;
      });

      UserCredential authResult =  await firebaseAuth.signInWithCredential(authCredential);
      if (authResult!=null&&authResult.user != null&&authResult.user.uid!=null) {
        checkUser(widget.phoneNumber,widget.userType,authResult.user.uid);
      } else {
        String id = Uuid().v4();
        await FirebaseFirestore.instance.collection(Paths.errorLogPath).doc(id).set({
          'timestamp': Timestamp.now(),
          'id': id,
          'seen': false,
          'desc': "invalid sms code",
          'phone': widget.phoneNumber,
          'screen': "otp",
          'function': "signInWithSmsCodeStep2",
        });

        showFailedSnakbar('Verification failed!');
        setState(() {
          inProgress = false;
        });
      }
    } catch (e) {
      print("phonenumber11error "+e.toString());
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath).doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.phoneNumber,
        'screen': "otp",
        'function': "signInWithSmsCodeStep2",
      });

      showFailedSnakbar(e.toString());
      setState(() {
        inProgress = false;
      });
      return null;
    }
  }
}
