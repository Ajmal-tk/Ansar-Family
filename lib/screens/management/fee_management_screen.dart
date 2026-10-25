import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../config/app_theme.dart';
import '../../models/fee_model.dart';
import '../../models/profile_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';

class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
  List<FeeModel> _allFees = [];
  List<ProfileModel> _allProfiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final fees = await SupabaseService.instance.fetchAllFees();
    final profiles = await SupabaseService.instance.fetchAllProfiles();
    if (!mounted) return;
    setState(() {
      _allFees = fees;
      _allProfiles = profiles
          .where((profile) => profile.role == 'member' && profile.isApproved)
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _showAddManualFeeDialog() async {
    final amountController = TextEditingController();
    final periodController = TextEditingController(text: '2026-Q1');
    ProfileModel? selectedMember =
        _allProfiles.isNotEmpty ? _allProfiles.first : null;
    String selectedStatus = 'pending';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Enter Member Fee Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_allProfiles.isEmpty)
                  const Text('No approved members are available.')
                else
                  DropdownButtonFormField<ProfileModel>(
                    initialValue: selectedMember,
                    decoration: const InputDecoration(
                        labelText: 'Select Approved Member'),
                    items: _allProfiles
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.fullName ?? p.username ?? 'Member'),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedMember = val),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount (INR)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: periodController,
                  decoration: const InputDecoration(
                      labelText: 'Period / Note (e.g. 2026-Q1)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Fee Status'),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'paid', child: Text('Paid')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedStatus = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedMember == null
                  ? null
                  : () async {
                      final amount = double.tryParse(amountController.text);
                      if (amount == null || !amount.isFinite || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Enter a valid amount greater than zero.')),
                        );
                        return;
                      }
                      final fee = FeeModel(
                        id: const Uuid().v4(),
                        userId: selectedMember!.id,
                        amount: amount,
                        currency: 'INR',
                        period: periodController.text.trim(),
                        status: selectedStatus,
                        paymentDate: DateTime.now(),
                        createdBy: SupabaseService.instance.currentUserId,
                        userName: selectedMember!.fullName,
                      );
                      final saved =
                          await SupabaseService.instance.recordFee(fee);
                      if (!saved) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Unable to save the fee entry.')),
                          );
                        }
                        return;
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadData();
                    },
              child: const Text('Save Fee Details'),
            ),
          ],
        ),
      ),
    );
    amountController.dispose();
    periodController.dispose();
  }

  Future<void> _markFeePaid(FeeModel fee) async {
    final updated = await SupabaseService.instance.updateFeeStatus(
      fee.id,
      'paid',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated ? 'Fee marked as paid.' : 'Unable to update the fee status.',
        ),
      ),
    );
    if (updated) await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final totalsByCurrency = <String, double>{};
    for (final fee in _allFees.where((fee) => fee.status == 'paid')) {
      totalsByCurrency.update(
        fee.currency,
        (total) => total + fee.amount,
        ifAbsent: () => fee.amount,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Transactions & Fees'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _allProfiles.isEmpty ? null : _showAddManualFeeDialog,
        backgroundColor: AppTheme.secondaryGold,
        icon: const Icon(Icons.add),
        label: const Text('Enter Member Fee'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Card
                  CustomCard(
                    color: AppTheme.primaryEmerald,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Community Revenue Collected',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Membership Fees & Charity',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          totalsByCurrency.isEmpty
                              ? 'No payments yet'
                              : totalsByCurrency.entries
                                  .map((entry) =>
                                      '${entry.key} ${entry.value.toStringAsFixed(2)}')
                                  .join('  •  '),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'ALL FINANCIAL ENTRIES',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 12),

                  _allFees.isEmpty
                      ? const Text('No financial entries recorded.')
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _allFees.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final item = _allFees[i];
                            return CustomCard(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.secondaryGold
                                        .withValues(alpha: 0.15),
                                    child: const Icon(Icons.attach_money,
                                        color: AppTheme.secondaryGold),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.userName ??
                                              item.userId.substring(0, 8),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          'Period: ${item.period ?? "N/A"}  •  ${item.status == 'paid' ? 'Paid on' : 'Recorded'}: ${dateFormat.format(item.paymentDate)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${item.currency} ${item.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.primaryEmerald,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  StatusBadge(status: item.status),
                                  if (item.status == 'pending')
                                    IconButton(
                                      tooltip: 'Mark as paid',
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        color: AppTheme.primaryEmerald,
                                      ),
                                      onPressed: () => _markFeePaid(item),
                                    ),
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
