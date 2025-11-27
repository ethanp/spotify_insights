import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_insights/providers/sync_provider.dart';
import 'package:spotify_insights/screens/analytics_screen.dart';
import 'package:spotify_insights/screens/listening_screen.dart';
import 'package:spotify_insights/screens/playlists_screen.dart';
import 'package:spotify_insights/theme/app_theme.dart';

class MainTabScreen extends ConsumerStatefulWidget {
  const MainTabScreen();

  @override
  ConsumerState<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends ConsumerState<MainTabScreen>
    with TickerProviderStateMixin {
  int currentTabIndex = 0;
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    fadeController = AnimationController(
      duration: AppAnimation.medium,
      vsync: this,
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: fadeController, curve: AppAnimation.curve),
    );
    fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncNotifierProvider.notifier).sync();
    });
  }

  @override
  void dispose() {
    fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppComponents.backgroundGradient,
      ),
      child: CupertinoTabScaffold(
        tabBar: mainTabBar(),
        tabBuilder: (context, index) => tabView(index),
      ),
    );
  }

  CupertinoTabBar mainTabBar() {
    return CupertinoTabBar(
      currentIndex: currentTabIndex,
      onTap: (int index) {
        setState(() => currentTabIndex = index);
        fadeController.reset();
        fadeController.forward();
      },
      backgroundColor: Colors.transparent,
      activeColor: AppColors.primary,
      inactiveColor: AppColors.textColor3,
      border: Border(
        top: BorderSide(
          color: AppColors.borderDepth1.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.chart_bar),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.headphones),
          label: 'Listening',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.music_albums),
          label: 'Playlists',
        ),
      ],
    );
  }

  Widget tabView(int index) {
    return CupertinoTabView(
      builder: (context) => FadeTransition(
        opacity: fadeAnimation,
        child: switch (index) {
          0 => const AnalyticsScreen(),
          1 => const ListeningScreen(),
          2 => const PlaylistsScreen(),
          _ => const AnalyticsScreen(),
        },
      ),
    );
  }
}
