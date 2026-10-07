import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';
import '../../../widgets/status_badge_widget.dart';

/// A provider loaded from the Supabase `providers` table.
class _Provider {
  final String id;
  final String name;
  final String profession;
  final double rating;
  final bool isVerified;
  final BadgeStatus availability;
  final String? photoUrl;

  const _Provider({
    required this.id,
    required this.name,
    required this.profession,
    required this.rating,
    required this.isVerified,
    required this.availability,
    required this.photoUrl,
  });

  factory _Provider.fromMap(Map<String, dynamic> map) {
    final professionData = map['professions'];
    final availabilityText = map['availability'] as String? ?? 'offline';

    return _Provider(
      id: map['id'] as String,
      name: map['full_name'] as String? ?? '',
      profession: professionData is Map
          ? (professionData['name'] as String? ?? '')
          : '',
      rating: (map['rating_avg'] as num?)?.toDouble() ?? 0,
      isVerified: map['verification'] == 'verified',
      availability: switch (availabilityText) {
        'available' => BadgeStatus.available,
        'busy' => BadgeStatus.busy,
        _ => BadgeStatus.offline,
      },
      photoUrl: map['photo_url'] as String?,
    );
  }
}

class NearbyProvidersWidget extends StatefulWidget {
  final void Function(String providerId) onProviderTap;

  const NearbyProvidersWidget({required this.onProviderTap, super.key});

  @override
  State<NearbyProvidersWidget> createState() => _NearbyProvidersWidgetState();
}

class _NearbyProvidersWidgetState extends State<NearbyProvidersWidget> {
  late Future<List<_Provider>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadProviders();
  }

  Future<List<_Provider>> _loadProviders() async {
    final rows = await Supabase.instance.client
        .from('providers')
        .select(
          'id, full_name, photo_url, verification, availability, rating_avg, professions(name)',
        )
        .order('rating_avg', ascending: false)
        .limit(20);

    return rows.map<_Provider>((row) => _Provider.fromMap(row)).toList();
  }

  void _retry() {
    setState(() {
      _future = _loadProviders();
    });
  }

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
          child: FutureBuilder<List<_Provider>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Could not load providers'),
                      TextButton(
                        onPressed: _retry,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }

              final providers = snapshot.data ?? [];

              if (providers.isEmpty) {
                return const Center(child: Text('No providers yet'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  return _buildCard(providers[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(_Provider p) {
    return GestureDetector(
      onTap: () => widget.onProviderTap(p.id),
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
              child: p.photoUrl != null
                  ? CustomImageWidget(
                      imageUrl: p.photoUrl!,
                      width: 160,
                      height: 100,
                      fit: BoxFit.cover,
                      semanticLabel: '${p.name}, ${p.profession}',
                    )
                  : Container(
                      width: 160,
                      height: 100,
                      color: AppTheme.primaryMuted,
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: AppTheme.primary,
                      ),
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
                        p.rating.toStringAsFixed(1),
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
  }
}
