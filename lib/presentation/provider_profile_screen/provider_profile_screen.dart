import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar_widget.dart';

class _ProfileData {
  final Map<String, dynamic> provider;
  final List<Map<String, dynamic>> reviews;

  const _ProfileData(this.provider, this.reviews);
}

/// What customers see when they tap a provider.
class ProviderProfileScreen extends StatefulWidget {
  final String providerId;

  const ProviderProfileScreen({required this.providerId, super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  late Future<_ProfileData?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProfileData?> _load() async {
    final client = Supabase.instance.client;

    final provider = await client
        .from('providers')
        .select(
          'id, full_name, photo_url, description, experience_years, verification, '
          'availability, emergency_available, rating_avg, rating_count, '
          'professions(name, category)',
        )
        .eq('id', widget.providerId)
        .maybeSingle();

    if (provider == null) return null;

    final reviews = await client
        .from('reviews')
        .select('rating, comment, created_at')
        .eq('provider_id', widget.providerId)
        .order('created_at', ascending: false)
        .limit(20);

    return _ProfileData(
      Map<String, dynamic>.from(provider),
      List<Map<String, dynamic>>.from(reviews),
    );
  }

  Color _availabilityColor(String value) {
    switch (value) {
      case 'available':
        return AppTheme.success;
      case 'busy':
        return AppTheme.warning;
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final comment = review['comment'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < rating ? Icons.star : Icons.star_border,
                color: const Color(0xFFF59E0B),
                size: 18,
              ),
            ),
          ),
          if (comment != null && comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              comment,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF5C5C5C),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Provider',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<_ProfileData?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              // Also happens when the id is not a real provider id.
              return const Center(child: Text('Provider not found'));
            }

            final data = snapshot.data;
            if (data == null) {
              return const Center(child: Text('Provider not found'));
            }

            final p = data.provider;
            final name = p['full_name'] as String? ?? '';
            final professionData = p['professions'];
            final profession = professionData is Map
                ? (professionData['name'] as String? ?? '')
                : '';
            final category = professionData is Map
                ? (professionData['category'] as String? ?? '')
                : '';
            final verified = p['verification'] == 'verified';
            final availability = p['availability'] as String? ?? 'offline';
            final ratingCount = (p['rating_count'] as num?)?.toInt() ?? 0;
            final ratingAvg = (p['rating_avg'] as num?)?.toDouble() ?? 0;
            final years = (p['experience_years'] as num?)?.toInt() ?? 0;
            final description = p['description'] as String? ?? '';
            final emergency = p['emergency_available'] == true;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    children: [
                      Center(
                        child: AvatarWidget(
                          name: name,
                          imageUrl: p['photo_url'] as String?,
                          radius: 48,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (verified) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              color: AppTheme.verified,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profession,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF5C5C5C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _availabilityColor(
                              availability,
                            ).withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            availability[0].toUpperCase() +
                                availability.substring(1),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _availabilityColor(availability),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _stat(
                            ratingCount == 0
                                ? '-'
                                : ratingAvg.toStringAsFixed(1),
                            'Rating',
                          ),
                          const SizedBox(width: 10),
                          _stat('$ratingCount', 'Reviews'),
                          const SizedBox(width: 10),
                          _stat('$years yr', 'Experience'),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        _title('About'),
                        Text(
                          description,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF5C5C5C),
                            height: 1.5,
                          ),
                        ),
                      ],
                      if (emergency) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Available for emergency calls',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                      _title('Reviews'),
                      if (data.reviews.isEmpty)
                        const Text('No reviews yet.')
                      else
                        ...data.reviews.map(_reviewCard),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.push(
                        AppRoutes.createServiceRequestScreen,
                        extra: {
                          'providerId': p['id'],
                          'providerName': name,
                          'category': category,
                        },
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Request service'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
