import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../theme/app_theme.dart';

/// Admin only: approve, suspend and reactivate providers.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final rows = await Supabase.instance.client
        .from('providers')
        .select(
          'id, full_name, description, experience_years, verification, '
          'rating_avg, rating_count, created_at, professions(name)',
        )
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> _refresh() async {
    final newFuture = _load();
    setState(() {
      _future = newFuture;
    });
    await newFuture;
  }

  Future<void> _setStatus(String providerId, String status) async {
    setState(() {
      _busyId = providerId;
    });
    try {
      await Supabase.instance.client.rpc(
        'admin_set_verification',
        params: {'p_provider_id': providerId, 'p_status': status},
      );
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyId = null;
        });
      }
    }
  }

  Future<void> _confirmSuspend(String providerId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Suspend $name?'),
        content: const Text(
          'They will disappear from the app and will not receive requests.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _setStatus(providerId, 'suspended');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'verified':
        return AppTheme.success;
      case 'suspended':
        return AppTheme.error;
      case 'pending':
        return AppTheme.warning;
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Widget _card(Map<String, dynamic> p) {
    final id = p['id'] as String;
    final name = p['full_name'] as String? ?? '';
    final status = p['verification'] as String? ?? 'unverified';
    final professionData = p['professions'];
    final profession = professionData is Map
        ? (professionData['name'] as String? ?? '')
        : '';
    final years = (p['experience_years'] as num?)?.toInt() ?? 0;
    final description = p['description'] as String? ?? '';
    final busy = _busyId == id;
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$profession  •  $years yr experience',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF5C5C5C),
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF5C5C5C),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (busy)
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Row(
              children: [
                if (status == 'unverified' || status == 'pending')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _setStatus(id, 'verified'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                if (status == 'suspended')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _setStatus(id, 'verified'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Reactivate'),
                    ),
                  ),
                if (status != 'suspended') ...[
                  if (status == 'unverified' || status == 'pending')
                    const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirmSuspend(id, name),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                      ),
                      child: const Text('Suspend'),
                    ),
                  ),
                ],
              ],
            ),
        ],
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
          'Admin: Providers',
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
              return const Center(child: Text('No providers yet.'));
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
