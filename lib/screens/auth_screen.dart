import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_insights/providers/auth_provider.dart';
import 'package:spotify_insights/theme/app_theme.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDepth1,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(
                  CupertinoIcons.music_note_2,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text('Spotify Insights', style: AppTypography.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Analyze your playlists and discover patterns',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                authState.when(
                  data: (_) => signInButton(ref),
                  loading: () => const CupertinoActivityIndicator(),
                  error: (error, _) => Column(
                    children: [
                      Text(
                        'Error: $error',
                        style: AppTypography.error,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      signInButton(ref),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'Sign in with your Spotify account to get started',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget signInButton(WidgetRef ref) {
    return CupertinoButton(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadius.large),
      onPressed: () => ref.read(authNotifierProvider.notifier).signIn(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.music_note, color: CupertinoColors.black),
          const SizedBox(width: 8),
          Text(
            'Sign in with Spotify',
            style: AppTypography.labelLarge.copyWith(
              color: CupertinoColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

