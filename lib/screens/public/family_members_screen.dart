import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/family_member_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_card.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  List<FamilyMemberModel> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uId =
        auth.currentProfile?.id ?? SupabaseService.instance.currentUserId;
    final list = await SupabaseService.instance.fetchFamilyMembers(uId);
    setState(() {
      _members = list;
      _isLoading = false;
    });
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String selectedRelation = 'Spouse';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Family Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRelation,
                  decoration: const InputDecoration(labelText: 'Relation'),
                  items: ['Spouse', 'Child', 'Parent', 'Sibling', 'Other']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null)
                      setDialogState(() => selectedRelation = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age'),
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
                if (nameController.text.trim().isNotEmpty) {
                  final age = int.tryParse(ageController.text.trim()) ?? 0;
                  await SupabaseService.instance.addFamilyMember(
                    name: nameController.text.trim(),
                    relation: selectedRelation,
                    age: age,
                  );
                  Navigator.pop(ctx);
                  _loadData();
                }
              },
              child: const Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Members Directory'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.primaryEmerald,
        icon: const Icon(Icons.add),
        label: const Text('Add Member'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.family_restroom,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No family members registered yet.',
                        style:
                            TextStyle(color: AppTheme.textMuted, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Register Dependent'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final item = _members[i];
                    return CustomCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppTheme.primaryTeal.withValues(alpha: 0.1),
                            child: const Icon(Icons.person,
                                color: AppTheme.primaryTeal),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Relation: ${item.relation ?? "N/A"}  •  Age: ${item.age ?? "N/A"}',
                                  style: const TextStyle(
                                      color: AppTheme.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () async {
                              await SupabaseService.instance
                                  .deleteFamilyMember(item.id);
                              _loadData();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
