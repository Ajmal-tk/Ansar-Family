import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../models/marriage_registration_model.dart';
import '../../services/pdf_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/app_drawer.dart';

class MarriageRegistrationScreen extends StatefulWidget {
  const MarriageRegistrationScreen({super.key});

  @override
  State<MarriageRegistrationScreen> createState() =>
      _MarriageRegistrationScreenState();
}

class _MarriageRegistrationScreenState
    extends State<MarriageRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groomNameController = TextEditingController();
  final _groomAddressController = TextEditingController();
  final _brideNameController = TextEditingController();
  final _brideAddressController = TextEditingController();
  final _placeController = TextEditingController();
  final _venueController = TextEditingController();

  List<MarriageRegistrationModel> _registrations = [];
  DateTime? _marriageDate;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  @override
  void dispose() {
    _groomNameController.dispose();
    _groomAddressController.dispose();
    _brideNameController.dispose();
    _brideAddressController.dispose();
    _placeController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _loadRegistrations() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final registrations =
          await SupabaseService.instance.fetchMarriageRegistrations();
      if (!mounted) return;
      setState(() {
        _registrations = registrations;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load marriage registrations: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectMarriageDate(FormFieldState<DateTime> field) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _marriageDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (selectedDate != null) {
      setState(() => _marriageDate = selectedDate);
      field.didChange(selectedDate);
    }
  }

  Future<void> _registerMarriage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_marriageDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the marriage date.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final registration = MarriageRegistrationModel(
        id: '',
        groomName: _groomNameController.text.trim(),
        groomAddress: _groomAddressController.text.trim(),
        brideName: _brideNameController.text.trim(),
        brideAddress: _brideAddressController.text.trim(),
        marriagePlace: _placeController.text.trim(),
        venue: _venueController.text.trim(),
        marriageDate: _marriageDate!,
        registeredAt: DateTime.now(),
      );
      await SupabaseService.instance.createMarriageRegistration(registration);
      if (!mounted) return;
      _groomNameController.clear();
      _groomAddressController.clear();
      _brideNameController.clear();
      _brideAddressController.clear();
      _placeController.clear();
      _venueController.clear();
      setState(() => _marriageDate = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marriage registered successfully.')),
      );
      await _loadRegistrations();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not register marriage: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _downloadCertificate(
    MarriageRegistrationModel registration,
  ) async {
    try {
      final pdf = await PdfService.generateMarriageCertificate(registration);
      final filename =
          'marriage_certificate_${registration.groomName}_${registration.brideName}'
              .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      await PdfService.printOrDownloadPdf(pdf, '$filename.pdf');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create certificate: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marriage Registration'),
        actions: [
          IconButton(
            tooltip: 'Refresh registrations',
            icon: const Icon(Icons.refresh),
            onPressed: _loadRegistrations,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRegistrationForm(),
                const SizedBox(height: 28),
                _buildRegistrationList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Register a Marriage',
                style: TextStyle(
                  color: AppTheme.primaryEmerald,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('Groom details'),
              _buildResponsiveFields([
                _textField(_groomNameController, 'Groom name'),
                _textField(
                  _groomAddressController,
                  'Groom address',
                  maxLines: 2,
                ),
              ]),
              const SizedBox(height: 16),
              _buildSectionTitle('Bride details'),
              _buildResponsiveFields([
                _textField(_brideNameController, 'Bride name'),
                _textField(
                  _brideAddressController,
                  'Bride address',
                  maxLines: 2,
                ),
              ]),
              const SizedBox(height: 16),
              _buildSectionTitle('Marriage details'),
              _buildResponsiveFields([
                _textField(_placeController, 'Place'),
                _textField(_venueController, 'Venue'),
                _dateField(),
              ]),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _registerMarriage,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.how_to_reg),
                  label: Text(
                    _isSaving ? 'Registering...' : 'Register Marriage',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registered Marriages (${_registrations.length})',
              style: const TextStyle(
                color: AppTheme.primaryEmerald,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_loadError != null)
              Row(
                children: [
                  Expanded(child: Text(_loadError!)),
                  TextButton(
                    onPressed: _loadRegistrations,
                    child: const Text('Retry'),
                  ),
                ],
              )
            else if (_registrations.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('No marriages have been registered yet.'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Groom')),
                    DataColumn(label: Text('Bride')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Place / Venue')),
                    DataColumn(label: Text('Certificate')),
                  ],
                  rows: _registrations.map((registration) {
                    return DataRow(
                      cells: [
                        DataCell(Text(registration.groomName)),
                        DataCell(Text(registration.brideName)),
                        DataCell(Text(
                          DateFormat('dd MMM yyyy')
                              .format(registration.marriageDate),
                        )),
                        DataCell(Text(
                          '${registration.marriagePlace} / ${registration.venue}',
                        )),
                        DataCell(
                          IconButton(
                            tooltip: 'Download marriage certificate',
                            icon: const Icon(
                              Icons.picture_as_pdf,
                              color: AppTheme.primaryEmerald,
                            ),
                            onPressed: () =>
                                _downloadCertificate(registration),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  Widget _buildResponsiveFields(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 700
            ? fields.length
            : constraints.maxWidth > 450
                ? 2
                : 1;
        final width =
            (constraints.maxWidth - 12 * (columns - 1)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields
              .map((field) => SizedBox(width: width, child: field))
              .toList(),
        );
      },
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Enter $label'
          : null,
    );
  }

  Widget _dateField() {
    return FormField<DateTime>(
      validator: (_) =>
          _marriageDate == null ? 'Select the marriage date' : null,
      builder: (field) => InkWell(
        onTap: () => _selectMarriageDate(field),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Marriage date',
            errorText: field.errorText,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            _marriageDate == null
                ? 'Select date'
                : DateFormat('dd MMM yyyy').format(_marriageDate!),
          ),
        ),
      ),
    );
  }
}
