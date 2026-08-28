import 'package:flutter/material.dart';
import 'package:xplore_app/config/theme.dart';
import 'package:xplore_app/config/string_utils.dart';

class RegisteredEventCard extends StatelessWidget {
  final String imagelocation;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final double cardWidth;

  const RegisteredEventCard({
    super.key,
    required this.imagelocation,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.cardWidth = 148.0,
  });

  Widget _buildImageWidget(String loc) {
    final formatted = formatImageUrl(loc);
    if (formatted.isEmpty) {
      return Image.asset(
        'assets/octave.png',
        fit: BoxFit.cover,
      );
    }
    if (formatted.startsWith('http://') || formatted.startsWith('https://')) {
      return Image.network(
        formatted,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/octave.png',
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      formatted,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/octave.png',
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Spotify style square artwork cover
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildImageWidget(imagelocation),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle.isNotEmpty ? subtitle : "Registered",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
