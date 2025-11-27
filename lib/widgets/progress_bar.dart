import 'package:flutter/cupertino.dart';
import 'package:spotify_insights/theme/app_theme.dart';

class ProgressBar extends StatelessWidget {
  final String label;
  final String? value;
  final double fraction;
  final bool animate;

  const ProgressBar({
    required this.label,
    this.value,
    required this.fraction,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (value != null) Text(value!, style: AppTypography.caption),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.backgroundDepth3,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              animate
                  ? _AnimatedBar(fraction: fraction)
                  : _StaticBar(fraction: fraction),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaticBar extends StatelessWidget {
  final double fraction;
  const _StaticBar({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: fraction.clamp(0.0, 1.0),
      child: _barDecoration(),
    );
  }
}

class _AnimatedBar extends StatefulWidget {
  final double fraction;
  const _AnimatedBar({required this.fraction});

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousFraction = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: AppAnimation.medium, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.fraction)
        .animate(CurvedAnimation(parent: _controller, curve: AppAnimation.curve));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fraction != widget.fraction) {
      _previousFraction = _animation.value;
      _animation = Tween<double>(begin: _previousFraction, end: widget.fraction)
          .animate(CurvedAnimation(parent: _controller, curve: AppAnimation.curve));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _animation.value.clamp(0.0, 1.0),
        child: child,
      ),
      child: _barDecoration(),
    );
  }
}

Widget _barDecoration() => Container(
      height: 6,
      decoration: BoxDecoration(
        gradient: AppComponents.primaryGradient,
        borderRadius: BorderRadius.circular(3),
      ),
    );

