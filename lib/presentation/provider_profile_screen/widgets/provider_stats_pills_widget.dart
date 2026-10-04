import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class _StatPill {
  final String iconName;
  final String value;
  final String label;
  final Color iconColor;

  const _StatPill({
    required this.iconName,
    required this.value,
    required this.label,
    required this.iconColor,
  });
}

class ProviderStatsPillsWidget extends StatelessWidget {
  const ProviderStatsPillsWidget({super.key});

  static const List<_StatPill> _stats = [
    _StatPill(
      iconName: 'emoji_events',
      value: '#1',
      label: 'Top Service',
      iconColor: Color(0xFFF59E0B),
    ),
    _StatPill(
      iconName: 'star',
      value: '4.9',
      label: 'Rating',
      iconColor: Color(0xFFF59E0B),
    ),
    _StatPill(
      iconName: 'work_history',
      value: '12 Yrs',
      label: 'Experience',
      iconColor: AppTheme.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, -24, 20, 0),
      child: Row(
        children: List.generate(_stats.length, (i) {
          final stat = _stats[i];
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < _stats.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: stat.iconName,
                    color: stat.iconColor,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    stat.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: const Color(0xFF9E9E9E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
