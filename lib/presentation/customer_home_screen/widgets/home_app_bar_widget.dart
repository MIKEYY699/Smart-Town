import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/avatar_widget.dart';
import '../../../widgets/custom_icon_widget.dart';

class HomeAppBarWidget extends StatelessWidget {
  final String userName;
  final String community;
  final VoidCallback onNotificationTap;
  final VoidCallback onAvatarTap;
  final VoidCallback? onMenuTap;
  final int unreadCount;
  final String? avatarUrl;

  const HomeAppBarWidget({
    required this.userName,
    required this.community,
    required this.onNotificationTap,
    required this.onAvatarTap,
    this.onMenuTap,
    this.unreadCount = 0,
    this.avatarUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          // Side menu button
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: AppTheme.primary, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                Text(
                  userName.isEmpty ? ' ' : userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: onNotificationTap,
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: 'notifications_outlined',
                    color: const Color(0xFF1A1A1A),
                    size: 22,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // The user's own profile photo
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
              child: AvatarWidget(
                name: userName,
                imageUrl: avatarUrl,
                radius: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
