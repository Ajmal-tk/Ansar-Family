import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/profile_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';
import '../management/fee_management_screen.dart';
import '../management/member_approvals_screen.dart';
import '../management/reports_screen.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  List<ProfileModel> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final list = await SupabaseService.instance.fetchAllProfiles();
    setState(() {
      _profiles = list;
      _isLoading = false;
    });
  }

  void _changeRole(String userId, String newRole) async {
    await SupabaseService.instance.updateProfileRole(userId, newRole);
    _loadProfiles();
  }

  void _changeStatus(String userId, String newStatus) async {
    await SupabaseService.instance.updateProfileStatus(userId, newStatus);
    _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin System Panel'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProfiles),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCard(
                    color: Colors.purple.shade700,
                    child: const Row(
                      children: [
                        Icon(Icons.admin_panel_settings,
                            color: Colors.white, size: 32),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Role-Based Access Control (RBAC) & Database Management',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Assign system roles (Admin, Management, Member) and update user approval states.',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ADMIN & MANAGEMENT OPTIONS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2,
                    children: [
                      _buildAdminActionCard(
                        title: '1-Click Approvals',
                        description:
                            'Approve or reject new member applications.',
                        icon: Icons.how_to_reg,
                        color: AppTheme.primaryEmerald,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MemberApprovalsScreen(),
                          ),
                        ),
                      ),
                      _buildAdminActionCard(
                        title: 'Member Fees & Status',
                        description:
                            'Enter fees for approved members and track pending or paid status.',
                        icon: Icons.receipt_long,
                        color: AppTheme.secondaryGold,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeeManagementScreen(),
                          ),
                        ),
                      ),
                      _buildAdminActionCard(
                        title: 'PDF Report Generator',
                        description:
                            'Generate financial summaries and membership certificates.',
                        icon: Icons.picture_as_pdf,
                        color: AppTheme.primaryTeal,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SYSTEM PROFILES & ROLES DIRECTORY',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _profiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final item = _profiles[i];
                      return CustomCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.purple.shade50,
                                  child: Text(
                                    (item.fullName != null &&
                                            item.fullName!.isNotEmpty)
                                        ? item.fullName![0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.fullName ??
                                            item.username ??
                                            'User',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        'ID: ${item.id.substring(0, 8)}...  •  Phone: ${item.phone ?? "N/A"}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: item.role, isRole: true),
                                const SizedBox(width: 6),
                                StatusBadge(status: item.status),
                              ],
                            ),
                            const Divider(height: 20),

                            // Role & Status Dropdown Selectors
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('Role: ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    DropdownButton<String>(
                                      value: item.role,
                                      isDense: true,
                                      underline: const SizedBox(),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'member',
                                            child: Text('Member')),
                                        DropdownMenuItem(
                                            value: 'management',
                                            child: Text('Management')),
                                        DropdownMenuItem(
                                            value: 'admin',
                                            child: Text('Admin')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null)
                                          _changeRole(item.id, val);
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Status: ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    DropdownButton<String>(
                                      value: item.status,
                                      isDense: true,
                                      underline: const SizedBox(),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'pending',
                                            child: Text('Pending')),
                                        DropdownMenuItem(
                                            value: 'approved',
                                            child: Text('Approved')),
                                        DropdownMenuItem(
                                            value: 'rejected',
                                            child: Text('Rejected')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null)
                                          _changeStatus(item.id, val);
                                      },
                                    ),
                                  ],
                                ),
                              ],
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

  Widget _buildAdminActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
