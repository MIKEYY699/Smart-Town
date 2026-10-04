import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import './custom_icon_widget.dart';

class _TabSpec {
  final String label;
  final String iconName;
  final String selectedIconName;
  final int? branchIndex;

  const _TabSpec({
    required this.label,
    required this.iconName,
    required this.selectedIconName,
    this.branchIndex,
  });
}

// V2 — Floating Pill BottomNav
class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavigation({required this.navigationShell, super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedVisualIndex = 0;

  static const List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'Home',
      iconName: 'home_outlined',
      selectedIconName: 'home',
      branchIndex: 0,
    ),
    _TabSpec(
      label: 'Services',
      iconName: 'construction_outlined',
      selectedIconName: 'construction',
      branchIndex: 1,
    ),
    _TabSpec(
      label: 'Requests',
      iconName: 'assignment_outlined',
      selectedIconName: 'assignment',
      branchIndex: 2,
    ),
    _TabSpec(
      label: 'Profile',
      iconName: 'person_outline',
      selectedIconName: 'person',
      branchIndex: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(24, 0, 24, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(31),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final isActive = i == _selectedVisualIndex;
            final isStub = tab.branchIndex == null;

            return GestureDetector(
              onTap: () {
                if (isStub) return;
                setState(() => _selectedVisualIndex = i);
                widget.navigationShell.goBranch(
                  tab.branchIndex!,
                  initialLocation:
                      tab.branchIndex == widget.navigationShell.currentIndex,
                );
              },
              child: Opacity(
                opacity: isStub ? 0.4 : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: isActive
                            ? tab.selectedIconName
                            : tab.iconName,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF9E9E9E),
                        size: 22,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: isActive
                            ? Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  tab.label,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
