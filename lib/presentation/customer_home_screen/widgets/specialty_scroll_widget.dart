import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';

class _SpecialtyItem {
  final String id;
  final String name;
  final String subtitle;
  final String imageUrl;
  final String semanticLabel;
  final int providerCount;

  const _SpecialtyItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.semanticLabel,
    required this.providerCount,
  });
}

class SpecialtyScrollWidget extends StatelessWidget {
  final void Function(String id) onProviderTap;

  const SpecialtyScrollWidget({required this.onProviderTap, super.key});

  static const List<_SpecialtyItem> _items = [
    _SpecialtyItem(
      id: 'appliance',
      name: 'Appliance Repair',
      subtitle: 'Fridge, washer, oven',
      imageUrl:
          'https://images.pexels.com/photos/4489732/pexels-photo-4489732.jpeg',
      semanticLabel: 'Technician repairing home appliance in kitchen',
      providerCount: 8,
    ),
    _SpecialtyItem(
      id: 'tutor',
      name: 'Home Tuition',
      subtitle: 'All subjects, all grades',
      imageUrl:
          'https://images.pixabay.com/photo/2015/07/17/22/43/student-849825_1280.jpg',
      semanticLabel: 'Tutor teaching student at table with books',
      providerCount: 15,
    ),
    _SpecialtyItem(
      id: 'pest',
      name: 'Pest Control',
      subtitle: 'Fumigation & treatment',
      imageUrl:
          'https://images.pexels.com/photos/6471938/pexels-photo-6471938.jpeg',
      semanticLabel: 'Pest control worker in protective suit spraying',
      providerCount: 4,
    ),
    _SpecialtyItem(
      id: 'tailor',
      name: 'Tailoring',
      subtitle: 'Stitching & alterations',
      imageUrl:
          'https://images.pixabay.com/photo/2016/11/19/15/50/sewing-1839757_1280.jpg',
      semanticLabel: 'Tailor working at sewing machine with fabric',
      providerCount: 6,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Specialty Services',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
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
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return GestureDetector(
                onTap: () => onProviderTap(item.id),
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomImageWidget(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          semanticLabel: item.semanticLabel,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(179),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${item.providerCount} providers nearby',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: Colors.white.withAlpha(217),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
