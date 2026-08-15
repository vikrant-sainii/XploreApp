import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xplore_app/config/theme.dart';
import 'package:xplore_app/config/string_utils.dart';

enum TrailingType { typeUpcoming, typeRegistered }

Widget buildTrailing(TrailingType type, VoidCallback? onTap) {
  switch (type) {
    case (TrailingType.typeUpcoming):
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "5:30 PM",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                FontAwesomeIcons.angleRight,
                size: 14,
                color: AppColors.primary,
              ),
              GestureDetector(
                onTap: onTap,
                child: const Text(
                  "See More Info",
                  style: TextStyle(
                    letterSpacing: -1,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    case (TrailingType.typeRegistered):
      return IconButton(
        onPressed: onTap,
        icon: const Icon(FontAwesomeIcons.angleRight),
        color: AppColors.primary,
      );
  }
}

class EventTile extends StatelessWidget {
  final String imagelocation, title, subtitle;
  final VoidCallback? onTap;
  final TrailingType type;

  const EventTile({
    super.key,
    required this.imagelocation,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.type,
  });

  Widget _buildImageWidget(String loc) {
    final formatted = formatImageUrl(loc);
    if (formatted.isEmpty) {
      return Image.asset(
        'assets/octave.png',
        width: 52,
        height: 52,
        fit: BoxFit.cover,
      );
    }
    if (formatted.startsWith('http://') || formatted.startsWith('https://')) {
      return Image.network(
        formatted,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/octave.png',
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      formatted,
      width: 52,
      height: 52,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/octave.png',
        width: 52,
        height: 52,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: 0.9 * maxWidth,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImageWidget(imagelocation),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                buildTrailing(type, onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class XploreTile extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;

  const XploreTile({
    super.key,
    this.onTap,
    this.title = "Xplore More",
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      height: 52,
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(
                  FontAwesomeIcons.angleRight,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
