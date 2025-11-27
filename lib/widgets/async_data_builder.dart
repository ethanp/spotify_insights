import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_insights/theme/app_theme.dart';

class AsyncDataBuilder<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final String loadingMessage;
  final VoidCallback? onRetry;

  const AsyncDataBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.loadingMessage = 'Loading...',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CupertinoActivityIndicator(radius: 16),
            const SizedBox(height: 16),
            Text(loadingMessage, style: AppTypography.bodySmall),
          ],
        ),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: AppTypography.error,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(radius: 16),
          const SizedBox(height: 16),
          Text(message, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = CupertinoIcons.music_note_list,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textColor3),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

