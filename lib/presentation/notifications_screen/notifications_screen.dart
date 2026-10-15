import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// The user's notifications. New ones appear live.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = Supabase.instance.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50);
  }

  String _now() => DateTime.now().toUtc().toIso8601String();

  Future<void> _markAllRead() async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'read_at': _now()})
          .filter('read_at', 'is', null);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update. Try again.')),
      );
    }
  }

  Future<void> _open(Map<String, dynamic> notification) async {
    final id = notification['id'] as String;
    final type = notification['type'] as String? ?? '';

    if (notification['read_at'] == null) {
      try {
        await Supabase.instance.client
            .from('notifications')
            .update({'read_at': _now()})
            .eq('id', id);
      } catch (_) {
        // Opening the screen still works even if marking as read fails.
      }
    }

    if (!mounted) return;

    if (type == 'new_request' || type == 'cancelled' || type == 'review') {
      context.push(AppRoutes.providerDashboardScreen);
    } else if (type == 'status') {
      context.go(AppRoutes.myRequestsScreen);
    }
  }

  String _ago(String? iso) {
    final date = DateTime.tryParse(iso ?? '')?.toLocal();
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }

  IconData _icon(String type) {
    switch (type) {
      case 'new_request':
        return Icons.assignment_outlined;
      case 'status':
        return Icons.sync;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'review':
        return Icons.star_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Widget _tile(Map<String, dynamic> n) {
    final unread = n['read_at'] == null;
    final type = n['type'] as String? ?? '';

    return GestureDetector(
      onTap: () => _open(n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? AppTheme.primaryMuted : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon(type), color: AppTheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n['title'] as String? ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n['body'] as String? ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF5C5C5C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _ago(n['created_at'] as String?),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
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
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Read all'),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Could not load notifications'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data!;

            if (items.isEmpty) {
              return const Center(child: Text('No notifications yet.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (context, index) => _tile(items[index]),
            );
          },
        ),
      ),
    );
  }
}
