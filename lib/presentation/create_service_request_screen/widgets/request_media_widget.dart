import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_theme.dart';

/// Lets the customer attach one photo of the problem.
class RequestMediaWidget extends StatelessWidget {
  final List<String> attachedPaths;
  final ValueChanged<String> onMediaAdded;
  final ValueChanged<String>? onMediaRemoved;

  const RequestMediaWidget({
    required this.attachedPaths,
    required this.onMediaAdded,
    this.onMediaRemoved,
    super.key,
  });

  Future<void> _pickPhoto(BuildContext context) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked != null) {
        onMediaAdded(picked.path);
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open your photos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Add button (only while no photo is attached)
              if (attachedPaths.isEmpty)
                GestureDetector(
                  onTap: () => _pickPhoto(context),
                  child: Container(
                    width: 72,
                    height: 72,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primary.withAlpha(102),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate,
                          color: AppTheme.primary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Attached photo
              ...attachedPaths.map(
                (path) => Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.image, color: Color(0xFF9E9E9E)),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onMediaRemoved?.call(path),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add one photo. It helps providers understand the problem.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}