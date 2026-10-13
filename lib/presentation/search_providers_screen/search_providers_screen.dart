import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Search providers by name or profession.
class SearchProvidersScreen extends StatefulWidget {
  final String initialQuery;

  const SearchProvidersScreen({this.initialQuery = '', super.key});

  @override
  State<SearchProvidersScreen> createState() => _SearchProvidersScreenState();
}

class _SearchProvidersScreenState extends State<SearchProvidersScreen> {
  late final TextEditingController _controller;
  late Future<List<Map<String, dynamic>>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _controller = TextEditingController(text: widget.initialQuery);
    _future = _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The community is small, so we load providers once and filter on the phone.
  Future<List<Map<String, dynamic>>> _load() async {
    final rows = await Supabase.instance.client
        .from('providers')
        .select(
          'id, full_name, verification, availability, rating_avg, '
          'rating_count, professions(name)',
        )
        .order('rating_avg', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  String _professionOf(Map<String, dynamic> p) {
    final data = p['professions'];
    return data is Map ? (data['name'] as String? ?? '') : '';
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> all) {
    final q = _query.toLowerCase();
    if (q.isEmpty) return all;
    return all.where((p) {
      final name = (p['full_name'] as String? ?? '').toLowerCase();
      final profession = _professionOf(p).toLowerCase();
      return name.contains(q) || profession.contains(q);
    }).toList();
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
                  const SizedBox(height: 2),
                  Text(
                    _professionOf(p),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF5C5C5C),
                    ),
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
        title: TextField(
          controller: _controller,
          autofocus: widget.initialQuery.isEmpty,
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: const InputDecoration(
            hintText: 'Search name or profession',
            border: InputBorder.none,
          ),
        ),
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
                      onPressed: () {
                        setState(() {
                          _future = _load();
                        });
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            }

            final results = _filter(snapshot.data ?? []);

            if (results.isEmpty) {
              return const Center(child: Text('No providers found.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: results.length,
              itemBuilder: (context, index) => _card(results[index]),
            );
          },
        ),
      ),
    );
  }
}
