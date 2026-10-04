import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/status_badge_widget.dart';

class _ProviderCard {
  final String id;
  final String name;
  final String profession;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final BadgeStatus availability;
  final String imageUrl;
  final String semanticLabel;
  final String area;
  final int completedJobs;

  const _ProviderCard({
    required this.id,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.availability,
    required this.imageUrl,
    required this.semanticLabel,
    required this.area,
    required this.completedJobs,
  });
}

class NearbyProvidersWidget extends StatelessWidget {
  final void Function(String providerId) onProviderTap;

  const NearbyProvidersWidget({required this.onProviderTap, super.key});

  static const List<_ProviderCard> _providers = [
    _ProviderCard(
      id: 'p1',
      name: 'Muhammad Usman',
      profession: 'Plumber',
      rating: 4.8,
      reviewCount: 67,
      isVerified: true,
      availability: BadgeStatus.available,
      imageUrl:
          'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg',
      semanticLabel:
          'Professional plumber, Pakistani man in blue uniform, smiling',
      area: 'Model Town B',
      completedJobs: 142,
    ),
    _ProviderCard(
      id: 'p2',
      name: 'Tariq Mehmood',
      profession: 'Electrician',
      rating: 4.6,
      reviewCount: 43,
      isVerified: true,
      availability: BadgeStatus.busy,
      imageUrl:
          'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg',
      semanticLabel:
          'Electrician, South Asian man wearing safety gear, holding tools',
      area: 'Model Town C',
      completedJobs: 98,
    ),
    _ProviderCard(
      id: 'p3',
      name: 'Asif Raza',
      profession: 'AC Technician',
      rating: 4.9,
      reviewCount: 112,
      isVerified: true,
      availability: BadgeStatus.available,
      imageUrl:
          'https://images.pixabay.com/photo/2018/01/15/07/51/woman-3083383_1280.jpg',
      semanticLabel: 'AC technician in orange uniform working on outdoor unit',
      area: 'Serving your area',
      completedJobs: 234,
    ),
    _ProviderCard(
      id: 'p4',
      name: 'Bilal Hassan',
      profession: 'Carpenter',
      rating: 4.3,
      reviewCount: 28,
      isVerified: false,
      availability: BadgeStatus.offline,
      imageUrl:
          'https://images.pexels.com/photos/3637786/pexels-photo-3637786.jpeg',
      semanticLabel: 'Young carpenter measuring wood in workshop',
      area: 'Model Town A',
      completedJobs: 45,
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
                'Nearby Providers',
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
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: _providers.length,
            itemBuilder: (context, index) {
              final p = _providers[index];
              return GestureDetector(
                onTap: () => onProviderTap(p.id),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CustomImageWidget(
                          imageUrl: p.imageUrl,
                          width: 160,
                          height: 100,
                          fit: BoxFit.cover,
                          semanticLabel: p.semanticLabel,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (p.isVerified)
                                  CustomIconWidget(
                                    iconName: 'verified',
                                    color: AppTheme.verified,
                                    size: 14,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              p.profession,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFF9E9E9E),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'star',
                                  color: const Color(0xFFF59E0B),
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${p.rating}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                const Spacer(),
                                StatusBadgeWidget(status: p.availability),
                              ],
                            ),
                          ],
                        ),
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
