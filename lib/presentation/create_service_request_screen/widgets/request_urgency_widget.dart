import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/custom_icon_widget.dart';

class _UrgencyOption {
  final String label;
  final String iconName;
  final String description;
  final Color color;

  const _UrgencyOption({
    required this.label,
    required this.iconName,
    required this.description,
    required this.color,
  });
}

class RequestUrgencyWidget extends StatelessWidget {
  final String selectedUrgency;
  final ValueChanged<String> onUrgencyChanged;

  const RequestUrgencyWidget({
    required this.selectedUrgency,
    required this.onUrgencyChanged,
    super.key,
  });

  static const List<_UrgencyOption> _options = [
    _UrgencyOption(
      label: 'Normal',
      iconName: 'schedule',
      description: 'Within 1–2 days',
      color: Color(0xFF2D7A4F),
    ),
    _UrgencyOption(
      label: 'Urgent',
      iconName: 'bolt',
      description: 'Within a few hours',
      color: Color(0xFFB45309),
    ),
    _UrgencyOption(
      label: 'Emergency',
      iconName: 'emergency',
      description: 'Need help NOW',
      color: Color(0xFFB91C1C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((opt) {
        final isSelected = opt.label == selectedUrgency;
        return Expanded(
          child: GestureDetector(
            onTap: () => onUrgencyChanged(opt.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: opt.label == 'Emergency' ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? opt.color.withAlpha(26)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? opt.color : const Color(0xFFEEEEEE),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: opt.iconName,
                    color: isSelected ? opt.color : const Color(0xFF9E9E9E),
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opt.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? opt.color : const Color(0xFF5C5C5C),
                    ),
                  ),
                  Text(
                    opt.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      color: isSelected
                          ? opt.color.withAlpha(204)
                          : const Color(0xFF9E9E9E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
