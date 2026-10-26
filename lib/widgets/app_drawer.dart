import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/public/public_portal.dart';
import '../screens/public/family_members_screen.dart';
import '../screens/public/community_posts_screen.dart';
import '../screens/public/fee_payment_screen.dart';
import '../screens/management/management_dashboard.dart';
import '../screens/management/member_approvals_screen.dart';
import '../screens/management/all_members_screen.dart';
import '../screens/management/fee_management_screen.dart';
import '../screens/admin/admin_panel.dart';
import 'status_badge.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profile = auth.currentProfile;

    return Drawer(
      child: Column(
        children: [
          // Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryEmerald, AppTheme.primaryTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              profile?.fullName ?? 'Ansar Family Member',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(profile?.phone ??
                    profile?.address ??
                    'Local Muslim Community Platform'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StatusBadge(
                        status: profile?.role ?? 'member', isRole: true),
                    const SizedBox(width: 6),
                    StatusBadge(status: profile?.status ?? 'pending'),
                  ],
                ),
              ],
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (profile?.fullName != null && profile!.fullName!.isNotEmpty)
                    ? profile.fullName![0].toUpperCase()
                    : 'A',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryEmerald,
                ),
              ),
            ),
          ),

          // Main Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Public Portal Section
                ListTile(
                  leading:
                      const Icon(Icons.home, color: AppTheme.primaryEmerald),
                  title: const Text('Public Portal'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const PublicPortal()),
                    );
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.people, color: AppTheme.primaryTeal),
                  title: const Text('Family Members'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FamilyMembersScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.forum, color: AppTheme.primaryTeal),
                  title: const Text('Community Posts & Assistance'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CommunityPostsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.payments, color: AppTheme.secondaryGold),
                  title: const Text('Membership Fees & Donations'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FeePaymentScreen()),
                    );
                  },
                ),

                const Divider(),

                // Management & Admin Navigation (Shown if authorized)
                if (auth.isManagement) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                    child: Text(
                      'MANAGEMENT & ADMIN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard,
                        color: AppTheme.primaryEmerald),
                    title: const Text('Management Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ManagementDashboard()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.how_to_reg,
                        color: AppTheme.primaryTeal),
                    title: const Text('Pending Approvals Panel'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MemberApprovalsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people_alt,
                        color: AppTheme.primaryEmerald),
                    title: const Text('All Members Directory'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AllMembersScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long,
                        color: AppTheme.secondaryGold),
                    title: const Text('Financial Transactions Tracker'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FeeManagementScreen()),
                      );
                    },
                  ),
                ],

                if (auth.isAdmin) ...[
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings,
                        color: Colors.purple),
                    title: const Text('Admin System Panel'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminPanel()),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),

          // Logout
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await auth.signOut();
            },
          ),
        ],
      ),
    );
  }
}
