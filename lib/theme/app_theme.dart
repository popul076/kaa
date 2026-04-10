import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);

  // Background
  static const Color bgDark = Color(0xFF0B1120);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgGray = Color(0xFFF1F5F9);

  // Text
  static const Color textPrimary = Color(0xFF1B2433);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Accent
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentGold = Color(0xFFD4A017);
  static const Color danger = Color(0xFFFF4D4F);
  static const Color success = Color(0xFF10B981);

  // Social
  static const Color kakao = Color(0xFFFEE500);
  static const Color kakaoText = Color(0xFF3C1E1E);
  static const Color naver = Color(0xFF03C75A);
  static const Color google = Color(0xFF4285F4);

  // Border
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFFCBD5E1);

  // Badge
  static const Color badgeCert = Color(0xFF1B2433);
  static const Color badgeNormal = Color(0xFF2563EB);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        background: AppColors.bgLight,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      fontFamily: 'NotoSansKR',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        // 상태바를 항상 검정 배경 + 흰색 아이콘으로 고정
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF000000),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'NotoSansKR',
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}
