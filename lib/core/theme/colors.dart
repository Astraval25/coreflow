import 'dart:ui';

class LoginColors {
  // PRIMARY BRAND COLORS
  static const Color primary = Color(0xFF6366F1);        // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8);   // Indigo 400
  static const Color primaryDark = Color(0xFF4F46E5);    // Indigo 600
  
  //  ACCENT COLORS
  static const Color accent = Color(0xFFEC4899);         // Pink 500
  static const Color accentLight = Color(0xFFF472B6);    // Pink 400
  
  // NEUTRAL BACKGROUND
  static const Color background = Color(0xFFFAFAFA);     // Gray 50
  static const Color surface = Color(0xFFFFFFFF);        // White
  static const Color surfaceSecondary = Color(0xFFF8FAFC); // Slate 50
  
  // FIELD & CARD COLORS
  static const Color fieldFill = Color(0xFFF8FAFC);      // Slate 50
  static const Color fieldFillFocus = Color(0xFFEEF2FF); // Indigo 50
  static const Color cardBackground = Color(0xFFFFFFFF); // White
  
  //  BORDER COLORS
  static const Color border = Color(0xFFE2E8F0);         // Slate 200
  static const Color borderFocus = Color(0xFFCBD5E1);    // Slate 300
  static const Color borderLight = Color(0xFFF1F5F9);    // Slate 100
  
  // TEXT COLORS
  static const Color textPrimary = Color(0xFF0F172A);    // Slate 900
  static const Color textSecondary = Color(0xFF64748B);  // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8);   // Slate 400
  
  // SUCCESS / ERROR COLORS
  static const Color success = Color(0xFF10B981);        // Emerald 500
  static const Color successLight = Color(0xFF34D399);   // Emerald 400
  static const Color error = Color(0xFFEF4444);          // Red 500
  static const Color errorLight = Color(0xF87171);       // Red 400
  
  //  SHADOW COLORS
  static const Color shadowLight = Color(0xFFCBD5E1);    // Slate 300
  static const Color shadowDark = Color(0xFF334155);     // Slate 700
}

class DashboardColors {
  //  DASHBOARD PRIMARY (Same as Login)
  static const Color primary = LoginColors.primary;
  static const Color primaryLight = LoginColors.primaryLight;
  static const Color primaryDark = LoginColors.primaryDark;
  
  //  DASHBOARD SPECIFIC
  static const Color dashboardBg = Color(0xFFF8FAFC);    // Slate 50
  static const Color sidebarBg = Color(0xFFFFFFFF);      // White
  static const Color headerGradientStart = Color(0xFF6366F1); // Indigo 500
  static const Color headerGradientEnd = Color(0xFF4F46E5);   // Indigo 600

   static const Color addIcon = Color.fromARGB(255, 218, 217, 226); 
}
