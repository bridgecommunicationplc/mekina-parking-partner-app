import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:owner/model/user_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfInvoiceApi {
  static Future<pw.Document> generate(
    PdfColor color,
    pw.Font fontFamily,
    UserModel userModel,
    String phoneNumber,
    String paymentStatus,
    String createdAt,
    String sessionId,
    String amount,
    String wordsAmount,
    String note,
    String withdrawMethod, String serviceFee
  ) async {
    final pdf = pw.Document();

    final ByteData bytes = await rootBundle.load('assets/logo.png');
    final ByteData bytesStamp = await rootBundle.load('assets/stamp.png');
    final Uint8List imageData = bytes.buffer.asUint8List();
    final Uint8List imageDataStamp = bytesStamp.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: color, width: 2),
            ),
            padding: const pw.EdgeInsets.all(15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Image(pw.MemoryImage(imageData), height: 80),
                    pw.SizedBox(width: 180),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Mekina Partner",
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [
                            pw.SizedBox(
                              width: 120,
                              child: pw.Text("TIN No.", style: pw.TextStyle(fontSize: 14)),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text("0068011163", style: pw.TextStyle(fontSize: 14)),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.SizedBox(
                              width: 120,
                              child: pw.Text("VAT Reg. No.", style: pw.TextStyle(fontSize: 14)),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text("", style: pw.TextStyle(fontSize: 14)),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.SizedBox(
                              width: 120,
                              child: pw.Text("Tel.", style: pw.TextStyle(fontSize: 14)),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text(userModel.phoneNumber.toString(), style: pw.TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Divider(color: PdfColor.fromInt(0xFF4CC50D)),
                pw.Center(
                  child: pw.Text(
                    "Transaction Information",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                pw.Divider(color: PdfColor.fromInt(0xFF4CC50D)),
                pw.SizedBox(height: 10),

                detailsWidget("Recever Name or beneficiary name", userModel.fullName.toString(), color),
                pw.SizedBox(height: 10),
                detailsWidget(
                    "Paid By telebirr ", phoneNumber.toString(), color),
                pw.SizedBox(height: 10),
                detailsWidget("recever or Beneficiary Account Type", "Partner", color),
                pw.SizedBox(height: 10),
                detailsWidget(
                    "Transaction status", paymentStatus.toString(), color),
                pw.SizedBox(height: 10),
                // Table Header
              pw.Table(
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: color),
                    ),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("Receipt No."),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("Payment date"),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("Settled Amount"),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: color),
                    ),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(sessionId.toString()),
                      ),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            left: pw.BorderSide(color: color),
                          ),
                        ),
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(createdAt.toString()),
                      ),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            left: pw.BorderSide(color: color),
                          ),
                        ),
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(amount.toString()),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(""),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("Stamp Duty:", textAlign: pw.TextAlign.right),
                      ),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: color),
                            right: pw.BorderSide(color: color),
                            left: pw.BorderSide(color: color),
                          ),
                        ),
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("0.0 Birr"),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(""),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("Discount Amount:", textAlign: pw.TextAlign.right),
                      ),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: color),
                            right: pw.BorderSide(color: color),
                            left: pw.BorderSide(color: color),
                          ),
                        ),
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("0.0 Birr"),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(""),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("Service fee:", textAlign: pw.TextAlign.right),
                      ),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: color),
                            right: pw.BorderSide(color: color),
                            left: pw.BorderSide(color: color),
                          ),
                        ),
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("${serviceFee.toString()} Birr"),
                      ),
                    ],
                  ), pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(""),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("Service fee VAT:", textAlign: pw.TextAlign.right),
                      ),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: color),
                            right: pw.BorderSide(color: color),
                            left: pw.BorderSide(color: color),
                          ),
                        ),
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("0.0 Birr"),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(""),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("Total Paid Amount:", textAlign: pw.TextAlign.right),
                      ),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: color),
                            right: pw.BorderSide(color: color),
                            left: pw.BorderSide(color: color),
                          ),
                        ),
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text("${double.parse(amount.toString()) + double.parse(serviceFee.toString())} Birr"),
                      ),
                    ],
                  ),
                ],
              ),
              // pw.Table.fromTextArray(
                //   border: pw.TableBorder.all(color: color),
                //   headers: ["Receipt No.", "Payment date", "Settled Amount"],
                //   data: [
                //     [
                //       sessionId.toString(),
                //       "               ${createdAt.toString()}",
                //       amount.toString()
                //     ],
                //     [
                //       "",
                //       "                                                          Total Paid Amount:",
                //       amount.toString()
                //     ],
                //   ],
                // ),
                pw.SizedBox(height: 40),
                detailsPaymentWidget(
                    "Total amount in word", wordsAmount.toString(), color),
                pw.SizedBox(height: 10),
                detailsPaymentWidget("Payment Reason", note.toString(), color),
                pw.SizedBox(height: 10),
                detailsPaymentWidget(
                    "Payment Mode", withdrawMethod.toString(), color),
                pw.SizedBox(height: 10),
                // pw.Divider(),
                pw.SizedBox(height: 30),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Thank you for using Mekina Parking",
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(fontSize: 10, color: color),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Please contact us:${userModel.phoneNumber.toString()}",
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(fontSize: 10, color: color),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Center(
                  child: pw.Image(pw.MemoryImage(imageDataStamp), height: 80),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget detailsWidget(String title, String value, PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Container(
          width: 250,
          child:
              pw.Text(title, style: pw.TextStyle(fontSize: 12, color: color)),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, color: color),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    );
  }

  static pw.Widget detailsPaymentWidget(
      String title, String value, PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 12, color: color)),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(value, style: pw.TextStyle(fontSize: 12, color: color)),
              pw.Divider(color: color, endIndent: 2),
            ],
          ),
        ),
      ],
    );
  }
}
