import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgresChangeEvent, RealtimeChannel, Supabase;

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class _DashboardData {
  final String providerId;
  final String verification;
  final String availability;
  final bool emergencyAvailable;
  final double ratingAvg;
  final int ratingCount;
  final List<Map<String, dynamic>> reviews;
  final List<Map<String, dynamic>> openRequests;
  final List<Map<String, dynamic>> myJobs;

  const _DashboardData({
    required this.providerId,
    required this.verification,
    required this.availability,
    required this.emergencyAvailable,
    required this.ratingAvg,
    required this.ratingCount,
    required this.reviews,
    required this.openRequests,
    required this.myJobs,
  });
}

/// For providers: see new requests, accept them, and move jobs forward.
class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  late Future<_DashboardData> _future;
  String? _busyRequestId;
  RealtimeChannel? _channel;

  static const _columns =
      'id, category, description, urgency, status, preferred_time, '
      'photo_path, created_at';

  @override
  void initState() {
    super.initState();
    _future = _load();
    _channel = Supabase.instance.client
        .channel('provider-dashboard-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'service_requests',
          callback: (_) {
            if (mounted) _refresh();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    final channel = _channel;
    if (channel != null) {
      Supabase.instance.client.removeChannel(channel);
    }
    super.dispose();
  }

  Future<_DashboardData> _load() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;

    final provider = await client
        .from('providers')
        .select(
          'id, verification, rating_avg, rating_count, '
          'availability, emergency_available',
        )
        .eq('user_id', userId)
        .single();

    final providerId = provider['id'] as String;
    final verification = provider['verification'] as String;

    var open = <Map<String, dynamic>>[];
    if (verification == 'verified') {
      final rows = await client
          .from('service_requests')
          .select(_columns)
          .eq('status', 'requested')
          .filter('provider_id', 'is', null)
          .neq('customer_id', userId)
          .order('created_at', ascending: false);
      open = await _withPhotoUrls(List<Map<String, dynamic>>.from(rows));
    }

    final jobRows = await client
        .from('service_requests')
        .select(_columns)
        .eq('provider_id', providerId)
        .inFilter('status', ['accepted', 'on_the_way', 'in_progress'])
        .order('created_at', ascending: false);

    final reviewRows = await client
        .from('reviews')
        .select('rating, comment, created_at')
        .eq('provider_id', providerId)
        .order('created_at', ascending: false)
        .limit(10);

    return _DashboardData(
      providerId: providerId,
      verification: verification,
      availability: provider['availability'] as String? ?? 'offline',
      emergencyAvailable: provider['emergency_available'] == true,
      ratingAvg: (provider['rating_avg'] as num?)?.toDouble() ?? 0,
      ratingCount: (provider['rating_count'] as num?)?.toInt() ?? 0,
      reviews: List<Map<String, dynamic>>.from(reviewRows),
      openRequests: open,
      myJobs: await _withPhotoUrls(List<Map<String, dynamic>>.from(jobRows)),
    );
  }

  /// Photos are private, so each one needs a short-lived link.
  Future<List<Map<String, dynamic>>> _withPhotoUrls(
    List<Map<String, dynamic>> rows,
  ) async {
    final storage = Supabase.instance.client.storage.from('request-photos');
    final result = <Map<String, dynamic>>[];

    for (final row in rows) {
      final copy = Map<String, dynamic>.from(row);
      final path = row['photo_path'] as String?;
      if (path != null) {
        try {
          copy['photo_url'] = await storage.createSignedUrl(path, 3600);
        } catch (_) {
          copy['photo_url'] = null;
        }
      }
      result.add(copy);
    }
    return result;
  }

  Future<void> _refresh() async {
    final newFuture = _load();
    setState(() {
      _future = newFuture;
    });
    await newFuture;
  }

  Future<void> _run(String requestId, Future<void> Function() action) async {
    setState(() => _busyRequestId = requestId);
    try {
      await action();
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update. It may no longer be available.'),
        ),
      );
      await _refresh();
    } finally {
      if (mounted) setState(() => _busyRequestId = null);
    }
  }

  Future<void> _accept(String requestId) {
    return _run(requestId, () async {
      await Supabase.instance.client.rpc(
        'accept_request',
        params: {'request_id': requestId},
      );
    });
  }

  Future<void> _moveTo(String requestId, String newStatus) {
    return _run(requestId, () async {
      await Supabase.instance.client.rpc(
        'update_job_status',
        params: {'request_id': requestId, 'new_status': newStatus},
      );
    });
  }

  String? _nextStatus(String status) {
    switch (status) {
      case 'accepted':
        return 'on_the_way';
      case 'on_the_way':
        return 'in_progress';
      case 'in_progress':
        return 'completed';
      default:
        return null;
    }
  }

  String _nextLabel(String status) {
    switch (status) {
      case 'accepted':
        return "I'm on the way";
      case 'on_the_way':
        return 'Start work';
      case 'in_progress':
        return 'Mark completed';
      default:
        return '';
    }
  }

  String _statusLabel(String status) {
    final text = status.replaceAll('_', ' ');
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Future<void> _updateProvider(
    String providerId,
    Map<String, dynamic> values,
  ) async {
    try {
      await Supabase.instance.client
          .from('providers')
          .update(values)
          .eq('id', providerId);
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Check your internet.')),
      );
    }
  }

  Widget _controls(_DashboardData data) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your status',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'available', label: Text('Available')),
                ButtonSegment(value: 'busy', label: Text('Busy')),
                ButtonSegment(value: 'offline', label: Text('Offline')),
              ],
              showSelectedIcon: false,
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 4),
                ),
                textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 13)),
              ),
              selected: {data.availability},
              onSelectionChanged: (selection) => _updateProvider(
                data.providerId,
                {'availability': selection.first},
              ),
            ),
          ),
          const SizedBox(height: 6),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Available for emergency calls'),
            value: data.emergencyAvailable,
            onChanged: (value) => _updateProvider(data.providerId, {
              'emergency_available': value,
            }),
          ),
        ],
      ),
    );
  }

  Widget _ratingSummary(_DashboardData data) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Color(0xFFF59E0B), size: 32),
          const SizedBox(width: 10),
          Text(
            data.ratingCount == 0
                ? 'No ratings yet'
                : data.ratingAvg.toStringAsFixed(1),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          if (data.ratingCount > 0)
            Text(
              '(${data.ratingCount} ${data.ratingCount == 1 ? 'review' : 'reviews'})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF5C5C5C),
              ),
            ),
        ],
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

  Widget _requestCard(Map<String, dynamic> r, {required bool isJob}) {
    final id = r['id'] as String;
    final status = r['status'] as String;
    final urgency = r['urgency'] as String? ?? 'normal';
    final busy = _busyRequestId == id;
    final next = isJob ? _nextStatus(status) : null;

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
                  r['category'] as String? ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (urgency != 'normal')
                Text(
                  urgency.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r['description'] as String? ?? '',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF5C5C5C),
              height: 1.4,
            ),
          ),
          if (r['photo_url'] != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                r['photo_url'] as String,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 60,
                  child: Center(child: Text('Photo could not load')),
                ),
              ),
            ),
          ],
          if (r['preferred_time'] != null) ...[
            const SizedBox(height: 6),
            Text(
              'Preferred time: ${r['preferred_time']}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (!isJob)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: busy ? null : () => _accept(id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Accept request'),
              ),
            )
          else ...[
            Text(
              'Status: ${_statusLabel(status)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => context.push(
                  AppRoutes.chatScreen,
                  extra: {
                    'requestId': id,
                    'title': r['category'] as String? ?? 'Chat',
                    'canSend': true,
                  },
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat with customer'),
              ),
            ),
            if (next != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: busy ? null : () => _moveTo(id, next),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_nextLabel(status)),
                ),
              ),
            ],
          ],
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
          'Provider Dashboard',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<_DashboardData>(
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
                    const Text('Could not load the dashboard'),
                    TextButton(
                      onPressed: _refresh,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!;
            final verified = data.verification == 'verified';

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                children: [
                  if (!verified)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.warningContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data.verification == 'suspended'
                            ? 'Your account is suspended.'
                            : 'Your profile is waiting for admin '
                                  'verification. You will see requests '
                                  'once you are verified.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                      ),
                    ),
                  _ratingSummary(data),
                  _controls(data),
                  if (verified) ...[
                    _sectionTitle('New requests (${data.openRequests.length})'),
                    if (data.openRequests.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No new requests right now.'),
                      ),
                    ...data.openRequests.map(
                      (r) => _requestCard(r, isJob: false),
                    ),
                  ],
                  _sectionTitle('My active jobs (${data.myJobs.length})'),
                  if (data.myJobs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No active jobs.'),
                    ),
                  ...data.myJobs.map((r) => _requestCard(r, isJob: true)),
                  _sectionTitle('Recent reviews'),
                  if (data.reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No reviews yet.'),
                    ),
                  ...data.reviews.map(_reviewCard),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
