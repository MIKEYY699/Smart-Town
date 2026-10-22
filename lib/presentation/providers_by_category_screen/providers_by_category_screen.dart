import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar_widget.dart';

/// Lists the providers for one category, for example "Plumbing".
class ProvidersByCategoryScreen extends StatefulWidget {
  final String category;

  const ProvidersByCategoryScreen({required this.category, super.key});

  @override
  State<ProvidersByCategoryScreen> createState() =>
      _ProvidersByCategoryScreenState();
}

class _ProvidersByCategoryScreenState extends State<ProvidersByCategoryScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final rows = await Supabase.instance.client
        .from('providers')
        .select(
          'id, full_name, photo_url, verification, availability, rating_avg, '
          'rating_count, professions!inner(name, category)',
        )
        .eq('professions.category', widget.category)
        .order('rating_avg', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> _refresh() async {
    final newFuture = _load();
    setState(() {
      _future = newFuture;
    });
    await newFuture;
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

  Widget _card(Map<String, dynamic> p) {
    final name = p['full_name'] as String? ?? '';
    final verified = p['verification'] == 'verified';
    final availability = p['availability'] as String? ?? 'offline';
    final ratingCount = (p['rating_count'] as num?)?.toInt() ?? 0;
    final ratingAvg = (p['rating_avg'] as num?)?.toDouble() ?? 0;

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.providerProfileScreen,
        extra: p['id'] as String,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            AvatarWidget(
              name: name,
              imageUrl: p['photo_url'] as String?,
              radius: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (verified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: AppTheme.verified,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFF59E0B),
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        ratingCount == 0
                            ? 'New'
                            : '${ratingAvg.toStringAsFixed(1)} ($ratingCount)',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              availability[0].toUpperCase() + availability.substring(1),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _availabilityColor(availability),
              ),
            ),
          ],
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
          widget.category,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
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
                      onPressed: _refresh,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            }

            final providers = snapshot.data ?? [];

            if (providers.isEmpty) {
              return Center(
                child: Text('No ${widget.category} providers yet.'),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: providers.length,
                itemBuilder: (context, index) => _card(providers[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
