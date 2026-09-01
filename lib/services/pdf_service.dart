import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/profile_model.dart';
import '../models/fee_model.dart';

class PdfService {
  /// Generate printable PDF binary for Membership Certificate
  static Future<Uint8List> generateMembershipCertificate(ProfileModel profile) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final issueDate = dateFormat.format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.green900, width: 6),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.amber700, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Header
                  pw.Column(
                    children: [
                      pw.Text(
                        'ANSAR FAMILY COMMUNITY PLATFORM',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'CERTIFICATE OF COMMUNITY MEMBERSHIP',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.amber800,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        height: 2,
                        width: 300,
                        color: PdfColors.green800,
                      ),
                    ],
                  ),

                  // Body
                  pw.Column(
                    children: [
                      pw.Text(
                        'This is to officially certify that',
                        style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        profile.fullName?.toUpperCase() ?? 'VALUED MEMBER',
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green900,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        width: 400,
                        child: pw.Text(
                          'is a registered and verified member of the Ansar Family local community support network, dedicated to mutual assistance, brotherhood, and empowerment.',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey800),
                        ),
                      ),
                    ],
                  ),

                  // Details & Seal
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Left info
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Member ID: ${profile.id.substring(0, 8).toUpperCase()}',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.Text('Role: ${profile.role.toUpperCase()}',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.Text('Status: ${profile.status.toUpperCase()}',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                  color: PdfColors.green800)),
                          pw.Text('Date Issued: $issueDate',
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        ],
                      ),

                      // Decorative Seal Badge
                      pw.Container(
                        width: 70,
                        height: 70,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: PdfColors.amber100,
                          border: pw.Border.all(color: PdfColors.amber800, width: 3),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'OFFICIAL\nSEAL',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green900,
                            ),
                          ),
                        ),
                      ),

                      // Right signature
                      pw.Column(
                        children: [
                          pw.Container(width: 140, height: 1, color: PdfColors.black),
                          pw.SizedBox(height: 4),
                          pw.Text('Community Management',
                              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Ansar Family Executive Board',
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generate Financial Summary PDF Report
  static Future<Uint8List> generateFinancialSummaryReport(List<FeeModel> fees) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final totalCollected = fees
        .where((f) => f.status == 'paid')
        .fold<double>(0, (sum, f) => sum + f.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'ANSAR FAMILY COMMUNITY',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                ),
                pw.Text(
                  'FINANCIAL SUMMARY REPORT',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.amber800),
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.green800),
            pw.SizedBox(height: 8),
          ],
        ),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Generated On: ${dateFormat.format(DateTime.now())}'),
              pw.Text('Total Transactions: ${fees.length}'),
            ],
          ),
          pw.SizedBox(height: 12),

          // Total Banner
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.green800),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Mahallu Funds Collected:',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('INR ${totalCollected.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Transactions Table
          pw.Table.fromTextArray(
            headers: ['Member Name', 'Period', 'Amount', 'Status', 'Payment Date'],
            data: fees.map((f) => [
              f.userName ?? f.userId.substring(0, 8),
              f.period ?? 'N/A',
              'INR ${f.amount.toStringAsFixed(2)}',
              f.status.toUpperCase(),
              dateFormat.format(f.paymentDate),
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green900),
            cellAlignment: pw.Alignment.centerLeft,
            rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Print or open download preview
  static Future<void> printOrDownloadPdf(Uint8List pdfData, String filename) async {
    await Printing.sharePdf(bytes: pdfData, filename: filename);
  }
}
