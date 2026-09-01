import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/profile_model.dart';
import '../../models/fee_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_card.dart';
import 'member_approvals_screen.dart';
import 'fee_management_screen.dart';
import 'reports_screen.dart';

class ManagementDashboard extends StatefulWidget {
  const ManagementDashboard({super.key});

  @override
  State<ManagementDashboard> createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard> {
  int _totalMembers = 0;
  int _pendingCount = 0;
  double _totalFeesCollected = 0.0;
  int _postsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final profiles = await SupabaseService.instance.fetchAllProfiles();
    final fees = await SupabaseService.instance.fetchAllFees();
    final posts = await SupabaseService.instance.fetchPosts();

    final pending = profiles.where((p) => p.status == 'pending').length;
    final totalFees = fees
        .where((f) => f.status == 'paid')
        .fold<double>(0, (sum, item) => sum + item.amount);

    setState(() {
      _totalMembers = profiles.length;
      _pendingCount = pending;
      _totalFeesCollected = totalFees;
      _postsCount = posts.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMetrics,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  // Dashboard Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAlignment.start,
                        children: [
                          const Text(
                            'Executive Management Overview',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryEmerald,
                            ),
                          ),
                          Text(
                            'Logged in as ${auth.currentProfile?.fullName ?? "Manager"} (${auth.currentProfile?.role.toUpperCase()})',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Required Alert Banner if Pending Applications
                  if (_pendingCount > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.statusPending.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.statusPending),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active, color: Color(0xFFB45309), size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAlignment.start,
                              children: [
                                Text(
                                  '$_pendingCount Pending Membership Application(s)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                                const Text(
                                  'Review and approve user requests with 1-click controls.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MemberApprovalsScreen()),
                              ).then((_) => _loadMetrics());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryGold,
                            ),
                            child: const Text('Review Now'),
                          ),
                        ],
                      ),
                    ),

                  // KPI Cards
                  GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.5,
                    children: [
                      _buildKpiCard(
                        title: 'Total Members',
                        value: '$_totalMembers',
                        icon: Icons.people,
                        color: AppTheme.primaryEmerald,
                      ),
                      _buildKpiCard(
                        title: 'Pending Requests',
                        value: '$_pendingCount',
                        icon: Icons.pending_actions,
                        color: AppTheme.statusPending,
                      ),
                      _buildKpiCard(
                        title: 'Total Fees Collected',
                        value: '\$${_totalFeesCollected.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: AppTheme.accentMint,
                      ),
                      _buildKpiCard(
                        title: 'Posts & Requests',
                        value: '$_postsCount',
                        icon: Icons.article_outlined,
                        color: AppTheme.primaryTeal,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'MANAGEMENT MODULES',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Modules Grid
                  GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.0,
                    children: [
                      CustomCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MemberApprovalsScreen()),
                          ).then((_) => _loadMetrics());
                        },
                        child: Column(
                          crossAxisAlignment: CrossAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryEmerald.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.how_to_reg, color: AppTheme.primaryEmerald),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '1-Click Approvals',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Approve or reject new member applications instantly.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),

                      CustomCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FeeManagementScreen()),
                          ).then((_) => _loadMetrics());
                        },
                        child: Column(
                          crossAxisAlignment: CrossAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryGold.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.receipt_long, color: AppTheme.secondaryGold),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Financial Receipts',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Track membership fees, donations, and record manual entries.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),

                      CustomCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReportsScreen()),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryTeal),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'PDF Report Generator',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Export printable financial summaries & membership certificates.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
