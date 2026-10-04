import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';
import '../../../widgets/custom_icon_widget.dart';

class _Review {
  final String reviewerName;
  final String reviewerImageUrl;
  final String semanticLabel;
  final double rating;
  final String text;
  final String timeAgo;
  final String service;

  const _Review({
    required this.reviewerName,
    required this.reviewerImageUrl,
    required this.semanticLabel,
    required this.rating,
    required this.text,
    required this.timeAgo,
    required this.service,
  });
}

class ProviderReviewsWidget extends StatelessWidget {
  const ProviderReviewsWidget({super.key});

  static const List<_Review> _reviews = [
    _Review(
      reviewerName: 'Sana Khalid',
      reviewerImageUrl:
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
      semanticLabel: 'Pakistani woman Sana with dark hair smiling',
      rating: 5.0,
      text:
          'Excellent work! Asif installed our new AC perfectly. Very professional and completed the job quickly. Highly recommended.',
      timeAgo: '2 days ago',
      service: 'AC Installation',
    ),
    _Review(
      reviewerName: 'Faisal Nawaz',
      reviewerImageUrl:
          'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg',
      semanticLabel: 'Pakistani man Faisal in casual attire',
      rating: 4.0,
      text:
          'Good service overall. Gas refilling done properly. Came on time. Price was fair for the area.',
      timeAgo: '1 week ago',
      service: 'AC Gas Refilling',
    ),
    _Review(
      reviewerName: 'Rubab Fatima',
      reviewerImageUrl:
          'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg',
      semanticLabel: 'Woman Rubab with hijab smiling outdoors',
      rating: 5.0,
      text:
          'Very satisfied! He cleaned both our ACs thoroughly and they are running much better now. Will definitely book again.',
      timeAgo: '2 weeks ago',
      service: 'AC Servicing',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final avg = _reviews.fold(0.0, (s, r) => s + r.rating) / _reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
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
        const SizedBox(height: 10),
        // Rating summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryMuted,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (i) {
                      return CustomIconWidget(
                        iconName: i < avg.floor()
                            ? 'star'
                            : (i < avg ? 'star_half' : 'star_border'),
                        color: const Color(0xFFF59E0B),
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_reviews.length * 37} total reviews',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF5C5C5C),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._reviews.map((r) => _ReviewCard(review: r)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: CustomImageWidget(
                  imageUrl: review.reviewerImageUrl,
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  semanticLabel: review.semanticLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      review.service,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => CustomIconWidget(
                        iconName: i < review.rating.floor()
                            ? 'star'
                            : 'star_border',
                        color: const Color(0xFFF59E0B),
                        size: 13,
                      ),
                    ),
                  ),
                  Text(
                    review.timeAgo,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF5C5C5C),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
