import 'dart:typed_data';

import 'package:excel/excel.dart' as xlsx;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/family_member_model.dart';
import '../models/profile_model.dart';

class MemberExportService {
  static const _headers = [
    'Name',
    'Mobile Number',
    'Address',
    'Email',
    'Username',
    'Total Household Members',
  ];

  static Uint8List generateExcel(
    List<ProfileModel> profiles,
    List<FamilyMemberModel> familyMembers,
  ) {
    final workbook = xlsx.Excel.createExcel();
    final defaultSheetName = workbook.sheets.keys.first;
    workbook.rename(defaultSheetName, 'Members');
    final sheet = workbook['Members'];
    final membersByUserId = _groupFamilyMembers(familyMembers);
    sheet.appendRow(_headers.map(xlsx.TextCellValue.new).toList());

    final headerStyle = xlsx.CellStyle(
      backgroundColorHex: xlsx.ExcelColor.fromHexString('FF0B5D46'),
      fontColorHex: xlsx.ExcelColor.white,
      fontSize: 11,
      bold: true,
      horizontalAlign: xlsx.HorizontalAlign.Left,
      verticalAlign: xlsx.VerticalAlign.Center,
      textWrapping: xlsx.TextWrapping.WrapText,
      bottomBorder: xlsx.Border(
        borderStyle: xlsx.BorderStyle.Medium,
        borderColorHex: xlsx.ExcelColor.fromHexString('FF084C3A'),
      ),
    );
    final border = xlsx.Border(
      borderStyle: xlsx.BorderStyle.Thin,
      borderColorHex: xlsx.ExcelColor.fromHexString('FFDCE5E1'),
    );

    for (var column = 0; column < _headers.length; column++) {
      sheet
          .cell(
            xlsx.CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 0),
          )
          .cellStyle = headerStyle;
    }
    sheet.setRowHeight(0, 30);

    for (var index = 0; index < _headers.length; index++) {
      sheet.setColumnWidth(index, [
        28.0,
        20.0,
        36.0,
        30.0,
        20.0,
        24.0,
      ][index]);
    }

    for (var profileIndex = 0;
        profileIndex < profiles.length;
        profileIndex++) {
      final profile = profiles[profileIndex];
      final householdMembers = membersByUserId[profile.id] ?? const [];
      final rowIndex = profileIndex + 1;
      sheet.appendRow([
        xlsx.TextCellValue(_name(profile)),
        xlsx.TextCellValue(_value(profile.phone)),
        xlsx.TextCellValue(_value(profile.address)),
        xlsx.TextCellValue(_value(profile.email)),
        xlsx.TextCellValue(_value(profile.username)),
        xlsx.IntCellValue(householdMembers.length + 1),
      ]);
      final rowStyle = xlsx.CellStyle(
        backgroundColorHex: profileIndex.isEven
            ? xlsx.ExcelColor.fromHexString('FFFFFFFF')
            : xlsx.ExcelColor.fromHexString('FFF2F7F5'),
        fontColorHex: xlsx.ExcelColor.fromHexString('FF26352F'),
        fontSize: 10,
        verticalAlign: xlsx.VerticalAlign.Center,
        textWrapping: xlsx.TextWrapping.WrapText,
        bottomBorder: border,
      );
      for (var column = 0; column < _headers.length; column++) {
        sheet
            .cell(
              xlsx.CellIndex.indexByColumnRow(
                columnIndex: column,
                rowIndex: rowIndex,
              ),
            )
            .cellStyle = rowStyle;
      }
      sheet.setRowHeight(rowIndex, 24);
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw StateError('Could not encode the members Excel workbook.');
    }
    return Uint8List.fromList(bytes);
  }

  static Future<Uint8List> generatePdf(
    List<ProfileModel> profiles,
    List<FamilyMemberModel> familyMembers,
  ) async {
    final pdf = pw.Document();
    final generatedAt = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final membersByUserId = _groupFamilyMembers(familyMembers);
    final rows = profiles.map((profile) {
      final householdMembers = membersByUserId[profile.id] ?? const [];
      return [
        _name(profile),
        _value(profile.phone),
        _value(profile.address),
        _value(profile.email),
        _value(profile.username),
        (householdMembers.length + 1).toString(),
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.green800, width: 1.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ANSAR FAMILY',
                      style: pw.TextStyle(
                        color: PdfColors.green900,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'MEMBER DIRECTORY',
                      style: pw.TextStyle(
                        color: PdfColors.grey700,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      '${profiles.length} members',
                      style: pw.TextStyle(
                        color: PdfColors.green900,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Generated $generatedAt',
                      style: const pw.TextStyle(
                        color: PdfColors.grey600,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Table.fromTextArray(
            headers: _headers,
            data: rows,
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green900),
            headerHeight: 30,
            cellStyle: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 7,
            ),
            cellHeight: 25,
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            border: pw.TableBorder(
              horizontalInside: const pw.BorderSide(
                color: PdfColors.grey300,
                width: 0.5,
              ),
              bottom: const pw.BorderSide(
                color: PdfColors.grey300,
                width: 0.5,
              ),
            ),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: const pw.BoxDecoration(
              color: PdfColors.grey100,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.6),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(2.4),
              3: const pw.FlexColumnWidth(2.0),
              4: const pw.FlexColumnWidth(1.4),
              5: const pw.FlexColumnWidth(1.0),
            },
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static String _name(ProfileModel profile) =>
      _value(profile.fullName ?? profile.username).isEmpty
      ? 'Community Member'
      : _value(profile.fullName ?? profile.username);

  static String _value(String? value) => value?.trim() ?? '';

  static Map<String, List<FamilyMemberModel>> _groupFamilyMembers(
    List<FamilyMemberModel> familyMembers,
  ) {
    final membersByUserId = <String, List<FamilyMemberModel>>{};
    for (final member in familyMembers) {
      membersByUserId.putIfAbsent(member.userId, () => []).add(member);
    }
    return membersByUserId;
  }
}
