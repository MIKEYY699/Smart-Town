import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum BadgeStatus {
  available,
  busy,
  offline,
  verified,
  pending,
  suspended,
  urgent,
  emergency,
  completed,
  cancelled,
}

class StatusBadgeWidget extends StatelessWidget {
  final BadgeStatus status;
  final String? customLabel;

  const StatusBadgeWidget({required this.status, this.customLabel, super.key});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: config.dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            customLabel ?? config.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config.textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig() {
    switch (status) {
      case BadgeStatus.available:
        return _BadgeConfig(
          label: 'Available',
          bgColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2D7A4F),
          dotColor: const Color(0xFF2D7A4F),
        );
      case BadgeStatus.busy:
        return _BadgeConfig(
          label: 'Busy',
          bgColor: const Color(0xFFFFF8E1),
          textColor: const Color(0xFFB45309),
          dotColor: const Color(0xFFB45309),
        );
      case BadgeStatus.offline:
        return _BadgeConfig(
          label: 'Offline',
          bgColor: const Color(0xFFF5F5F5),
          textColor: const Color(0xFF9E9E9E),
          dotColor: const Color(0xFF9E9E9E),
        );
      case BadgeStatus.verified:
        return _BadgeConfig(
          label: '✓ Verified',
          bgColor: const Color(0xFFE3F2FD),
          textColor: const Color(0xFF1565C0),
        );
      case BadgeStatus.pending:
        return _BadgeConfig(
          label: 'Pending',
          bgColor: const Color(0xFFFFF8E1),
          textColor: const Color(0xFFB45309),
        );
      case BadgeStatus.suspended:
        return _BadgeConfig(
          label: 'Suspended',
          bgColor: const Color(0xFFFFEBEE),
          textColor: const Color(0xFFB91C1C),
        );
      case BadgeStatus.urgent:
        return _BadgeConfig(
          label: 'Urgent',
          bgColor: const Color(0xFFFFE4CC),
          textColor: const Color(0xFFE8650A),
        );
      case BadgeStatus.emergency:
        return _BadgeConfig(
          label: '🚨 Emergency',
          bgColor: const Color(0xFFFFEBEE),
          textColor: const Color(0xFFB91C1C),
        );
      case BadgeStatus.completed:
        return _BadgeConfig(
          label: 'Completed',
          bgColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2D7A4F),
        );
      case BadgeStatus.cancelled:
        return _BadgeConfig(
          label: 'Cancelled',
          bgColor: const Color(0xFFFFEBEE),
          textColor: const Color(0xFFB91C1C),
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? dotColor;

  _BadgeConfig({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.dotColor,
  });
}
