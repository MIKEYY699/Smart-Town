import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../../theme/app_theme.dart';

/// Shows the customer's real community and lets them add a private note
/// (house number, street, landmark). The note is shared only with the
/// provider who accepts the request.
class RequestLocationWidget extends StatefulWidget {
  final ValueChanged<String> onNoteChanged;

  const RequestLocationWidget({required this.onNoteChanged, super.key});

  @override
  State<RequestLocationWidget> createState() => _RequestLocationWidgetState();
}

class _RequestLocationWidgetState extends State<RequestLocationWidget> {
  String _community = '';

  @override
  void initState() {
    super.initState();
    _loadCommunity();
  }

  Future<void> _loadCommunity() async {
    try {
      final client = Supabase.instance.client;
      final row = await client
          .from('profiles')
          .select('communities(name, city)')
          .eq('id', client.auth.currentUser!.id)
          .single();
      final data = row['communities'];
      if (!mounted) return;
      setState(() {
        _community = data is Map ? '${data['name']}, ${data['city']}' : '';
      });
    } catch (_) {
      // The form still works without the community name.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _community.isEmpty ? 'Your community' : _community,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: widget.onNoteChanged,
          maxLength: 300,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'House number, street or landmark (optional)',
            hintText: 'e.g. House 14, Street 3, near the green mosque',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline, size: 14, color: Color(0xFF9E9E9E)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Private. Only the provider who accepts your request can read this.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}