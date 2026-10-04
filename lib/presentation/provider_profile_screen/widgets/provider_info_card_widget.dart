import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProviderInfoCardWidget extends StatelessWidget {
  const ProviderInfoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: AppTheme.primary, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Joseph Carl',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AC Specialist',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rs. 500 /visit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _ActionCircleButton(iconName: 'call', onTap: () {}),
                  const SizedBox(width: 10),
                  _ActionCircleButton(
                    iconName: 'chat_bubble_outline',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'About',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Experienced AC technician with 12 years of hands-on expertise in installation, maintenance, and repair of all major AC brands. Serving Model Town and surrounding areas with reliable, punctual service.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF5C5C5C),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoChip(iconName: 'location_on', label: 'Model Town, GRW'),
              const SizedBox(width: 10),
              _InfoChip(iconName: 'check_circle', label: '234 Jobs Done'),
              const SizedBox(width: 10),
              _InfoChip(iconName: 'language', label: 'Urdu, English'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCircleButton extends StatelessWidget {
  final String iconName;
  final VoidCallback onTap;

  const _ActionCircleButton({required this.iconName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
          color: Colors.white,
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: AppTheme.primary,
          size: 20,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String iconName;
  final String label;

  const _InfoChip({required this.iconName, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.primary,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
