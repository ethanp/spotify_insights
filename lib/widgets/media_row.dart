import 'package:flutter/cupertino.dart';
import 'package:spotify_insights/theme/app_theme.dart';
import 'package:spotify_insights/widgets/network_image.dart';

class MediaRow extends StatelessWidget {
  final int? rank;
  final String? imageUrl;
  final ImageShape imageShape;
  final IconData fallbackIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const MediaRow({
    this.rank,
    this.imageUrl,
    this.imageShape = ImageShape.rounded,
    this.fallbackIcon = CupertinoIcons.music_note,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  const MediaRow.artist({
    this.rank,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  })  : imageShape = ImageShape.circle,
        fallbackIcon = CupertinoIcons.person_fill;

  const MediaRow.track({
    this.rank,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  })  : imageShape = ImageShape.rounded,
        fallbackIcon = CupertinoIcons.music_note;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s + 4),
      child: Row(
        children: [
          if (rank != null)
            SizedBox(
              width: 28,
              child: Text(
                '$rank',
                style: AppTypography.labelMedium.copyWith(color: AppColors.textColor3),
              ),
            ),
          SpotifyImage(
            url: imageUrl,
            shape: imageShape,
            fallbackIcon: fallbackIcon,
          ),
          SizedBox(width: AppSpacing.s + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: AppSpacing.s),
            trailing!,
          ],
          if (onTap != null) ...[
            SizedBox(width: AppSpacing.s),
            Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textColor3),
          ],
        ],
      ),
    );

    return onTap != null
        ? CupertinoButton(padding: EdgeInsets.zero, onPressed: onTap, child: content)
        : content;
  }
}

