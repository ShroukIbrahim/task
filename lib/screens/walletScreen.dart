// @dart=2.9

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/userPaymentHistory.dart';
import 'package:grocery_store/widget/orderListItem.dart';
import 'package:grocery_store/widget/userPaymentHistoryListItem.dart';
import 'package:http/http.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WalletScreen extends StatefulWidget {
  final GroceryUser loggedUser;
  const WalletScreen({Key key, this.loggedUser}) : super(key: key);
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>with SingleTickerProviderStateMixin {
  AccountBloc accountBloc;
  GroceryUser user;
  bool load=false,showBalance=true,showHistory=false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving=false,showPayView=false;
  GroceryUser searchUser;
  List<GroceryUser> users = [];
  String to,amount,balance,theme;
  num _stackIndex = 1;
  String initialUrl = '';
  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetAccountDetailsEvent(widget.loggedUser.uid));
    accountBloc.listen((state) {
      print(state);
      if (state is GetAccountDetailsCompletedState) {
        user = state.user;
        if(mounted)
          setState(() {
            load=false;
          });
        if(user!=null&&user.photoUrl!=null&&user.photoUrl!="")
          if(mounted)
            setState(() {
              balance=user.balance.toString();
            });
      }
    });
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
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
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
                  child: Container(height: 80,
                    child:Row(
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
                                  color: theme=="light"?Colors.white:Colors.black,
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
                            getTranslated(context, "wallet"),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 3,
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
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
            ),
            SizedBox(height: 30,),
            showBalance? Expanded(
              child: ListView(padding:const EdgeInsets.only(left: 10,right: 10),
                  children: <Widget>[ Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 25.0,
                          ),
                          Text(
                            getTranslated(context, "addBalanceText"),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 6,
                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.black:Colors.white,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              to=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.call),
                              labelText: getTranslated(context, "to"),
                              hintText: "+966XXXXXXXXX",
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String val) {
                              if (val.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              amount=val;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                // color: Colors.black54,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(Icons.attach_money),
                              labelText: getTranslated(context, "amount"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            height: 45.0,
                            width: double.infinity,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 0.0),
                            child: saving?Center(child: CircularProgressIndicator()):FlatButton(
                              onPressed: () {
                                save();
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.send,
                                    color:theme=="light"?Colors.white:Colors.black,
                                    size: 20.0,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    getTranslated(context, "addBalance"),
                                    style: GoogleFonts.poppins(
                                      color:theme=="light"?Colors.white:Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ]),
            ):SizedBox(),
            showHistory? Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
                //Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  UserPaymentHistoryListItem(
                    history: UserPaymentHistory.fromFirestore(documentSnapshot[index]),
                    theme:theme);
                },
                query: FirebaseFirestore.instance.collection(Paths.userPaymentHistory)
                    .where('userUid', isEqualTo: widget.loggedUser.uid)
                    .orderBy('payDateValue', descending: true),
                isLive: true,
              ),
            ):SizedBox(),

          ],
        ),
        Positioned(
            right: 0.0,
            top: 100.0,
            left: 0,
            child:  Center(
              child:  Container(height: 60,width: size.width*.9,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 0.0),
                        blurRadius: 15.0,
                        spreadRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                  child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          splashColor: Colors.green.withOpacity(0.5),
                          onTap: () {
                            setState(() {
                              showBalance=true;
                              showHistory=false;
                            });
                          },
                          child: Container(height: 40,width: size.width*.4,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: showBalance?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "addBalance"),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  color: showBalance?theme=="light"?Colors.white:Colors.white:theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),),
                        ),
                        SizedBox(width: 5,),
                        InkWell(
                          splashColor: Colors.green.withOpacity(0.5),
                          onTap: () {
                            setState(() {
                              showHistory=true;
                              showBalance=false;
                            });
                          },
                          child: Container(height: 40,width: size.width*.4,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: showHistory?theme=="light"?Theme.of(context).primaryColor:Colors.black:Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "paymentHistory"),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  color: showHistory?theme=="light"?Colors.white:Colors.white:theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),),
                        ),


                      ])
              ),
            )
        ),
        showPayView ? Positioned(
          child: Scaffold(
            body:IndexedStack(
              index: _stackIndex,
              children: <Widget>[
                WebView(
                  initialUrl:initialUrl,
                  navigationDelegate: (NavigationRequest request) {
                    if(request.url.startsWith("https://www.jeras.io/app/redirect_url")){
                      print('onPageSuccess');
                      setState(() {
                        _stackIndex = 1;
                        showPayView = false;
                        var str=request.url;
                        const start = "tap_id=";
                        final startIndex = str.indexOf(start);
                        print(str.substring(startIndex + start.length, str.length));
                        String charge=str.substring(startIndex + start.length, str.length);
                        print("chargeeee11111111  "+charge);
                        payStatus(charge);
                      });
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                  onPageStarted: (url) => print("OnPagestarted " + url),
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                  onPageFinished: (url) {
                    print("onPageFinished " + url);
                    setState(() => _stackIndex = 0);} ,
                ),
                Center(child: Text('Loading  ...')),
                Center(child: Text('order ...'))
              ],
            ),
          ),
        ) : Container()
      ]),
    );
  }

  save() async {

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try{
        setState(() {
          saving=true;
        });
        //get userdata
        QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection(Paths.usersPath)
            .where( 'phoneNumber', isEqualTo: to, )
            .where( 'userType', isEqualTo: "USER", ).get();

        for (var doc in querySnapshot.docs) {
          users.add(GroceryUser.fromFirestore(doc));
        }
        if(users.length>0)
        {
          setState(() {
            searchUser=users[0];
          });
          pay();
        }
        else
        {
          addingDialog(MediaQuery.of(context).size,getTranslated(context, "noUser"),false);
          setState(() {
            saving=false;
          });
        }

      }catch(e)
      {print("rrrrrrrrrr"+e.toString());}
    }

  }
  addingDialog(Size size,String data,bool status) {

    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            /* Text(
              getTranslated(context, "appointments"),
              style: GoogleFonts.cairo(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Text(
              status?getTranslated(context, "appointmentRegister"):getTranslated(context, "error"),
              style: GoogleFonts.cairo(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: status?Colors.black87:Colors.red,
              ),
            ),*/
            SizedBox(
              height: 5.0,
            ),
            Text(
              data,
              style: GoogleFonts.cairo(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Center(
              child: Container(
                width: size.width*.5,
                child: FlatButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: GoogleFonts.cairo(
                      color: Colors.black87,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ), barrierDismissible: false,
      context: context,
    );
  }
  pay() async {
    final uri = Uri.parse('https://api.tap.company/v2/charges');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
     'Authorization':"Bearer sk_test_4KmXWCt20xzpfeNvyOiFUY3G",
      'Connection':'keep-alive',
      'Accept-Encoding':'gzip, deflate, br'

    };
    Map<String, dynamic> body ={
      "amount": amount,
      "currency": "USD",
      "threeDSecure": true,
      "save_card": true,
      "description": "Test Description",
      "statement_descriptor": "Sample",
      "metadata": {
        "udf1": "test 1",
        "udf2": "test 2"
      },
      "reference": {
        "transaction": "txn_0001",
        "order": "ord_0001"
      },
      "receipt": {
        "email": false,
        "sms": true
      },
      "customer": {
        "id": widget.loggedUser.customerId!=null? widget.loggedUser.customerId:'',
        "first_name":  widget.loggedUser.name,
        "middle_name": ".",
        "last_name": ".",
        "email":  widget.loggedUser.name+"@jeras.com",
        "phone": {"country_code": "غ",
          "number":  widget.loggedUser.phoneNumber
        }
      },
      "merchant": {
        "id": ""
      },
      "source": {
        "id": "src_all"
      },
      "post": {
        "url": "http://your_website.com/post_url"
      },
      "redirect": {
        "url": "https://www.jeras.io/app/redirect_url"
      }
    };
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');
    var response = await post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );
    String responseBody = response.body;
    print("start5");
    print(responseBody);
    var res = json.decode(responseBody);
    print(res['transaction']);
    print("start6");
    String url = res['transaction']['url'];
    setState(() {
      initialUrl=url;
      print("yarab applepay");
      print(initialUrl);
      showPayView = true;
    });


  }
  payStatus(String chargeId) async {
    final uri = Uri.parse('https://api.tap.company/v2/charges/'+chargeId);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization':"Bearer sk_test_4KmXWCt20xzpfeNvyOiFUY3G",
      'Connection':'keep-alive',
      'Accept-Encoding':'gzip, deflate, br'
    };
    print("startchargeId1");
    var response = await get(
      uri,
      headers: headers,

    );
    String responseBody = response.body;
    var res = json.decode(responseBody);

    String customerId=res['customer']['id'];
    customerId= customerId!=null?customerId:"";
    if(res['status']=="CAPTURED")
    {
      //update userBalance
      dynamic balance=double.parse(amount.toString());
      if(searchUser.balance!=null)
      { balance=searchUser.balance+balance;
      searchUser.balance=balance;
      }
      await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.loggedUser.uid).set({
        'customerId': customerId,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection(Paths.userPaymentHistory).doc(Uuid().v4()).set({
        'userUid': widget.loggedUser.uid,
        'payType': "send",
        'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
        'payDateValue':DateTime.now().millisecondsSinceEpoch,
        'amount':amount,
        'otherData': {
          'uid': searchUser.uid,
          'name': searchUser.name,
          'image': searchUser.photoUrl,
          'phone': searchUser.phoneNumber,
        },
      });

      await FirebaseFirestore.instance.collection(Paths.usersPath).doc(searchUser.uid).set({
        'balance': balance,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection(Paths.userPaymentHistory).doc(Uuid().v4()).set({
        'userUid': searchUser.uid,
        'payType': "receive",
        'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
        'payDateValue':Timestamp.now().millisecondsSinceEpoch,
        'amount':amount,
        'otherData': {
          'uid': widget.loggedUser.uid,
          'name': widget.loggedUser.name,
          'image': widget.loggedUser.photoUrl,
          'phone': widget.loggedUser.phoneNumber,
        },
      });
      addingDialog(MediaQuery.of(context).size,getTranslated(context, "addBalanceDoneSuccessfully"),true);
      if(widget.loggedUser.phoneNumber==to)
        accountBloc.add(GetAccountDetailsEvent(widget.loggedUser.uid));
      setState(() {
        showPayView=false;
        saving=false;
      });
    }
    else
    {
      setState(() {
        showPayView=false;
        saving=false;
      });
      showSnakbar(getTranslated(context, "failed"),true);

    }
  }
  void showSnakbar(String s,bool status) {
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
      backgroundColor: status?Colors.lightGreen:Colors.red,
      action: SnackBarAction(
          label: 'OK', textColor: Colors.white, onPressed: () {}),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
