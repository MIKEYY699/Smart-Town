import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Verified providers who are available for emergency calls right now.
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
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
          'id, full_name, availability, rating_avg, rating_count, '
          'professions(name)',
        )
        .eq('emergency_available', true)
        .eq('verification', 'verified')
        .neq('availability', 'offline')
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

  Widget _card(Map<String, dynamic> p) {
    final name = p['full_name'] as String? ?? '';
    final professionData = p['professions'];
    final profession = professionData is Map
        ? (professionData['name'] as String? ?? '')
        : '';
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
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primaryContainer,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profession,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF5C5C5C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF59E0B), size: 15),
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
                color: availability == 'available'
                    ? AppTheme.success
                    : AppTheme.warning,
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
          'Emergency Services',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warningContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'This app does not replace official emergency services. '
                'If there is danger to life, fire, or a serious electrical '
                'hazard, contact the proper emergency authority first.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.5),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done &&
                      !snapshot.hasData) {
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
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No emergency providers are available right now.',
                          textAlign: TextAlign.center,
                        ),
                      ),
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
          ],
        ),
      ),
    );
  }
}
