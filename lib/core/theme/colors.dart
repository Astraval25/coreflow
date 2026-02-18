import 'package:flutter/material.dart';

class LoginColors {
  static bool _isDark = false;
  static void setBrightness(Brightness brightness) {
    _isDark = brightness == Brightness.dark;
  }

  // PRIMARY BRAND COLORS (Constant across themes)
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600

  // ACCENT COLORS
  static const Color accent = Color(0xFFEC4899); // Pink 500
  static const Color accentLight = Color(0xFFF472B6); // Pink 400

  // NEUTRAL BACKGROUND
  static Color get background =>
      _isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA);
  static Color get surface =>
      _isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
  static Color get surfaceSecondary =>
      _isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC);

  // FIELD & CARD COLORS
  static Color get fieldFill =>
      _isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC);
  static Color get fieldFillFocus =>
      _isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF);
  static Color get cardBackground =>
      _isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  // BORDER COLORS
  static Color get border =>
      _isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get borderFocus =>
      _isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
  static Color get borderLight =>
      _isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

  // TEXT COLORS
  static Color get textPrimary =>
      _isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textSecondary =>
      _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get textTertiary =>
      _isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // SUCCESS / ERROR COLORS
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFF34D399); // Emerald 400
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFF87171); // Red 400

  // SHADOW COLORS
  static Color get shadowLight =>
      _isDark ? Colors.black.withOpacity(0.3) : const Color(0xFFCBD5E1);
  static Color get shadowDark =>
      _isDark ? Colors.black.withOpacity(0.5) : const Color(0xFF334155);
}

class DashboardColors {
  static const Color primary = LoginColors.primary;
  static const Color primaryLight = LoginColors.primaryLight;
  static const Color primaryDark = LoginColors.primaryDark;

  static Color get dashboardBg => LoginColors.background;
  static Color get sidebarBg => LoginColors.surface;
  static Color get cardBg => LoginColors.cardBackground;
  static Color get cardBorder => LoginColors.border.withOpacity(0.5);

  static Color get textPrimary => LoginColors.textPrimary;
  static Color get textSecondary => LoginColors.textSecondary;
  static Color get textWhite => Colors.white;

  static const Color headerGradientStart = Color(0xFF6366F1);
  static const Color headerGradientEnd = Color(0xFF4F46E5);

  static Color get addIcon => LoginColors.textTertiary.withOpacity(0.2);
}
