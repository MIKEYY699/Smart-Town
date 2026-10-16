import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.background,
    required this.foreground,
  });
}

/// Clean icon tiles for every service category (no stock photos).
class CategoryGridWidget extends StatelessWidget {
  final bool isTablet;
  final void Function(String categoryId, String categoryName) onCategoryTap;

  const CategoryGridWidget({
    required this.isTablet,
    required this.onCategoryTap,
    super.key,
  });

  static const List<_CategoryItem> _categories = [
    _CategoryItem(
      id: 'plumbing',
      name: 'Plumbing',
      icon: Icons.plumbing,
      background: Color(0xFFE3F2FD),
      foreground: Color(0xFF1565C0),
    ),
    _CategoryItem(
      id: 'electrical',
      name: 'Electrical',
      icon: Icons.electrical_services,
      background: Color(0xFFFFF8E1),
      foreground: Color(0xFFF59E0B),
    ),
    _CategoryItem(
      id: 'ac_repair',
      name: 'AC Repair',
      icon: Icons.ac_unit,
      background: Color(0xFFE0F7FA),
      foreground: Color(0xFF00838F),
    ),
    _CategoryItem(
      id: 'carpentry',
      name: 'Carpentry',
      icon: Icons.carpenter,
      background: Color(0xFFEFEBE9),
      foreground: Color(0xFF6D4C41),
    ),
    _CategoryItem(
      id: 'painting',
      name: 'Painting',
      icon: Icons.format_paint,
      background: Color(0xFFF3E5F5),
      foreground: Color(0xFF8E24AA),
    ),
    _CategoryItem(
      id: 'cleaning',
      name: 'Cleaning',
      icon: Icons.cleaning_services,
      background: Color(0xFFE8F5E9),
      foreground: Color(0xFF2E7D32),
    ),
    _CategoryItem(
      id: 'locksmith',
      name: 'Locksmith',
      icon: Icons.lock_open,
      background: Color(0xFFECEFF1),
      foreground: Color(0xFF455A64),
    ),
    _CategoryItem(
      id: 'appliance',
      name: 'Appliance',
      icon: Icons.kitchen,
      background: Color(0xFFFCE4EC),
      foreground: Color(0xFFD81B60),
    ),
    _CategoryItem(
      id: 'mobile_repair',
      name: 'Mobile Repair',
      icon: Icons.phone_android,
      background: Color(0xFFE8EAF6),
      foreground: Color(0xFF3949AB),
    ),
    _CategoryItem(
      id: 'tutor',
      name: 'Tutor',
      icon: Icons.school,
      background: Color(0xFFFFF3E0),
      foreground: Color(0xFFE8650A),
    ),
    _CategoryItem(
      id: 'mason',
      name: 'Masonry',
      icon: Icons.foundation,
      background: Color(0xFFFBE9E7),
      foreground: Color(0xFFD84315),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'Categories',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 4 : 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final item = _categories[index];
              return _CategoryTile(
                item: item,
                onTap: () => onCategoryTap(item.id, item.name),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final _CategoryItem item;
  final VoidCallback onTap;

  const _CategoryTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${item.name} providers',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: item.background,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.foreground, size: 26),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
