// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';

typedef OnDelete();

class UserForm extends StatefulWidget {
  final WorkTimes range;
  final state = _UserFormState();
  final OnDelete onDelete;
  final String currency;

  UserForm({Key key, this.range,this.currency, this.onDelete}) : super(key: key);
  @override
  _UserFormState createState() => state;

  bool isValid() => state.validate();
}

class _UserFormState extends State<UserForm> {
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Material(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(8),
        child: Form(
          key: form,
          child: Container(height: 50,
            child:  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row( mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                  Container(width: 30,height:40,child:
                  TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(3),
                    ],
                    textAlignVertical: TextAlignVertical.center,
                    initialValue: widget.range.from,
                    onSaved: (val) => widget.range.from = val,
                    validator: (val) =>
                    val.length !=0 ? null : getTranslated(context, "required"),
                    enableInteractiveSelection: true,
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontSize: 11.0,
                      letterSpacing: 0.5,
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300], width: 0.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300], width: 0.0),
                      ),
                      contentPadding: EdgeInsets.all(2),
                    ),
                  ),),
                  Text(
                    getTranslated(context, "to"),
                    style: GoogleFonts.cairo(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                      color: Colors.black,
                    ),
                  ),
                  Container(width: 30,height:40,child:TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(3),
                    ],
                    textAlignVertical: TextAlignVertical.center,
                    initialValue: widget.range.to,
                    onSaved: (val) => widget.range.to = val,
                    validator: (val) =>
                    val.length !=0 ? null : getTranslated(context, "required"),
                    enableInteractiveSelection: true,
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontSize: 11.0,
                      letterSpacing: 0.5,
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300], width: 0.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300], width: 0.0),
                      ),
                      contentPadding: EdgeInsets.all(2),
                    ),
                  ),),
                ],),


              ],
            ),

          ),
        ),
      ),
    );
  }

  ///form validator
  bool validate() {
    var valid = form.currentState.validate();
    if (valid) form.currentState.save();
    return valid;
  }
}
