import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/api/pdf_api.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/payHistory.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/invoice_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfParagraphApi {
  static Future<File> generate(GroceryUser user,PayHistory pay,String date,Size size) async {
    final pdf = Document();
    final customFont = Font.ttf(await rootBundle.load('assets/Hacen-Egypt.ttf'));
    final image = (await rootBundle.load('assets/applicationIcons/colorLogo.png')).buffer.asUint8List();
    final String balance=double.parse((double.parse(pay.balance.toString())*3.69).toString()).toStringAsFixed(1);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Image(pw.MemoryImage(image), width: 100, height: 100, fit: pw.BoxFit.fill),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Container(height: 2,width:size.width*.4, color:PdfColors.black ),
                  pw.SizedBox(width: 10),
                  pw.Text("Invoice",style: pw.TextStyle( fontWeight: FontWeight.bold,fontSize: 30, color: PdfColors.black)),
                  pw.SizedBox(width: 10),
                  pw.Container(height: 2,width:size.width*.4, color:PdfColors.black ),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text("Invoice To:",style: pw.TextStyle(fontSize: 20, color: PdfColors.black)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column( mainAxisAlignment: pw.MainAxisAlignment.start,crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(user.fullName==null?user.name:user.fullName,textDirection: TextDirection.rtl, style: pw.TextStyle(  font: customFont,)),
                     // pw.Text("kk"),//user.fullName==null?user.name:user.fullName),
                      pw.SizedBox(height: 10),
                      pw.Text(user.fullAddress==null?"Saudi":user.fullAddress),
                      pw.SizedBox(height: 10),
                      pw.Text(user.phoneNumber),
                    ],
                  ),
                  pw.SizedBox(width: 2,child: pw.Container(color:PdfColors.black)),
                  pw.Column( mainAxisAlignment: pw.MainAxisAlignment.start,crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Invoice Number: "+pay.invoiceNumber),
                      pw.SizedBox(height: 10),
                      pw.Text("Date: "+date),
                      pw.SizedBox(height: 10),
                      pw.Text("Total: "+balance+"SAR"),

                    ],
                  )
                ],
              ),
              pw.SizedBox(height: 50),
              blackSpace(size),
              pw.Row(
                children: [
                  pw.Expanded(child:  pw.Container(height: 30,width:size.width, color:PdfColors.pink50 ,child:
                  pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text("Statment", textAlign: pw.TextAlign.left,style: pw.TextStyle(fontSize: 20, color: PdfColors.black))),
                      pw.Expanded(child: pw.Text("Currency", textAlign: pw.TextAlign.right,style: pw.TextStyle(fontSize: 20, color: PdfColors.black))),
                      pw.Expanded(child: pw.Text("Date", textAlign: pw.TextAlign.right,style: pw.TextStyle(fontSize: 20, color: PdfColors.black))),
                    ],
                  ),),),

                ],
              ),

              blackSpace(size),
              pw.Expanded(
                child:  pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text("Consult dues in dream app", textAlign: pw.TextAlign.left)),
                    pw.Expanded(child: pw.Text("SAR", textAlign: pw.TextAlign.right)),
                    pw.Expanded(child: pw.Text(date, textAlign: pw.TextAlign.right)),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),
              blackSpace(size),
              pw.Row(
                children: [
                  pw.Expanded(child:  pw.Container(height: 30,width:size.width, color:PdfColors.pink50 ,child:
                  pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text("Total:   "+balance,style: pw.TextStyle(fontSize: 20, color: PdfColors.black)),)
                    ],
                  ),),),

                ],
              ),
              blackSpace(size),
              pw.SizedBox(height: 25),
              pw.Text("Payment methods,",style: pw.TextStyle(fontSize: 15, color: PdfColors.black)),
              pw.SizedBox(height: 15),
              pw.Text("Bank transfer, Paypal,Stc pay",style: pw.TextStyle(fontSize: 15, color: PdfColors.black)),
            ],
          );
        },
      ),
    );
    return PdfApi.saveDocument(name: 'payment.pdf', pdf: pdf);
  }
  static pw.Widget  blackSpace(Size size){
    return pw.Row( children: [
      pw.Expanded(child:  pw.Container(height: 1,width:size.width, color:PdfColors.black ,child:
      pw.Row(
        children: [
          pw.Expanded(child: pw.Text("  ", textAlign: pw.TextAlign.left)),
        ],
      ),),),

    ],
    );
  }
  pw.Expanded itemColumn(List<CustomRow> elements) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          for (var element in elements)
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text(element.statment, textAlign: pw.TextAlign.left)),
                pw.Expanded(child: pw.Text(element.currency, textAlign: pw.TextAlign.right)),
                pw.Expanded(child: pw.Text(element.total, textAlign: pw.TextAlign.right)),
                pw.Expanded(child: pw.Text(element.date, textAlign: pw.TextAlign.right)),
              ],
            )
        ],
      ),
    );
  }
 /* static Widget buildCustomHeader() => Container(
        padding: EdgeInsets.only(bottom: 3 * PdfPageFormat.mm),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 2, color: PdfColors.blue)),
        ),
        child: Row(
          children: [
            PdfLogo(),
            SizedBox(width: 0.5 * PdfPageFormat.cm),
            Text(
              'Create Your PDF',
              style: TextStyle(fontSize: 20, color: PdfColors.blue),
            ),
          ],
        ),
      );

  static Widget buildCustomHeadline() => Header(
        child: Text(
          'My Third Headline',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(color: PdfColors.red),
      );

  static Widget buildLink() => UrlLink(
        destination: 'https://flutter.dev',
        child: Text(
          'Go to flutter.dev',
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: PdfColors.blue,
          ),
        ),
      );

  static List<Widget> buildBulletPoints() => [
        Bullet(text: 'First Bullet'),
        Bullet(text: 'Second Bullet'),
        Bullet(text: 'Third Bullet'),
      ];*/
}
