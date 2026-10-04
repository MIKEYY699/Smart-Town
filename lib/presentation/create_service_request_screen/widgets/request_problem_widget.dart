import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class RequestProblemWidget extends StatefulWidget {
  final ValueChanged<String> onDescriptionChanged;
  final bool isTablet;

  const RequestProblemWidget({
    required this.onDescriptionChanged,
    required this.isTablet,
    super.key,
  });

  @override
  State<RequestProblemWidget> createState() => _RequestProblemWidgetState();
}

class _RequestProblemWidgetState extends State<RequestProblemWidget> {
  final _controller = TextEditingController();
  int _charCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          maxLines: widget.isTablet ? 5 : 4,
          maxLength: 500,
          buildCounter:
              (_, {required currentLength, required isFocused, maxLength}) =>
                  null,
          onChanged: (val) {
            setState(() => _charCount = val.length);
            widget.onDescriptionChanged(val);
          },
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please describe the problem';
            }
            if (val.trim().length < 10) {
              return 'Please provide more detail (at least 10 characters)';
            }
            return null;
          },
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF1A1A1A),
          ),
          decoration: InputDecoration(
            hintText:
                'e.g. Kitchen ka nal leak ho raha hai, pani neeche aa raha hai...',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFFBBBBBB),
              height: 1.5,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Describe in Urdu or English',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            Text(
              '$_charCount / 500',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: _charCount > 450
                    ? AppTheme.warning
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
