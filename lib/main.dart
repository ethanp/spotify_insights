import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_insights/providers/auth_provider.dart';
import 'package:spotify_insights/screens/auth_screen.dart';
import 'package:spotify_insights/screens/main_tab_screen.dart';
import 'package:spotify_insights/services/auth_service.dart';
import 'package:spotify_insights/services/local_database.dart';
import 'package:spotify_insights/theme/app_theme.dart';
import 'package:spotify_insights/widgets/async_data_builder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await LocalDatabase.database;
  runApp(const ProviderScope(child: SpotifyInsightsApp()));
}

class SpotifyInsightsApp extends ConsumerWidget {
  const SpotifyInsightsApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoApp(
      title: 'Spotify Insights',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundDepth1,
        barBackgroundColor: AppColors.backgroundDepth2,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.primary,
          textStyle: TextStyle(color: AppColors.textColor1),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);

    return authAsync.when(
      data: (authState) => switch (authState) {
        AuthState.authenticated => const MainTabScreen(),
        AuthState.unauthenticated => const AuthScreen(),
        AuthState.unknown => const AuthScreen(),
      },
      loading: () => CupertinoPageScaffold(
        backgroundColor: AppColors.backgroundDepth1,
        child: const LoadingIndicator(message: 'Initializing...'),
      ),
      error: (error, _) => CupertinoPageScaffold(
        backgroundColor: AppColors.backgroundDepth1,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error', style: AppTypography.error),
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: () => ref.invalidate(authNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
