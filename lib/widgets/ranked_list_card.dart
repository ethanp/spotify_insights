import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:spotify_insights/theme/app_theme.dart';

class RankedListCard<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelFor;
  final String Function(T) valueFor;
  final String? Function(T)? subtitleFor;
  final void Function(T)? onItemTap;
  final VoidCallback? onSeeAll;
  final int maxItems;

  const RankedListCard({
    super.key,
    required this.title,
    required this.items,
    required this.labelFor,
    required this.valueFor,
    this.subtitleFor,
    this.onItemTap,
    this.onSeeAll,
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = items.take(maxItems).toList();

    return Container(
      decoration: AppComponents.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTypography.headlineSmall),
                if (onSeeAll != null && items.length > maxItems)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onSeeAll,
                    child: Text(
                      'See all',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (displayItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No data available', style: AppTypography.bodySmall),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppColors.borderDepth1,
              ),
              itemBuilder: (context, index) {
                final item = displayItems[index];
                final subtitle = subtitleFor?.call(item);
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onItemTap != null ? () => onItemTap!(item) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${index + 1}',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textColor3,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                labelFor(item),
                                style: AppTypography.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subtitle != null)
                                Text(
                                  subtitle,
                                  style: AppTypography.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          valueFor(item),
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        if (onItemTap != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                            color: AppColors.textColor3,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
