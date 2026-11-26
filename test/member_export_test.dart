import 'package:ansar_family/models/family_member_model.dart';
import 'package:ansar_family/models/profile_model.dart';
import 'package:ansar_family/services/member_export_service.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Excel export includes only directory details and household totals', () {
    final profile = ProfileModel(
      id: 'user-1',
      fullName: 'Aisha Ansari',
      username: 'aisha',
      phone: '1234567890',
      place: 'Alanallur',
      address: 'Main Road',
      email: 'aisha@example.com',
      role: 'admin',
      status: 'approved',
    );
    final familyMembers = [
      FamilyMemberModel(
        id: 'family-1',
        userId: 'user-1',
        name: 'Sara Ansari',
        relation: 'Child',
        age: 12,
        createdAt: DateTime(2026),
      ),
      FamilyMemberModel(
        id: 'family-2',
        userId: 'user-1',
        name: 'Omar Ansari',
        relation: 'Spouse',
        createdAt: DateTime(2026),
      ),
    ];

    final otherProfile = ProfileModel(id: 'user-2', fullName: 'Omar Ansari');
    final bytes = MemberExportService.generateExcel([
      profile,
      otherProfile,
    ], familyMembers);
    final workbook = Excel.decodeBytes(bytes);
    final rows = workbook.tables.values.single.rows;

    expect(rows.first.map((cell) => cell?.value.toString()), contains('Name'));
    expect(
      rows.first.map((cell) => cell?.value.toString()),
      contains('Total Household Members'),
    );
    final headers = rows.first.map((cell) => cell?.value.toString()).toList();
    expect(headers, [
      'Name',
      'Mobile Number',
      'Address',
      'Email',
      'Username',
      'Total Household Members',
    ]);
    expect(headers, isNot(contains('Place')));
    expect(headers, isNot(contains('Role')));
    expect(headers, isNot(contains('Status')));
    expect(headers, isNot(contains('Family Member Details')));
    expect(rows.every((row) => row.length == 6), isTrue);
    expect(rows.first.first?.cellStyle?.isBold, isTrue);
    expect(rows[1][0]?.value.toString(), 'Aisha Ansari');
    expect(rows[1][1]?.value.toString(), '1234567890');
    expect(rows[1][2]?.value.toString(), 'Main Road');
    expect(rows[1][3]?.value.toString(), 'aisha@example.com');
    expect(rows[1][4]?.value.toString(), 'aisha');
    expect(rows[1][5]?.value.toString(), '3');
    expect(rows[2][5]?.value.toString(), '1');
  });

  test('PDF export returns a PDF document', () async {
    final bytes = await MemberExportService.generatePdf([
      ProfileModel(
        id: 'user-1',
        fullName: 'Aisha Ansari',
        phone: '1234567890',
        address: 'Main Road',
      ),
    ], []);

    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
