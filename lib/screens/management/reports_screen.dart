import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/profile_model.dart';
import '../../services/pdf_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isGenerating = false;

  void _generateFinancialPdf() async {
    setState(() => _isGenerating = true);
    final fees = await SupabaseService.instance.fetchAllFees();
    final pdfBytes = await PdfService.generateFinancialSummaryReport(fees);
    setState(() => _isGenerating = false);

    await PdfService.printOrDownloadPdf(pdfBytes, 'Financial_Summary_Report.pdf');
  }

  void _generateCertificatePdf() async {
    setState(() => _isGenerating = true);
    final profiles = await SupabaseService.instance.fetchAllProfiles();
    final sampleProfile = profiles.isNotEmpty
        ? profiles.first
        : ProfileModel(id: '123', fullName: 'Sample Community Member', role: 'member', status: 'approved');

    final pdfBytes = await PdfService.generateMembershipCertificate(sampleProfile);
    setState(() => _isGenerating = false);

    await PdfService.printOrDownloadPdf(pdfBytes, 'Membership_Certificate_Sample.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Document & Report Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            const Text(
              'EXPORT COMMUNITY DOCUMENTS & REPORTS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 14),

            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Financial Audit Summary Report',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Generates a comprehensive printable PDF statement of all membership fee receipts, donations, totals, and transaction dates.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateFinancialPdf,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Financial Summary PDF'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryEmerald),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified, color: AppTheme.primaryTeal, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Membership Certificate Generator',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Generates an official printable membership certificate with Islamic border ornament, verification seal badge, and executive signature line.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateCertificatePdf,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Certificate PDF'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
