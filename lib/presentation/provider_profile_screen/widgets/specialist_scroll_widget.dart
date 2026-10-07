import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';
import '../../../widgets/custom_icon_widget.dart';

class _Specialist {
  final String name;
  final String role;
  final double rating;
  final String imageUrl;
  final String semanticLabel;

  const _Specialist({
    required this.name,
    required this.role,
    required this.rating,
    required this.imageUrl,
    required this.semanticLabel,
  });
}

class SpecialistScrollWidget extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSpecialistTap;

  const SpecialistScrollWidget({
    required this.selectedIndex,
    required this.onSpecialistTap,
    super.key,
  });

  static const List<_Specialist> _specialists = [
    _Specialist(
      name: 'Asif Raza',
      role: 'AC Specialist',
      rating: 4.9,
      imageUrl:
          'https://images.pexels.com/photos/4489732/pexels-photo-4489732.jpeg',
      semanticLabel: 'AC specialist Asif Raza in orange uniform',
    ),
    _Specialist(
      name: 'Mila Olivia',
      role: 'AC Technician',
      rating: 4.7,
      imageUrl:
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
      semanticLabel: 'Female AC technician Mila Olivia smiling in work uniform',
    ),
    _Specialist(
      name: 'Liam Asher',
      role: 'HVAC Engineer',
      rating: 4.8,
      imageUrl:
          'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg',
      semanticLabel: 'HVAC engineer Liam Asher with technical equipment',
    ),
    _Specialist(
      name: 'Lucas Ezra',
      role: 'AC Specialist',
      rating: 4.5,
      imageUrl:
          'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg',
      semanticLabel: 'AC specialist Lucas Ezra in professional attire',
    ),
    _Specialist(
      name: 'Tariq Ali',
      role: 'Refrigeration',
      rating: 4.6,
      imageUrl:
          'https://images.pexels.com/photos/2219024/pexels-photo-2219024.jpeg',
      semanticLabel: 'Refrigeration technician Tariq Ali holding tools',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AC Specialists',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'See all',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _specialists.length,
            itemBuilder: (context, index) {
              final s = _specialists[index];
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onSpecialistTap(index),
                child: Container(
                  width: 72,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 56 : 50,
                        height: isSelected ? 56 : 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withAlpha(77),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: ClipOval(
                          child: CustomImageWidget(
                            imageUrl: s.imageUrl,
                            fit: BoxFit.cover,
                            semanticLabel: s.semanticLabel,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.name.split(' ').first,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? AppTheme.primary
                              : const Color(0xFF1A1A1A),
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'star',
                            color: const Color(0xFFF59E0B),
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${s.rating}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
