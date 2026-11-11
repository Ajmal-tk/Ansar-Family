import 'dart:convert';

import 'package:ansar_family/models/fee_model.dart';
import 'package:ansar_family/services/pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FeeModel feeWithStatus(String status) => FeeModel(
    id: 'fee-123',
    userId: 'member-456',
    amount: 500,
    period: 'Monthly Members Fee - November 2026',
    status: status,
    paymentDate: DateTime.utc(2026, 11, 1),
    userName: 'Aisha Member',
  );

  test('generates a PDF receipt for paid fees', () async {
    final receipt = await PdfService.generateFeeReceipt(feeWithStatus('paid'));

    expect(utf8.decode(receipt.take(5).toList()), '%PDF-');
    expect(receipt, isNotEmpty);
  });

  test('does not generate receipts for unpaid fees', () async {
    await expectLater(
      PdfService.generateFeeReceipt(feeWithStatus('pending')),
      throwsArgumentError,
    );
  });
}
