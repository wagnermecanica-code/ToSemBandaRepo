import 'package:flutter/material.dart';

class AppColors {
  // Primary – Teal suave (músico)
  static const Color primary = Color(0xFF00A699);
  static const Color primaryLight = Color(0xFFE8F7F5);
  static const Color primaryDark = Color(0xFF007F73);

  // Accent – Coral quente (banda)
  static const Color accent = Color(0xFFFF6F61);
  static const Color accentLight = Color(0xFFFFECEA);

  // Neutros
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Texto
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF717171);
  static const Color textHint = Color(0xFF9E9E9E);

  // Bordas e divisores
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFF0F0F0);

  // Feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFB8C00);

  // MaterialColor para tema
  static MaterialColor get primarySwatch => const MaterialColor(
        0xFF00A699,
        <int, Color>{
          50: Color(0xFFE8F7F5),
          100: Color(0xFFB2E8E2),
          200: Color(0xFF80D8D0),
          300: Color(0xFF4DC9BE),
          400: Color(0xFF26BAB0),
          500: Color(0xFF00A699),
          600: Color(0xFF009589),
          700: Color(0xFF007F73),
          800: Color(0xFF00695C),
          900: Color(0xFF004C3F),
        },
      );
}
