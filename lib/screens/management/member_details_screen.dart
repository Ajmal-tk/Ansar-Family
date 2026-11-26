import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/family_member_model.dart';
import '../../models/profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';

class MemberDetailsScreen extends StatefulWidget {
  final ProfileModel member;

  const MemberDetailsScreen({super.key, required this.member});

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  List<FamilyMemberModel> _familyMembers = [];
  bool _isLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final members = await SupabaseService.instance.fetchFamilyMembers(
        widget.member.id,
      );
      if (!mounted) return;
      setState(() {
        _familyMembers = members;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Widget _detailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppTheme.primaryTeal),
          const SizedBox(width: 12),
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.trim().isNotEmpty == true ? value! : 'Not provided',
              style: const TextStyle(color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMember(FamilyMemberModel member) {
    final details = <String>[
      'Relation: ${member.relation ?? "Not provided"}',
      'Age: ${member.age?.toString() ?? "Not provided"}',
      'Gender: ${member.gender ?? "Not provided"}',
      'Education: ${member.education ?? "Not provided"}',
      'Work status: ${member.workStatus ?? "Not provided"}',
      'Marital status: ${member.maritalStatus ?? "Not provided"}',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppTheme.primaryTeal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...details.map(
                    (detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        detail,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Registered ${DateFormat.yMMMd().format(member.createdAt)}',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canViewMemberDetails = context.watch<AuthProvider>().isManagement;
    final name =
        widget.member.fullName ?? widget.member.username ?? 'Community Member';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Details'),
        actions: [
          if (canViewMemberDetails)
            IconButton(
              tooltip: 'Refresh family details',
              onPressed: _isLoading ? null : _loadFamilyMembers,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: !canViewMemberDetails
          ? const Center(
              child: Text('You do not have permission to view this page.'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                StatusBadge(
                                  status: widget.member.role,
                                  isRole: true,
                                ),
                                StatusBadge(status: widget.member.status),
                              ],
                            ),
                            const Divider(height: 28),
                            _detailRow(
                              Icons.person_outline,
                              'Full name',
                              widget.member.fullName,
                            ),
                            _detailRow(
                              Icons.alternate_email,
                              'Username',
                              widget.member.username,
                            ),
                            _detailRow(
                              Icons.email_outlined,
                              'Email',
                              widget.member.email,
                            ),
                            _detailRow(
                              Icons.phone_outlined,
                              'Phone',
                              widget.member.phone,
                            ),
                            _detailRow(
                              Icons.location_city_outlined,
                              'Place',
                              widget.member.place,
                            ),
                            _detailRow(
                              Icons.location_on_outlined,
                              'Address',
                              widget.member.address,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Family Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_loadError != null)
                        CustomCard(
                          child: Column(
                            children: [
                              const Text(
                                'Could not load this member’s family details.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _loadFamilyMembers,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try again'),
                              ),
                            ],
                          ),
                        )
                      else if (_familyMembers.isEmpty)
                        const CustomCard(
                          child: Text(
                            'No family details have been registered for this member.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ..._familyMembers.map(_buildFamilyMember),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
