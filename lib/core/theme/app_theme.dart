import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'app_colors.dart';

/// Tema personalizado da aplicação (Material Design 3).
///
/// Expõe [light] e [dark] a partir de uma base comum, para que a identidade
/// visual seja consistente e a manutenção fique em um único lugar. A escolha
/// entre claro/escuro é controlada pelo `themeModeProvider`.
class AppTheme {
  AppTheme._();

  /// Tipografia global compartilhada pelos dois temas.
  static const TextTheme _textTheme = TextTheme(
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    titleMedium: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
    bodyMedium: TextStyle(fontSize: 14, height: 1.4),
    bodySmall: TextStyle(fontSize: 13),
    labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  );

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? AppColors.primaryDarkMode : AppColors.primary,
      surface: isDark ? AppColors.surfaceDark : AppColors.surface,
      error: AppColors.danger,
    );

    final Color borderColor =
        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08);

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: _textTheme.apply(
        bodyColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        displayColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(color: borderColor),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primary,
        showCheckmark: false,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
