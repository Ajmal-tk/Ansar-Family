import 'package:uuid/uuid.dart';

import '../models/fee_model.dart';
import 'supabase_service.dart';

enum PaymentMethod {
  sandboxCreditCard,
  manualBankTransfer,
  digitalWalletMock,
}

class PaymentResult {
  final bool isSuccess;
  final String transactionId;
  final String message;
  final FeeModel? feeRecord;

  PaymentResult({
    required this.isSuccess,
    required this.transactionId,
    required this.message,
    this.feeRecord,
  });
}

abstract class IPaymentGateway {
  Future<PaymentResult> processPayment({
    required String userId,
    required double amount,
    required String currency,
    required String period,
    required PaymentMethod method,
    String? note,
  });
}

/// Zero-cost Mock & Sandbox Payment Gateway Implementation
class SandboxPaymentGateway implements IPaymentGateway {
  @override
  Future<PaymentResult> processPayment({
    required String userId,
    required double amount,
    required String currency,
    required String period,
    required PaymentMethod method,
    String? note,
  }) async {
    // Simulate network delay for zero-cost sandbox checkout
    await Future.delayed(const Duration(milliseconds: 1200));

    final txId = 'TX-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    final feeRecord = FeeModel(
      id: const Uuid().v4(),
      userId: userId,
      amount: amount,
      currency: currency,
      period: period,
      status: 'paid',
      paymentDate: DateTime.now(),
      createdBy: userId,
    );

    // Log transaction into database via SupabaseService
    final success = await SupabaseService.instance.recordFee(feeRecord);

    if (success) {
      return PaymentResult(
        isSuccess: true,
        transactionId: txId,
        message: 'Sandbox Transaction Successful! No real funds were charged.',
        feeRecord: feeRecord,
      );
    } else {
      return PaymentResult(
        isSuccess: false,
        transactionId: txId,
        message: 'Failed to record transaction in database.',
      );
    }
  }
}
