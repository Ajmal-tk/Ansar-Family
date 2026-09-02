import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isRole;

  const StatusBadge({
    super.key,
    required this.status,
    this.isRole = false,
  });

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.toLowerCase();
    Color bgColor;
    Color textColor;
    IconData icon;

    if (isRole) {
      switch (cleanStatus) {
        case 'admin':
          bgColor = Colors.purple.shade50;
          textColor = Colors.purple.shade800;
          icon = Icons.admin_panel_settings;
          break;
        case 'management':
          bgColor = Colors.teal.shade50;
          textColor = Colors.teal.shade800;
          icon = Icons.verified_user;
          break;
        default:
          bgColor = Colors.blue.shade50;
          textColor = Colors.blue.shade800;
          icon = Icons.person;
      }
    } else {
      switch (cleanStatus) {
        case 'approved':
        case 'paid':
          bgColor = AppTheme.accentMint.withValues(alpha: 0.12);
          textColor = AppTheme.primaryEmerald;
          icon = Icons.check_circle;
          break;
        case 'pending':
          bgColor = AppTheme.statusPending.withValues(alpha: 0.12);
          textColor = const Color(0xFFB45309);
          icon = Icons.hourglass_empty;
          break;
        case 'rejected':
          bgColor = AppTheme.statusRejected.withValues(alpha: 0.12);
          textColor = AppTheme.statusRejected;
          icon = Icons.cancel;
          break;
        default:
          bgColor = Colors.grey.shade100;
          textColor = Colors.grey.shade800;
          icon = Icons.info;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
