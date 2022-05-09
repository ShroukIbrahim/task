import 'dart:io';

import 'package:flutter/services.dart';
import 'package:grocery_store/api/pdf_api.dart';
import 'package:grocery_store/models/payHistory.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/invoice_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ArabicPdf {
  static Future<File> generate(GroceryUser user,PayHistory pay,String date) async {
    final pdf = Document();

    final customFont = Font.ttf(await rootBundle.load('assets/Hacen-Egypt.ttf'));
    final image = (await rootBundle.load('assets/applicationIcons/6.png')).buffer.asUint8List();
    final String balance=double.parse((double.parse(pay.balance.toString())*3.69).toString()).toStringAsFixed(1)+"ريال سعودي";
    //final String date='${new DateFormat('dd MMM yyyy').format(pay.payTime.toDate())}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text("تطبيق رؤيا",textDirection: TextDirection.rtl, style: pw.TextStyle( fontSize: 18.0, font: customFont,)),
                      pw.Text("فاتوره بالمستحقات الماليه ",textDirection: TextDirection.rtl, style: pw.TextStyle(fontSize: 15.0, font: customFont,)),
                    ],
                  ),
                  pw.Image(pw.MemoryImage(image), width: 50, height: 50, fit: pw.BoxFit.fill),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(user.fullName==null?"الاسم بالكامل":user.fullName,textDirection: TextDirection.rtl, style: pw.TextStyle( font: customFont,)),
                      pw.Text(user.fullAddress==null?"العنوان بالكامل":user.fullAddress,textDirection: TextDirection.rtl, style: pw.TextStyle( font: customFont,)),
                      pw.Text(user.phoneNumber,textDirection: TextDirection.rtl, style: pw.TextStyle( font: customFont,)),

                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text("رقم الفاتورة: "+pay.invoiceNumber,textDirection: TextDirection.rtl, style: pw.TextStyle(fontSize: 15.0,  font: customFont,)),
                      pw.Text("التاريخ:  "+date,textDirection: TextDirection.rtl, style: pw.TextStyle( fontSize: 15.0, font: customFont,)),
                      pw.Text("الاجمالي:  "+balance,textDirection: TextDirection.rtl, style: pw.TextStyle(fontSize: 15.0, font: customFont,)),

                    ],
                  )
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Text(
                  "Dear Customer, thanks for buying at Flutter Explained, feel free to see the list of items below."),
              pw.SizedBox(height: 25),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(child: pw.Text("الاجمالي",textDirection: TextDirection.rtl, style: pw.TextStyle( font: customFont,))),
                        pw.Expanded(child: pw.Text("التاريخ",textDirection: TextDirection.rtl, style: pw.TextStyle( font: customFont,))),
                        pw.Expanded(child: pw.Text("العملة",textDirection: TextDirection.rtl, style: pw.TextStyle( font: customFont,))),
                        pw.Expanded(child: pw.Text("البيان",textDirection: TextDirection.rtl, style: pw.TextStyle( font: customFont,))),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Expanded(child: pw.Text(pay.balance.toString(),textDirection: TextDirection.rtl, style: pw.TextStyle( font: customFont,))),
                        pw.Expanded(child: pw.Text(date,textDirection: TextDirection.rtl, style: pw.TextStyle( font: customFont,))),
                        pw.Expanded(child: pw.Text("ريال سعودي",textDirection: TextDirection.rtl, style: pw.TextStyle( font: customFont,))),
                        pw.Expanded(child: pw.Text("مستحقات الشيخ لدي منصة رؤيا",textDirection: TextDirection.rtl, style: pw.TextStyle( font: customFont,))),
                      ],
                    )
                  ],
                ),
              ),
              pw.SizedBox(height: 25),
              pw.Text("Thanks for your trust, and till the next time."),
              pw.SizedBox(height: 25),
              pw.Text("Kind regards,"),
              pw.SizedBox(height: 25),
              pw.Text("Max Weber")
            ],
          );
        },
      ),
    );
    return PdfApi.saveDocument(name: 'my_example.pdf', pdf: pdf);
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
  static Widget buildCustomHeader() => Container(
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
  ];
}
