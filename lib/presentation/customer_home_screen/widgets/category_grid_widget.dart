import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/custom_image_widget.dart';

class _CategoryItem {
  final String id;
  final String name;
  final String imageUrl;
  final String semanticLabel;

  const _CategoryItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.semanticLabel,
  });
}

class CategoryGridWidget extends StatefulWidget {
  final bool isTablet;
  final void Function(String categoryId, String categoryName) onCategoryTap;

  const CategoryGridWidget({
    required this.isTablet,
    required this.onCategoryTap,
    super.key,
  });

  @override
  State<CategoryGridWidget> createState() => _CategoryGridWidgetState();
}

class _CategoryGridWidgetState extends State<CategoryGridWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  // TODO: Replace with Riverpod/Bloc for production

  static const List<_CategoryItem> _categories = [
    _CategoryItem(
      id: 'plumbing',
      name: 'Plumbing',
      imageUrl:
          'https://images.pexels.com/photos/2988232/pexels-photo-2988232.jpeg',
      semanticLabel: 'Plumber fixing pipe under sink with tools',
    ),
    _CategoryItem(
      id: 'electrical',
      name: 'Electrical',
      imageUrl:
          'https://images.pexels.com/photos/2219024/pexels-photo-2219024.jpeg',
      semanticLabel:
          'Electrician working on electrical panel with safety equipment',
    ),
    _CategoryItem(
      id: 'ac_repair',
      name: 'AC & Repair',
      imageUrl:
          'https://images.pexels.com/photos/4489732/pexels-photo-4489732.jpeg',
      semanticLabel: 'Technician in orange uniform repairing AC unit on wall',
    ),
    _CategoryItem(
      id: 'carpentry',
      name: 'Carpentry',
      imageUrl:
          'https://images.pexels.com/photos/3637786/pexels-photo-3637786.jpeg',
      semanticLabel: 'Carpenter measuring and cutting wood in workshop',
    ),
    _CategoryItem(
      id: 'painting',
      name: 'Painting',
      imageUrl:
          'https://images.pexels.com/photos/2219024/pexels-photo-2219024.jpeg',
      semanticLabel: 'Painter applying white paint to wall with roller',
    ),
    _CategoryItem(
      id: 'cleaning',
      name: 'Cleaning',
      imageUrl:
          'https://images.pexels.com/photos/4099354/pexels-photo-4099354.jpeg',
      semanticLabel: 'Professional cleaner in uniform mopping floor',
    ),
    _CategoryItem(
      id: 'locksmith',
      name: 'Locksmith',
      imageUrl:
          'https://images.pexels.com/photos/4386370/pexels-photo-4386370.jpeg',
      semanticLabel: 'Locksmith working on door lock with specialized tools',
    ),
    _CategoryItem(
      id: 'mobile_repair',
      name: 'Mobile Repair',
      imageUrl:
          'https://images.pexels.com/photos/2219024/pexels-photo-2219024.jpeg',
      semanticLabel:
          'Technician repairing smartphone with small tools on workbench',
    ),
    _CategoryItem(
      id: 'mason',
      name: 'Masonry',
      imageUrl:
          'https://images.pexels.com/photos/2219024/pexels-photo-2219024.jpeg',
      semanticLabel:
          'Mason laying bricks with trowel and mortar on construction site',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = widget.isTablet ? 4 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'See all',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE8650A),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final delay = index * 60;
              return AnimatedBuilder(
                animation: _entranceController,
                builder: (_, child) {
                  final start = (delay / 600.0).clamp(0.0, 1.0);
                  final end = ((delay + 300) / 600.0).clamp(0.0, 1.0);
                  final progress = CurvedAnimation(
                    parent: _entranceController,
                    curve: Interval(start, end, curve: Curves.easeOutCubic),
                  ).value;
                  return Opacity(
                    opacity: progress,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - progress)),
                      child: child,
                    ),
                  );
                },
                child: _CategoryCard(
                  item: _categories[index],
                  onTap: () => widget.onCategoryTap(
                    _categories[index].id,
                    _categories[index].name,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem item;
  final VoidCallback onTap;

  const _CategoryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomImageWidget(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              semanticLabel: item.semanticLabel,
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withAlpha(166)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Label
            Positioned(
              bottom: 10,
              left: 8,
              right: 8,
              child: Text(
                item.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
