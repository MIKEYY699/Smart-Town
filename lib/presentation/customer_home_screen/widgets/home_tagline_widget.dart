import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/custom_icon_widget.dart';

class HomeTaglineWidget extends StatelessWidget {
  final String community;

  const HomeTaglineWidget({required this.community, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'location_on',
              color: const Color(0xFFE8650A),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              community,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'All your services\nin one place',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
