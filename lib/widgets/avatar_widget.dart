import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Bumped whenever the user changes their name or photo, so other screens
/// (like the home screen) know to reload.
final ValueNotifier<int> profileChangedNotifier = ValueNotifier<int>(0);

/// A round profile picture. Shows the first letter of the name when the
/// person has not uploaded a photo (or the photo cannot load).
class AvatarWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;

  const AvatarWidget({
    required this.name,
    this.imageUrl,
    this.radius = 28,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
    final url = imageUrl;
    final hasPhoto = url != null && url.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.primaryContainer,
      foregroundImage: hasPhoto ? NetworkImage(url) : null,
      onForegroundImageError: hasPhoto ? (Object error, StackTrace? stack) {} : null,
      child: Text(
        initial,
        style: GoogleFonts.plusJakartaSans(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
