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
    setState(() {
      _allFees = fees;
      _allProfiles = profiles;
      _isLoading = false;
    });
  }

  void _showAddManualFeeDialog() {
    final amountController = TextEditingController(text: '50.0');
    final periodController = TextEditingController(text: '2026-Q1');
    ProfileModel? selectedMember = _allProfiles.isNotEmpty ? _allProfiles.first : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Record Manual Fee / Donation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ProfileModel>(
                  value: selectedMember,
                  decoration: const InputDecoration(labelText: 'Select Member'),
                  items: _allProfiles
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.fullName ?? p.username ?? 'Member'),
                          ))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedMember = val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (USD)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: periodController,
                  decoration: const InputDecoration(labelText: 'Period / Note (e.g. 2026-Q1)'),
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
              onPressed: () async {
                if (selectedMember != null) {
                  final amount = double.tryParse(amountController.text) ?? 50.0;
                  final fee = FeeModel(
                    id: const Uuid().v4(),
                    userId: selectedMember!.id,
                    amount: amount,
                    currency: 'USD',
                    period: periodController.text.trim(),
                    status: 'paid',
                    paymentDate: DateTime.now(),
                    createdBy: SupabaseService.instance.currentUserId,
                    userName: selectedMember!.fullName,
                  );
                  await SupabaseService.instance.recordFee(fee);
                  Navigator.pop(ctx);
                  _loadData();
                }
              },
              child: const Text('Record Entry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final totalCollected = _allFees
        .where((f) => f.status == 'paid')
        .fold<double>(0, (sum, f) => sum + f.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Transactions & Fees'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddManualFeeDialog,
        backgroundColor: AppTheme.secondaryGold,
        icon: const Icon(Icons.add),
        label: const Text('Record Manual Entry'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  // Total Card
                  CustomCard(
                    color: AppTheme.primaryEmerald,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAlignment.start,
                          children: [
                            Text(
                              'Total Community Revenue Collected',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Membership Fees & Charity',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          '\$${totalCollected.toStringAsFixed(2)} USD',
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 12),

                  _allFees.isEmpty
                      ? const Text('No financial entries recorded.')
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _allFees.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final item = _allFees[i];
                            return CustomCard(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.secondaryGold.withOpacity(0.15),
                                    child: const Icon(Icons.attach_money, color: AppTheme.secondaryGold),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAlignment.start,
                                      children: [
                                        Text(
                                          item.userName ?? item.userId.substring(0, 8),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        Text(
                                          'Period: ${item.period ?? "N/A"}  •  Date: ${dateFormat.format(item.paymentDate)}',
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${item.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.primaryEmerald,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  StatusBadge(status: item.status),
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
