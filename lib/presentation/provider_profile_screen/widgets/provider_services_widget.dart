import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class _ServiceItem {
  final String name;
  final String priceRange;
  final bool available;
  final String iconName;

  const _ServiceItem({
    required this.name,
    required this.priceRange,
    required this.available,
    required this.iconName,
  });
}

class ProviderServicesWidget extends StatelessWidget {
  const ProviderServicesWidget({super.key});

  static const List<_ServiceItem> _services = [
    _ServiceItem(
      name: 'AC Installation',
      priceRange: 'Rs. 1,500 – 3,000',
      available: true,
      iconName: 'ac_unit',
    ),
    _ServiceItem(
      name: 'AC Gas Refilling',
      priceRange: 'Rs. 2,000 – 4,500',
      available: true,
      iconName: 'air',
    ),
    _ServiceItem(
      name: 'AC Servicing / Wash',
      priceRange: 'Rs. 800 – 1,500',
      available: true,
      iconName: 'cleaning_services',
    ),
    _ServiceItem(
      name: 'AC Repair',
      priceRange: 'Rs. 500 onwards',
      available: false,
      iconName: 'build',
    ),
    _ServiceItem(
      name: 'AC Uninstallation',
      priceRange: 'Rs. 500 – 1,000',
      available: true,
      iconName: 'power_off',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Services Offered',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
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
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._services.map((s) => _ServiceRow(service: s)),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final _ServiceItem service;

  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: service.available
                  ? AppTheme.primaryMuted
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomIconWidget(
              iconName: service.iconName,
              color: service.available
                  ? AppTheme.primary
                  : const Color(0xFF9E9E9E),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  service.priceRange,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: service.available
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              service.available ? 'Available' : 'Unavailable',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: service.available
                    ? const Color(0xFF2D7A4F)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
