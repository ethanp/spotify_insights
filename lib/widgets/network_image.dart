import 'package:flutter/cupertino.dart';
import 'package:spotify_insights/theme/app_theme.dart';

enum ImageShape { circle, rounded }

class SpotifyImage extends StatelessWidget {
  final String? url;
  final double size;
  final IconData fallbackIcon;
  final ImageShape shape;
  final double borderRadius;

  const SpotifyImage({
    required this.url,
    this.size = 48,
    this.fallbackIcon = CupertinoIcons.music_note,
    this.shape = ImageShape.rounded,
    this.borderRadius = 4,
  });

  const SpotifyImage.circle({
    required this.url,
    this.size = 48,
    this.fallbackIcon = CupertinoIcons.person_fill,
  })  : shape = ImageShape.circle,
        borderRadius = 0;

  const SpotifyImage.album({
    required this.url,
    this.size = 48,
  })  : shape = ImageShape.rounded,
        borderRadius = 4,
        fallbackIcon = CupertinoIcons.music_note;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: size,
      height: size,
      color: AppColors.backgroundDepth3,
      child: url != null
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );

    return shape == ImageShape.circle
        ? ClipOval(child: child)
        : ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: child);
  }

  Widget _placeholder() => Center(
        child: Icon(fallbackIcon, size: size * 0.5, color: AppColors.textColor3),
      );
}

