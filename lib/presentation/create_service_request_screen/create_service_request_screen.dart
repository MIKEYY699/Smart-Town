import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../theme/app_theme.dart';
import './widgets/request_category_selector_widget.dart';
import './widgets/request_location_widget.dart';
import './widgets/request_media_widget.dart';
import './widgets/request_problem_widget.dart';
import './widgets/request_schedule_widget.dart';
import './widgets/request_urgency_widget.dart';
import '../../routes/app_routes.dart';

class CreateServiceRequestScreen extends StatefulWidget {
  const CreateServiceRequestScreen({super.key});

  @override
  State<CreateServiceRequestScreen> createState() =>
      _CreateServiceRequestScreenState();
}

class _CreateServiceRequestScreenState
    extends State<CreateServiceRequestScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String _problemDescription = '';
  String _urgencyLevel = 'Normal';
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;
  final List<String> _attachedMediaPaths = [];
  bool _isSubmitting = false;
  String? _aiClassificationHint;

  void _onCategorySelected(String id, String name) {
    setState(() {
      _selectedCategoryId = id;
      _selectedCategoryName = name;
    });
  }

  void _onDescriptionChanged(String text) {
    setState(() {
      _problemDescription = text;
      // Simulate AI classification hint
      if (text.toLowerCase().contains('nal') ||
          text.toLowerCase().contains('pipe') ||
          text.toLowerCase().contains('leak')) {
        _aiClassificationHint = '🤖 Detected: Plumbing → Pipe/Faucet Leakage';
      } else if (text.toLowerCase().contains('ac') ||
          text.toLowerCase().contains('thanda')) {
        _aiClassificationHint = '🤖 Detected: AC Technician → Cooling Issue';
      } else if (text.toLowerCase().contains('bijli') ||
          text.toLowerCase().contains('electric')) {
        _aiClassificationHint = '🤖 Detected: Electrical → Power/Wiring Issue';
      } else if (text.length > 10) {
        _aiClassificationHint = null;
      } else {
        _aiClassificationHint = null;
      }
    });
  }

  void _onUrgencyChanged(String urgency) =>
      setState(() => _urgencyLevel = urgency);

  void _onDateSelected(DateTime date) => setState(() => _preferredDate = date);

  void _onTimeSelected(TimeOfDay time) => setState(() => _preferredTime = time);

  void _onMediaAdded(String path) =>
      setState(() => _attachedMediaPaths.add(path));

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a service category',
            style: GoogleFonts.plusJakartaSans(fontSize: 13),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final client = Supabase.instance.client;
      await client.from('service_requests').insert({
        'customer_id': client.auth.currentUser!.id,
        'category': _selectedCategoryName,
        'description': _problemDescription.trim(),
        'urgency': _urgencyLevel.toLowerCase(),
        'preferred_date': _preferredDate?.toIso8601String().split('T').first,
        'preferred_time': _preferredTime?.format(context),
      });
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSuccessDialog();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not submit. Check your description and internet, then try again.',
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF2D7A4F),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Request Submitted!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your service request has been submitted. Nearby providers will respond shortly.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF5C5C5C),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go(AppRoutes.myRequestsScreen);
                },
                child: const Text('View My Requests'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
          onPressed: () => context.go(AppRoutes.myRequestsScreen),
        ),
        title: Text(
          'New Service Request',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _urgencyLevel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 40 : 20,
                20,
                isTablet ? 40 : 20,
                0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // AI Classification hint banner
                  if (_aiClassificationHint != null) ...[
                    _AiHintBanner(hint: _aiClassificationHint!),
                    const SizedBox(height: 16),
                  ],

                  // Section 1: Category
                  _SectionCard(
                    title: 'Service Category',
                    iconName: 'category',
                    child: RequestCategorySelectorWidget(
                      selectedCategoryId: _selectedCategoryId,
                      onCategorySelected: _onCategorySelected,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 2: Problem Description
                  _SectionCard(
                    title: 'Describe the Problem',
                    iconName: 'description',
                    child: RequestProblemWidget(
                      onDescriptionChanged: _onDescriptionChanged,
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 3: Urgency
                  _SectionCard(
                    title: 'Urgency Level',
                    iconName: 'priority_high',
                    child: RequestUrgencyWidget(
                      selectedUrgency: _urgencyLevel,
                      onUrgencyChanged: _onUrgencyChanged,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 4: Schedule
                  _SectionCard(
                    title: 'Preferred Schedule',
                    iconName: 'calendar_today',
                    child: RequestScheduleWidget(
                      selectedDate: _preferredDate,
                      selectedTime: _preferredTime,
                      onDateSelected: _onDateSelected,
                      onTimeSelected: _onTimeSelected,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 5: Media
                  _SectionCard(
                    title: 'Attach Photos / Videos',
                    iconName: 'photo_camera',
                    subtitle: 'Help providers understand the issue better',
                    child: RequestMediaWidget(
                      attachedPaths: _attachedMediaPaths,
                      onMediaAdded: _onMediaAdded,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 6: Location
                  _SectionCard(
                    title: 'Service Location',
                    iconName: 'location_on',
                    child: const RequestLocationWidget(),
                  ),

                  SizedBox(height: 100 + bottomPadding),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              disabledBackgroundColor: AppTheme.primary.withAlpha(153),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Submit Request',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── AI Hint Banner ───────────────────────────────────────────────────────────
class _AiHintBanner extends StatelessWidget {
  final String hint;
  const _AiHintBanner({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1565C0).withAlpha(51)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF1565C0), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hint,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1565C0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Card Wrapper ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final String iconName;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.iconName,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppTheme.primary, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _iconFromName(iconName),
                    color: AppTheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
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
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'category':
        return Icons.category_outlined;
      case 'description':
        return Icons.description_outlined;
      case 'priority_high':
        return Icons.priority_high_rounded;
      case 'calendar_today':
        return Icons.calendar_today_outlined;
      case 'photo_camera':
        return Icons.photo_camera_outlined;
      case 'location_on':
        return Icons.location_on_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
