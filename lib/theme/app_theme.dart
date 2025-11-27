import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color primary = Color(0xFF1DB954);
  static const Color primaryLight = Color(0xFF1ED760);
  static const Color primaryDark = Color(0xFF169C46);

  static const Color secondary = Color(0xFF535353);
  static const Color accent = Color(0xFF1DB954);

  static const Color destructive = Color(0xFFE57373);
  static const Color success = Color(0xFF1DB954);
  static const Color warning = Color(0xFFFFB74D);

  static const Color backgroundDepth1 = Color(0xFF121212);
  static const Color backgroundDepth2 = Color(0xFF181818);
  static const Color backgroundDepth3 = Color(0xFF282828);
  static const Color backgroundDepth4 = Color(0xFF3E3E3E);
  static const Color backgroundDepth5 = Color(0xFF535353);

  static const Color textColor1 = Color(0xFFFFFFFF);
  static const Color textColor2 = Color(0xFFB3B3B3);
  static const Color textColor3 = Color(0xFF727272);
  static const Color textColor4 = Color(0xFF535353);

  static const Color borderDepth1 = Color(0xFF282828);
  static const Color borderDepth2 = Color(0xFF3E3E3E);
  static const Color borderDepth3 = Color(0xFF535353);
}

class AppTypography {
  static TextStyle get headlineLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textColor1,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get headlineMedium => headlineLarge.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get headlineSmall =>
      headlineMedium.copyWith(fontSize: 20, height: 1.4);

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor1,
    height: 1.5,
  );

  static TextStyle get bodyMedium => bodyLarge.copyWith(fontSize: 16);

  static TextStyle get bodySmall =>
      bodyMedium.copyWith(fontSize: 14, color: AppColors.textColor2);

  static TextStyle get labelLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor1,
    height: 1.4,
  );

  static TextStyle get labelMedium =>
      labelLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle get labelSmall =>
      labelMedium.copyWith(fontSize: 12, color: AppColors.textColor2);

  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor3,
    height: 1.4,
  );

  static TextStyle get error => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.destructive,
    height: 1.4,
  );

  static TextStyle get navTitle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor1,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 24.0;
}

class AppAnimation {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Curve curve = Curves.easeInOutCubic;
}

class AppComponents {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [AppColors.backgroundDepth1, AppColors.backgroundDepth2],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static BoxDecoration get card => BoxDecoration(
    color: AppColors.backgroundDepth2,
    borderRadius: BorderRadius.circular(AppRadius.medium),
    border: Border.all(color: AppColors.borderDepth1, width: 1),
  );

  static BoxDecoration get elevatedCard => BoxDecoration(
    color: AppColors.backgroundDepth3,
    borderRadius: BorderRadius.circular(AppRadius.medium),
    boxShadow: [
      BoxShadow(
        color: CupertinoColors.black.withValues(alpha: 0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
