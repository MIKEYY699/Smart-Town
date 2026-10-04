import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class _Category {
  final String id;
  final String name;
  final String iconName;

  const _Category({
    required this.id,
    required this.name,
    required this.iconName,
  });
}

class RequestCategorySelectorWidget extends StatelessWidget {
  final String? selectedCategoryId;
  final void Function(String id, String name) onCategorySelected;

  const RequestCategorySelectorWidget({
    required this.selectedCategoryId,
    required this.onCategorySelected,
    super.key,
  });

  static const List<_Category> _categories = [
    _Category(id: 'plumbing', name: 'Plumbing', iconName: 'plumbing'),
    _Category(
      id: 'electrical',
      name: 'Electrical',
      iconName: 'electrical_services',
    ),
    _Category(id: 'ac_repair', name: 'AC Repair', iconName: 'ac_unit'),
    _Category(id: 'carpentry', name: 'Carpentry', iconName: 'carpenter'),
    _Category(id: 'painting', name: 'Painting', iconName: 'format_paint'),
    _Category(id: 'cleaning', name: 'Cleaning', iconName: 'cleaning_services'),
    _Category(id: 'locksmith', name: 'Locksmith', iconName: 'lock_open'),
    _Category(id: 'appliance', name: 'Appliance', iconName: 'kitchen'),
    _Category(
      id: 'mobile_repair',
      name: 'Mobile Repair',
      iconName: 'phone_android',
    ),
    _Category(id: 'tutor', name: 'Tutor', iconName: 'school'),
    _Category(id: 'mason', name: 'Masonry', iconName: 'foundation'),
    _Category(id: 'other', name: 'Other', iconName: 'more_horiz'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final isSelected = cat.id == selectedCategoryId;
        return GestureDetector(
          onTap: () => onCategorySelected(cat.id, cat.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.primary : const Color(0xFFEEEEEE),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: cat.iconName,
                  color: isSelected ? Colors.white : const Color(0xFF5C5C5C),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  cat.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF5C5C5C),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
