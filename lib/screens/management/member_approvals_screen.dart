import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/profile_model.dart';
import '../../models/family_member_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';

class MemberApprovalsScreen extends StatefulWidget {
  const MemberApprovalsScreen({super.key});

  @override
  State<MemberApprovalsScreen> createState() => _MemberApprovalsScreenState();
}

class _MemberApprovalsScreenState extends State<MemberApprovalsScreen> {
  List<ProfileModel> _pendingProfiles = [];
  Map<String, List<FamilyMemberModel>> _familyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final list = await SupabaseService.instance.fetchPendingProfiles();
    final Map<String, List<FamilyMemberModel>> famMap = {};

    for (var p in list) {
      famMap[p.id] = await SupabaseService.instance.fetchFamilyMembers(p.id);
    }

    setState(() {
      _pendingProfiles = list;
      _familyData = famMap;
      _isLoading = false;
    });
  }

  void _updateStatus(String userId, String status) async {
    final success = await SupabaseService.instance.updateProfileStatus(userId, status);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member status updated to ${status.toUpperCase()}'),
          backgroundColor: status == 'approved' ? AppTheme.primaryEmerald : Colors.red,
        ),
      );
      _loadPending();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Applications & Approvals'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPending),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingProfiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.emerald.shade300),
                      const SizedBox(height: 12),
                      const Text(
                        'All caught up! No pending member applications.',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _pendingProfiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    final p = _pendingProfiles[i];
                    final familyList = _familyData[p.id] ?? [];

                    return CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.primaryEmerald.withOpacity(0.1),
                                child: Text(
                                  (p.fullName != null && p.fullName!.isNotEmpty)
                                      ? p.fullName![0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryEmerald,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAlignment.start,
                                  children: [
                                    Text(
                                      p.fullName ?? 'Applicant',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Phone: ${p.phone ?? "N/A"}  •  Address: ${p.address ?? "N/A"}',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(status: p.status),
                            ],
                          ),
                          
                          if (familyList.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAlignment.start,
                                children: [
                                  Text(
                                    'Registered Household (${familyList.length} Dependents):',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: familyList
                                        .map(
                                          (fm) => Chip(
                                            label: Text(
                                              '${fm.name} (${fm.relation}, age ${fm.age})',
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                            backgroundColor: Colors.white,
                                            padding: EdgeInsets.zero,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const Divider(height: 24),

                          // One-Click Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _updateStatus(p.id, 'rejected'),
                                icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                                label: const Text('Reject Application', style: TextStyle(color: Colors.red)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () => _updateStatus(p.id, 'approved'),
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: const Text('Approve Member'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryEmerald,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
