// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user.dart';
import 'package:uuid/uuid.dart';

import 'package:webview_flutter/webview_flutter.dart';

class AddAppointmentScreen extends StatefulWidget {

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen>with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving=false;
  String userPhone,consultPhone,theme;
  @override
  void initState() {
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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
                        getTranslated(context, "addAppointement"),
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

          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

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
                        userPhone=val;
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
                      keyboardType: TextInputType.multiline,
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
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "userPhone"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 14.5,
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
                        consultPhone=val;
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
                      keyboardType: TextInputType.multiline,
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
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "consultPhone"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 14.5,
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
                              color: theme=="light"?Colors.white:Colors.black,
                              size: 20.0,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              getTranslated(context, "add"),
                              style: GoogleFonts.poppins(
                                color: theme=="light"?Colors.white:Colors.black,
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
          ),
        ],
      ),
    );
  }
  save() async {
    GroceryUser user, consult;
    List<GroceryUser> users = [],consults=[];
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try{
        setState(() {
          saving=true;
        });
      //get userdata
        QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection(Paths.usersPath)
            .where( 'phoneNumber', isEqualTo: userPhone, ).get();

        for (var doc in querySnapshot.docs) {
          users.add(GroceryUser.fromFirestore(doc));
        }
        if(users.length>0)
            user=users[0];
        //get consultdata
        QuerySnapshot querySnapshot2 = await  FirebaseFirestore.instance.collection(Paths.usersPath)
            .where( 'phoneNumber', isEqualTo: consultPhone, ).get();

        for (var doc in querySnapshot2.docs) {
          consults.add(GroceryUser.fromFirestore(doc));
        }
        if(consults.length>0)
          consult=consults[0];
        //addappointment
        DateTime date=DateTime.now();
        String appointmentId=Uuid().v4();
        if(user!=null&&consult!=null) {
          await FirebaseFirestore.instance.collection(Paths.appAppointments)
              .doc(appointmentId)
              .set({
            'appointmentId': appointmentId,
            'type': "fake",
            'appointmentStatus': 'new',
            'timestamp': Timestamp.now(), //FieldValue.serverTimestamp(),
            'timeValue': DateTime(date.year, date.month, date.day)
                .millisecondsSinceEpoch,
            'secondValue': DateTime(
                date.year, date.month, date.day, date.hour, date.minute,
                date.second).millisecondsSinceEpoch,
            'appointmentTimestamp': Timestamp.fromDate(date),
            'consultChat': 0,
            'userChat': 0,
            'orderId': Uuid().v4(),
            'callPrice':0.0,// double.parse(consult.price),
            'consult': {
              'uid': consult.uid,
              'name': consult.name,
              'image': consult.photoUrl,
              'phone': consult.phoneNumber,
            },
            'user': {
              'uid': user.uid,
              'name': user.name,
              'image': user.photoUrl,
              'phone': user.phoneNumber,

            },
            'date': {
              'day': date.day,
              'month': date.month,
              'year': date.year,
            },
            'time': {
              'hour': date.hour,
              'minute': date.minute,
            },
          });
          appointmentDialog(MediaQuery.of(context).size,date.toString(),true);
        }
        else
          {
            appointmentDialog(MediaQuery.of(context).size,getTranslated(context, 'invalidNumbers'),false);
          }
        setState(() {
          saving=false;
        });
      }catch(e)
      {print("rrrrrrrrrr"+e.toString());}
    }

  }
  appointmentDialog(Size size,String data,bool status) {

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
            Text(
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
}
