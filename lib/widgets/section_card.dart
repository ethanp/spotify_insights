import 'package:flutter/cupertino.dart';
import 'package:spotify_insights/theme/app_theme.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets? margin;

  const SectionCard({
    required this.title,
    required this.child,
    this.trailing,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Container(
        decoration: AppComponents.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.m),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTypography.headlineSmall),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            child,
            SizedBox(height: AppSpacing.s),
          ],
        ),
      ),
    );
  }
}

