import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/status_badge_widget.dart';

class ProviderHeroWidget extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback onShare;
  final bool isBookmarked;

  const ProviderHeroWidget({
    this.onBack,
    required this.onShare,
    required this.isBookmarked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = (screenHeight * 0.38).clamp(260.0, 360.0);

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomImageWidget(
            imageUrl:
                'https://images.pexels.com/photos/4489732/pexels-photo-4489732.jpeg',
            fit: BoxFit.cover,
            semanticLabel:
                'AC technician in orange uniform smiling with thumbs up, holding laptop',
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withAlpha(26),
                  Colors.transparent,
                  Colors.black.withAlpha(153),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onBack != null)
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: 'arrow_back_ios_new',
                          color: const Color(0xFF1A1A1A),
                          size: 18,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  GestureDetector(
                    onTap: onShare,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(230),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: isBookmarked ? 'bookmark' : 'bookmark_border',
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom provider name overlay
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Asif Raza',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CustomIconWidget(
                            iconName: 'verified',
                            color: const Color(0xFF60A5FA),
                            size: 20,
                          ),
                        ],
                      ),
                      Text(
                        'AC Installation Expert · Model Town',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.white.withAlpha(230),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadgeWidget(status: BadgeStatus.available),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
