import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:spotify_insights/models/playlist_overlap.dart';
import 'package:spotify_insights/theme/app_theme.dart';

class OverlapChart extends StatelessWidget {
  final List<PlaylistOverlap> overlaps;
  final int maxItems;

  const OverlapChart({
    super.key,
    required this.overlaps,
    this.maxItems = 15,
  });

  @override
  Widget build(BuildContext context) {
    if (overlaps.isEmpty) return emptyState();

    final displayOverlaps = overlaps.take(maxItems).toList();

    return Container(
      decoration: AppComponents.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Highest Overlap Pairs', style: AppTypography.labelMedium),
                const SizedBox(height: 4),
                Text(
                  'Showing % of each playlist that overlaps with the other',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayOverlaps.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: AppColors.borderDepth1,
            ),
            itemBuilder: (context, index) => overlapRow(displayOverlaps[index]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget emptyState() {
    return Container(
      height: 120,
      decoration: AppComponents.card,
      child: Center(
        child: Text('No overlapping playlists found', style: AppTypography.bodySmall),
      ),
    );
  }

  Widget overlapRow(PlaylistOverlap overlap) {
    final sharedCount = overlap.sharedCount;

    final aIsSmaller = overlap.playlistASize <= overlap.playlistBSize;
    final leftName = aIsSmaller ? overlap.playlistAName : overlap.playlistBName;
    final leftSize = aIsSmaller ? overlap.playlistASize : overlap.playlistBSize;
    final rightName = aIsSmaller ? overlap.playlistBName : overlap.playlistAName;
    final rightSize = aIsSmaller ? overlap.playlistBSize : overlap.playlistASize;

    final leftPercent = leftSize > 0 ? (sharedCount / leftSize) * 100 : 0.0;
    final rightPercent = rightSize > 0 ? (sharedCount / rightSize) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$leftName ($leftSize)',
                  style: AppTypography.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  CupertinoIcons.arrow_right_arrow_left,
                  size: 14,
                  color: AppColors.textColor3,
                ),
              ),
              Expanded(
                child: Text(
                  '$rightName ($rightSize)',
                  style: AppTypography.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${leftPercent.toStringAsFixed(1)}%',
                style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(child: overlapBar(leftPercent, rightPercent)),
              const SizedBox(width: 8),
              Text(
                '${rightPercent.toStringAsFixed(1)}%',
                style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '$sharedCount shared tracks',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget overlapBar(double leftPercent, double rightPercent) {
    final leftWidth = (leftPercent / 100).clamp(0.05, 1.0);
    final rightWidth = (rightPercent / 100).clamp(0.05, 1.0);

    return Row(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.backgroundDepth3,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(3)),
                ),
              ),
              FractionallySizedBox(
                widthFactor: leftWidth,
                alignment: Alignment.centerRight,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.6), AppColors.primary],
                    ),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(3)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(width: 2, height: 10, color: AppColors.textColor3),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.backgroundDepth3,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                ),
              ),
              FractionallySizedBox(
                widthFactor: rightWidth,
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
                    ),
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
