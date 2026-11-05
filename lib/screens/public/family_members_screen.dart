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
  bool _isAddingMember = false;
  bool _isSaving = false;
  String _selectedRelation = 'Spouse';
  String? _selectedGender;
  String? _selectedEducation;
  String? _selectedWorkStatus;
  String? _selectedMaritalStatus;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _specifiedRelationController = TextEditingController();

  static const _relationOptions = [
    'Spouse',
    'Child',
    'Parent',
    'Sibling',
    'Other',
  ];
  static const _genderOptions = ['Male', 'Female', 'Prefer not to say'];
  static const _educationOptions = [
    'School',
    'College / University',
    'Vocational / Technical',
    'Not currently studying',
    'Other',
  ];
  static const _workStatusOptions = [
    'Student',
    'Employed',
    'Gulf Employed',
    'Self-employed',
    'Unemployed',
    'Other',
  ];
  static const _maritalStatusOptions = [
    'Single',
    'Married',
    'Prefer not to say',
  ];

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
    if (!mounted) return;
    setState(() {
      _members = list;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _specifiedRelationController.dispose();
    super.dispose();
  }

  void _resetAddForm() {
    _nameController.clear();
    _ageController.clear();
    _specifiedRelationController.clear();
    setState(() {
      _isAddingMember = false;
      _selectedRelation = 'Spouse';
      _selectedGender = null;
      _selectedEducation = null;
      _selectedWorkStatus = null;
      _selectedMaritalStatus = null;
    });
  }

  Future<void> _saveFamilyMember() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the household member name.'),
        ),
      );
      return;
    }

    final specifiedRelation = _specifiedRelationController.text.trim();
    final relation =
        _selectedRelation == 'Other' && specifiedRelation.isNotEmpty
        ? 'Other - $specifiedRelation'
        : _selectedRelation;

    setState(() => _isSaving = true);
    final saved = await SupabaseService.instance.addFamilyMember(
      name: name,
      relation: relation,
      age: int.tryParse(_ageController.text.trim()),
      gender: _selectedGender,
      education: _selectedEducation,
      workStatus: _selectedWorkStatus,
      maritalStatus: _selectedMaritalStatus,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save this household member. Check the database schema and try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _resetAddForm();
    await _loadData();
  }

  Widget _buildOptionalDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      hint: Text(hint),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAddMemberForm() {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Register New Household Member',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          const Text(
            'Member details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 4),
          const Text(
            'Fields marked optional can be left blank.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final fieldWidth = constraints.maxWidth > 700
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;

              Widget field(Widget child) =>
                  SizedBox(width: fieldWidth, child: child);

              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  field(
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                  ),
                  field(
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age'),
                    ),
                  ),
                  field(
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRelation,
                      decoration: const InputDecoration(labelText: 'Relation'),
                      items: _relationOptions
                          .map(
                            (relation) => DropdownMenuItem(
                              value: relation,
                              child: Text(relation),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRelation = value);
                        }
                      },
                    ),
                  ),
                  if (_selectedRelation == 'Other')
                    field(
                      TextField(
                        controller: _specifiedRelationController,
                        decoration: const InputDecoration(
                          labelText: 'Specify Relation (optional)',
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const Divider(height: 32),
          const Text(
            'Additional details (optional)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 4),
          const Text(
            'These details help us understand education, work and family needs.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final fieldWidth = constraints.maxWidth > 700
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: fieldWidth,
                    child: _buildOptionalDropdown(
                      label: 'Gender (optional)',
                      hint: 'Select gender',
                      value: _selectedGender,
                      options: _genderOptions,
                      onChanged: (value) =>
                          setState(() => _selectedGender = value),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _buildOptionalDropdown(
                      label: 'Education (optional)',
                      hint: 'Select education',
                      value: _selectedEducation,
                      options: _educationOptions,
                      onChanged: (value) =>
                          setState(() => _selectedEducation = value),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _buildOptionalDropdown(
                      label: 'Work status (optional)',
                      hint: 'Select work status',
                      value: _selectedWorkStatus,
                      options: _workStatusOptions,
                      onChanged: (value) =>
                          setState(() => _selectedWorkStatus = value),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _buildOptionalDropdown(
                      label: 'Marital status (optional)',
                      hint: 'Select marital status',
                      value: _selectedMaritalStatus,
                      options: _maritalStatusOptions,
                      onChanged: (value) =>
                          setState(() => _selectedMaritalStatus = value),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveFamilyMember,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSaving ? 'Saving...' : 'Save Member'),
              ),
              TextButton(
                onPressed: _isSaving ? null : _resetAddForm,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Members Directory')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving
            ? null
            : _isAddingMember
            ? _resetAddForm
            : () => setState(() => _isAddingMember = true),
        backgroundColor: AppTheme.primaryEmerald,
        icon: Icon(_isAddingMember ? Icons.close : Icons.add),
        label: Text(_isAddingMember ? 'Close Form' : 'Add Member'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isAddingMember) ...[
                        _buildAddMemberForm(),
                        const SizedBox(height: 20),
                      ],
                      if (_members.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Text(
                              'No family members registered yet.',
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                          ),
                        )
                      else
                        ..._members.map((item) {
                          final additionalDetails = [
                            if (item.gender != null) 'Gender: ${item.gender}',
                            if (item.education != null)
                              'Education: ${item.education}',
                            if (item.workStatus != null)
                              'Work: ${item.workStatus}',
                            if (item.maritalStatus != null)
                              'Marital status: ${item.maritalStatus}',
                          ];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CustomCard(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.primaryTeal
                                        .withValues(alpha: 0.1),
                                    child: const Icon(
                                      Icons.person,
                                      color: AppTheme.primaryTeal,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: AppTheme.textMuted,
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (additionalDetails.isNotEmpty)
                                          Text(
                                            additionalDetails.join('  •  '),
                                            style: const TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 13,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await SupabaseService.instance
                                          .deleteFamilyMember(item.id);
                                      _loadData();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
