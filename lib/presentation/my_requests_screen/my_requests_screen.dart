import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Shows the logged-in customer's own service requests.
class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;

    final rows = await client
        .from('service_requests')
        .select('id, category, description, urgency, status, created_at')
        .eq('customer_id', userId)
        .order('created_at', ascending: false);

    final reviewRows = await client
        .from('reviews')
        .select('request_id')
        .eq('customer_id', userId);
    final reviewedIds = reviewRows.map((r) => r['request_id']).toSet();

    return rows.map<Map<String, dynamic>>((r) {
      final copy = Map<String, dynamic>.from(r);
      copy['reviewed'] = reviewedIds.contains(r['id']);
      return copy;
    }).toList();
  }

  Future<void> _rateProvider(String requestId) async {
    final result = await showDialog<_ReviewResult>(
      context: context,
      builder: (_) => const _ReviewDialog(),
    );
    if (result == null || !mounted) return;

    try {
      await Supabase.instance.client.rpc(
        'submit_review',
        params: {
          'p_request_id': requestId,
          'p_rating': result.rating,
          'p_comment': result.comment,
        },
      );
      if (!mounted) return;
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit your review.')),
      );
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: const Text('The provider will no longer see it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await Supabase.instance.client
          .from('service_requests')
          .update({'status': 'cancelled'})
          .eq('id', requestId);
      if (!mounted) return;
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not cancel. Try again.')),
      );
    }
  }

  Future<void> _refresh() async {
    final newFuture = _load();
    setState(() {
      _future = newFuture;
    });
    await newFuture;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
      case 'on_the_way':
      case 'in_progress':
        return AppTheme.secondary;
      case 'completed':
        return AppTheme.success;
      case 'cancelled':
      case 'rejected':
        return AppTheme.error;
      default:
        return AppTheme.warning;
    }
  }

  String _statusLabel(String status) {
    final text = status.replaceAll('_', ' ');
    return text[0].toUpperCase() + text.substring(1);
  }

  String _dateLabel(String? iso) {
    if (iso == null) return '';
    final date = DateTime.tryParse(iso)?.toLocal();
    if (date == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildCard(Map<String, dynamic> request) {
    final status = request['status'] as String? ?? 'requested';
    final urgency = request['urgency'] as String? ?? 'normal';
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
                  request['category'] as String? ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
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
                  _statusLabel(status),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request['description'] as String? ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF5C5C5C),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_dateLabel(request['created_at'] as String?)}'
            '${urgency != 'normal' ? '  •  ${urgency.toUpperCase()}' : ''}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          if (status == 'completed') ...[
            const SizedBox(height: 12),
            if (request['reviewed'] == true)
              Text(
                'You reviewed this job',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.success,
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => _rateProvider(request['id'] as String),
                  icon: const Icon(Icons.star_border),
                  label: const Text('Rate provider'),
                ),
              ),
          ],
          if (status == 'requested' || status == 'accepted') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => _cancelRequest(request['id'] as String),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                ),
                child: const Text('Cancel request'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Requests',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.go(AppRoutes.createServiceRequestScreen),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
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
                          const Text('Could not load your requests'),
                          TextButton(
                            onPressed: _refresh,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    );
                  }

                  final requests = snapshot.data ?? [];

                  if (requests.isEmpty) {
                    return const Center(
                      child: Text('No requests yet. Tap New to create one.'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: requests.length,
                      itemBuilder: (context, index) =>
                          _buildCard(requests[index]),
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


class _ReviewResult {
  final int rating;
  final String comment;

  const _ReviewResult(this.rating, this.comment);
}

/// The rating box. It owns its own text controller, so it is cleaned up
/// only after the box has fully closed.
class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog();

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _commentController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate this provider'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return IconButton(
                  onPressed: () => setState(() => _rating = i + 1),
                  icon: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFF59E0B),
                    size: 32,
                  ),
                );
              }),
            ),
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Write a short review (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _rating == 0
              ? null
              : () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pop(
                    _ReviewResult(_rating, _commentController.text.trim()),
                  );
                },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}