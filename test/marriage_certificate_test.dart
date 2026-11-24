import 'dart:convert';

import 'package:ansar_family/models/marriage_registration_model.dart';
import 'package:ansar_family/services/pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final registration = MarriageRegistrationModel(
    id: 'marriage-123',
    groomName: 'Groom Name',
    groomAddress: 'Groom Address',
    brideName: 'Bride Name',
    brideAddress: 'Bride Address',
    marriagePlace: 'Alanallur',
    venue: 'Trust Hall',
    marriageDate: DateTime(2026, 11, 24),
    registeredAt: DateTime(2026, 11, 24),
  );

  test('serializes marriage details for Supabase', () {
    expect(registration.toInsertJson(), {
      'groom_name': 'Groom Name',
      'groom_address': 'Groom Address',
      'bride_name': 'Bride Name',
      'bride_address': 'Bride Address',
      'marriage_place': 'Alanallur',
      'venue': 'Trust Hall',
      'marriage_date': '2026-11-24',
    });
  });

  test('generates a marriage certificate PDF', () async {
    final certificate =
        await PdfService.generateMarriageCertificate(registration);

    expect(utf8.decode(certificate.take(5).toList()), '%PDF-');
    expect(certificate, isNotEmpty);
  });
}
