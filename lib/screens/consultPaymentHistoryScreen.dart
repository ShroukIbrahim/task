// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/api/arabicPdf.dart';
import 'package:grocery_store/api/pdf_api.dart';
import 'package:grocery_store/api/pdf_paragraph_api.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/payHistory.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/userPaymentHistory.dart';
import 'package:grocery_store/screens/table.dart';
import 'package:grocery_store/widget/button_widget.dart';
import 'package:grocery_store/widget/techAppointmentWidget.dart';
import 'package:grocery_store/widget/userPaymentHistoryListItem.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import 'invoice_service.dart';

class ConsultPaymentHistoryScreen extends StatefulWidget {
  final GroceryUser user;

  const ConsultPaymentHistoryScreen({Key key, this.user}) : super(key: key);
  @override
  _ConsultPaymentHistoryScreenState createState() => _ConsultPaymentHistoryScreenState();
}

class _ConsultPaymentHistoryScreenState extends State<ConsultPaymentHistoryScreen>with SingleTickerProviderStateMixin {
  List <PayHistory>PayHistoryList=[];
    bool load=false;String theme;
  final PdfInvoiceService service = PdfInvoiceService();

  @override
  void initState() {
    super.initState();
    getPaymentHistory();
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
  getPaymentHistory() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.payHistoryPath)
          .where('consultUid', isEqualTo:widget.user.uid )
          .orderBy("payDate", descending: true)
          .get();
      var payList = List<PayHistory>.from(
        querySnapshot.docs.map(
              (snapshot) => PayHistory.fromFirestore(snapshot),
        ),
      );
      print(payList.length);
      setState(() {
        PayHistoryList=payList;
        load=false;
      });
    } catch (e) {
      setState(() {
        load=false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
      int numItems = 10;
    List<bool> selected = List<bool>.generate(numItems, (int index) => false);
    Size size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .primaryColor,
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
                            getTranslated(context, "paymentHistory"),
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

           //=======
            load?CircularProgressIndicator():SingleChildScrollView(
              child: DataTable(
                //sortAscending: true,
                  sortColumnIndex: 0,
                  //columnSpacing: 2.0,
                  dataRowHeight: 53.0,
                  headingRowHeight: 70.0,
                  columns: [
                    DataColumn(label: Text(getTranslated(context, "amount",),
                      textAlign:TextAlign.start,
                      style:TextStyle(color:theme=="light"?Colors.black:Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                      tooltip: getTranslated(context, "amount"),
                    ),
                    DataColumn(label: Center(
                      child: Text(getTranslated(context, "date"),
                        textAlign:TextAlign.center,
                        style:TextStyle(color:theme=="light"?Colors.black:Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                    ),
                      tooltip: getTranslated(context, "date"),
                    ),
                    DataColumn(label: Text(getTranslated(context, "download"),
                      textAlign:TextAlign.center,
                      style:TextStyle(color:theme=="light"?Colors.black:Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                      tooltip: getTranslated(context, "download"),
                    ),
                  ],
                  rows: [
                    for(int x=0;x<PayHistoryList.length;x++)
                    DataRow(cells: [
                      DataCell(Text(double.parse(PayHistoryList[x].balance.toString()).toStringAsFixed(1)+"\$"),
                        placeholder: true,
                      ),
                      DataCell(Text('${new DateFormat('dd MMM yyyy, hh:mm a').format((PayHistoryList[x].payTime.toDate()))}'),
                      ),
                      DataCell(Center(
                        child: Icon(
                          Icons.arrow_circle_down,
                          color: Colors.black,
                          size: 30.0,
                        ),
                      ),onTap: () async {
                        final String date='${new DateFormat('dd MMM yyyy').format(PayHistoryList[x].payTime.toDate())}';
                         final pdfFile = await PdfParagraphApi.generate(widget.user,PayHistoryList[x],date,size);
                          PdfApi.openFile(pdfFile);

                      })
                    ]),

                  ]),
            ),
            Padding(padding: const EdgeInsets.only(top: 80),),
            //=========

          ],
        ),

      ]),
    );
  }
}
