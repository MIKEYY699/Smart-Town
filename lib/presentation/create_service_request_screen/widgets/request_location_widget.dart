import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class RequestLocationWidget extends StatefulWidget {
  const RequestLocationWidget({super.key});

  @override
  State<RequestLocationWidget> createState() => _RequestLocationWidgetState();
}

class _RequestLocationWidgetState extends State<RequestLocationWidget> {
  // TODO: Replace with Riverpod/Bloc for production
  String _selectedArea = 'Model Town Block B';
  bool _useCurrentLocation = true;

  static const List<String> _areas = [
    'Model Town Block A',
    'Model Town Block B',
    'Model Town Block C',
    'Model Town Block D',
    'Model Town Block E',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current location toggle
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use current location',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'Approximate area only — not exact address',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _useCurrentLocation,
              onChanged: (val) => setState(() => _useCurrentLocation = val),
              activeThumbColor: AppTheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Area display / selector
        GestureDetector(
          onTap: () => _showAreaPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Area',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      Text(
                        _selectedArea,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: const Color(0xFF9E9E9E),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.warning,
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Exact address is only shared with accepted providers',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppTheme.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAreaPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Select Your Area',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          ..._areas.map(
            (area) => ListTile(
              leading: CustomIconWidget(
                iconName: area == _selectedArea
                    ? 'radio_button_checked'
                    : 'radio_button_unchecked',
                color: area == _selectedArea
                    ? AppTheme.primary
                    : const Color(0xFF9E9E9E),
                size: 20,
              ),
              title: Text(
                area,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: area == _selectedArea
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: area == _selectedArea
                      ? AppTheme.primary
                      : const Color(0xFF1A1A1A),
                ),
              ),
              onTap: () {
                setState(() => _selectedArea = area);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
