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
    final rows = await Supabase.instance.client
        .from('service_requests')
        .select('id, category, description, urgency, status, created_at')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> _refresh() async {
    final newFuture = _load();
    setState(() => _future = newFuture);
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
