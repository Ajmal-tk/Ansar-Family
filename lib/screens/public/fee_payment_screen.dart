import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/fee_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';

class FeePaymentScreen extends StatefulWidget {
  const FeePaymentScreen({super.key});

  @override
  State<FeePaymentScreen> createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  double _amount = 500.0;
  String _selectedPeriod = '2026-Q1';
  PaymentMethod _paymentMethod = PaymentMethod.sandboxCreditCard;

  bool _isProcessing = false;
  PaymentResult? _lastResult;
  List<FeeModel> _myFees = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uId =
        auth.currentProfile?.id ?? SupabaseService.instance.currentUserId;
    final list = await SupabaseService.instance.fetchUserFees(uId);
    setState(() {
      _myFees = list;
      _isLoadingHistory = false;
    });
  }

  void _executePayment() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uId =
        auth.currentProfile?.id ?? SupabaseService.instance.currentUserId;

    setState(() {
      _isProcessing = true;
      _lastResult = null;
    });

    final gateway = SandboxPaymentGateway();
    final result = await gateway.processPayment(
      userId: uId,
      amount: _amount,
      currency: 'INR',
      period: _selectedPeriod,
      method: _paymentMethod,
    );

    setState(() {
      _isProcessing = false;
      _lastResult = result;
    });

    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Fees & Sadaqah Fund'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Form Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.volunteer_activism,
                          color: AppTheme.secondaryGold),
                      SizedBox(width: 8),
                      Text(
                        'Mahallu Fund - Zero-Cost Sandbox Checkout',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'No actual real-world funds will be charged. All sandbox operations run fee-free for testing.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const Divider(height: 24),

                  // Preset Amount Selection
                  const Text('Select Contribution Type:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        label: const Text('₹500 - Q1 Mahallu Fee'),
                        selected:
                            _amount == 500.0 && _selectedPeriod == '2026-Q1',
                        onSelected: (selected) {
                          if (selected)
                            setState(() {
                              _amount = 500.0;
                              _selectedPeriod = '2026-Q1';
                            });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('₹2,000 - Annual Mahallu Fee'),
                        selected: _amount == 2000.0 &&
                            _selectedPeriod == '2026-Annual',
                        onSelected: (selected) {
                          if (selected)
                            setState(() {
                              _amount = 2000.0;
                              _selectedPeriod = '2026-Annual';
                            });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('₹250 - General Sadaqah / Zakat'),
                        selected:
                            _amount == 250.0 && _selectedPeriod == 'Sadaqah',
                        onSelected: (selected) {
                          if (selected)
                            setState(() {
                              _amount = 250.0;
                              _selectedPeriod = 'Sadaqah';
                            });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment Method Selection
                  const Text('Payment Gateway Method:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  RadioListTile<PaymentMethod>(
                    value: PaymentMethod.sandboxCreditCard,
                    groupValue: _paymentMethod,
                    title: const Text('UPI / Sandbox Test Card (Instant)'),
                    subtitle:
                        const Text('Simulates instant payment authorization'),
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                  ),
                  RadioListTile<PaymentMethod>(
                    value: PaymentMethod.manualBankTransfer,
                    groupValue: _paymentMethod,
                    title: const Text('Manual Bank Wire / Offline Log'),
                    subtitle:
                        const Text('Record direct offline bank transaction'),
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                  ),
                  const SizedBox(height: 16),

                  // Execute Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _executePayment,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_open),
                      label: Text(
                        _isProcessing
                            ? 'Processing...'
                            : 'Pay ₹${_amount.toStringAsFixed(0)} INR (Sandbox)',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryEmerald,
                      ),
                    ),
                  ),

                  // Result Feedback Banner
                  if (_lastResult != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _lastResult!.isSuccess
                            ? AppTheme.accentMint.withValues(alpha: 0.15)
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _lastResult!.isSuccess
                              ? AppTheme.accentMint
                              : Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _lastResult!.isSuccess
                                ? Icons.check_circle
                                : Icons.error,
                            color: _lastResult!.isSuccess
                                ? AppTheme.primaryEmerald
                                : Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _lastResult!.message,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _lastResult!.isSuccess
                                        ? AppTheme.primaryEmerald
                                        : Colors.red,
                                  ),
                                ),
                                Text(
                                  'Ref ID: ${_lastResult!.transactionId}',
                                  style: const TextStyle(
                                      fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'YOUR PAYMENT TRANSACTION HISTORY',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),

            _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : _myFees.isEmpty
                    ? const Text('No fee records found.')
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _myFees.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final f = _myFees[i];
                          return CustomCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentMint
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.receipt,
                                      color: AppTheme.primaryEmerald),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${f.period ?? "Payment"} • \$${f.amount.toStringAsFixed(2)} ${f.currency}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Text(
                                        dateFormat.format(f.paymentDate),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: f.status),
                              ],
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
