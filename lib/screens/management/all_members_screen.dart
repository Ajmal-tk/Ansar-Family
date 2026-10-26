import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';

class AllMembersScreen extends StatefulWidget {
  final String initialFilter;
  const AllMembersScreen({super.key, this.initialFilter = 'all'});

  @override
  State<AllMembersScreen> createState() => _AllMembersScreenState();
}

class _AllMembersScreenState extends State<AllMembersScreen> {
  List<ProfileModel> _allProfiles = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'approved', 'pending', 'rejected'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _loadProfiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    final list = await SupabaseService.instance.fetchAllProfiles();
    if (!mounted) return;
    setState(() {
      _allProfiles = list;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(String userId, String status) async {
    final success =
        await SupabaseService.instance.updateProfileStatus(userId, status);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member status updated to ${status.toUpperCase()}'),
          backgroundColor:
              status == 'approved' ? AppTheme.primaryEmerald : Colors.red,
        ),
      );
      await _loadProfiles();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update status. Check permissions.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changeRole(String userId, String newRole) async {
    final success =
        await SupabaseService.instance.updateProfileRole(userId, newRole);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role updated to ${newRole.toUpperCase()}'),
          backgroundColor: AppTheme.primaryEmerald,
        ),
      );
      await _loadProfiles();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update role. Check permissions.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRoleChangeDialog(ProfileModel item) {
    String selected = item.role;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text('Assign Role: ${item.fullName ?? item.username ?? "Member"}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select new system role:',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selected,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'member', child: Text('Member (Regular)')),
                  DropdownMenuItem(value: 'management', child: Text('Management (Committee)')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin (Full Access)')),
                ],
                onChanged: (val) {
                  if (val != null) setDlgState(() => selected = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _changeRole(item.id, selected);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryEmerald),
              child: const Text('Save Role'),
            ),
          ],
        ),
      ),
    );
  }

  List<ProfileModel> get _filteredProfiles {
    return _allProfiles.where((p) {
      // Filter by status
      if (_selectedFilter != 'all') {
        if (p.status.toLowerCase() != _selectedFilter) return false;
      }
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final name = (p.fullName ?? '').toLowerCase();
        final username = (p.username ?? '').toLowerCase();
        final phone = (p.phone ?? '').toLowerCase();
        final address = (p.address ?? '').toLowerCase();
        return name.contains(q) ||
            username.contains(q) ||
            phone.contains(q) ||
            address.contains(q);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.isAdmin;

    final allCount = _allProfiles.length;
    final approvedCount = _allProfiles.where((p) => p.isApproved).length;
    final pendingCount = _allProfiles.where((p) => p.isPending).length;
    final rejectedCount = _allProfiles.where((p) => p.isRejected).length;

    final displayList = _filteredProfiles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Members Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Box
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search members by name, phone, address...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All ($allCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('approved', 'Approved ($approvedCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('pending', 'Pending ($pendingCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('rejected', 'Rejected ($rejectedCount)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Directory List
                  if (displayList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No members found matching filter "$_selectedFilter".',
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final item = displayList[i];
                        final initial = (item.fullName != null &&
                                item.fullName!.isNotEmpty)
                            ? item.fullName![0].toUpperCase()
                            : 'M';

                        return CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: item.isAdmin
                                        ? Colors.purple.shade50
                                        : (item.role == 'management'
                                            ? Colors.teal.shade50
                                            : AppTheme.primaryEmerald
                                                .withValues(alpha: 0.1)),
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: item.isAdmin
                                            ? Colors.purple.shade800
                                            : (item.role == 'management'
                                                ? AppTheme.primaryTeal
                                                : AppTheme.primaryEmerald),
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
                                              'Community Member',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          '@${item.username ?? "user"} • Phone: ${item.phone ?? "N/A"}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                        if (item.address != null &&
                                            item.address!.isNotEmpty)
                                          Text(
                                            item.address!,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(status: item.role, isRole: true),
                                  const SizedBox(width: 6),
                                  StatusBadge(status: item.status),
                                ],
                              ),

                              // Quick Action Row for Admins / Managers
                              const Divider(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Status action for pending members
                                  if (item.isPending) ...[
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _updateStatus(item.id, 'approved'),
                                          icon: const Icon(Icons.check, size: 14),
                                          label: const Text('Approve',
                                              style: TextStyle(fontSize: 11)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.primaryEmerald,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              _updateStatus(item.id, 'rejected'),
                                          icon: const Icon(Icons.close, size: 14),
                                          label: const Text('Reject',
                                              style: TextStyle(fontSize: 11)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else if (item.isRejected) ...[
                                    TextButton.icon(
                                      onPressed: () =>
                                          _updateStatus(item.id, 'approved'),
                                      icon: const Icon(Icons.refresh, size: 14),
                                      label: const Text('Re-Approve',
                                          style: TextStyle(fontSize: 12)),
                                    ),
                                  ] else ...[
                                    const Text(
                                      'Active Approved Member',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.primaryEmerald,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],

                                  // Role change button (Admin only, especially for approved members)
                                  if (isAdmin && item.isApproved) ...[
                                    OutlinedButton.icon(
                                      onPressed: () => _showRoleChangeDialog(item),
                                      icon: const Icon(Icons.security, size: 14),
                                      label: const Text('Assign Role',
                                          style: TextStyle(fontSize: 11)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.purple.shade700,
                                        side: BorderSide(
                                            color: Colors.purple.shade300),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                      ),
                                    ),
                                  ],
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

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryEmerald,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textDark,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = filterKey);
      },
    );
  }
}
