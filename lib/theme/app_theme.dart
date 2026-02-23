import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'component_themes.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = AppColors.lightScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: AppTypography.textTheme,
      appBarTheme: ComponentThemes.appBar(scheme),
      cardTheme: ComponentThemes.card(scheme),
      elevatedButtonTheme: ComponentThemes.elevatedButton(scheme),
      outlinedButtonTheme: ComponentThemes.outlinedButton(scheme),
      inputDecorationTheme: ComponentThemes.inputDecoration(scheme),
      bottomNavigationBarTheme: ComponentThemes.bottomNav(scheme),
      chipTheme: ComponentThemes.chip(scheme),
      bottomSheetTheme: ComponentThemes.bottomSheet(scheme),
      floatingActionButtonTheme: ComponentThemes.fab(scheme),
      dividerTheme: DividerThemeData(color: scheme.outline.withAlpha((0.3 * 255).round())),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  static ThemeData dark() {
    final scheme = AppColors.darkScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.darkOnSurface,
        displayColor: AppColors.darkOnSurface,
      ),
      appBarTheme: ComponentThemes.appBar(scheme),
      cardTheme: ComponentThemes.card(scheme),
      elevatedButtonTheme: ComponentThemes.elevatedButton(scheme),
      outlinedButtonTheme: ComponentThemes.outlinedButton(scheme),
      inputDecorationTheme: ComponentThemes.inputDecoration(scheme),
      bottomNavigationBarTheme: ComponentThemes.bottomNav(scheme),
      chipTheme: ComponentThemes.chip(scheme),
      bottomSheetTheme: ComponentThemes.bottomSheet(scheme),
      floatingActionButtonTheme: ComponentThemes.fab(scheme),
      dividerTheme: DividerThemeData(color: scheme.outline.withAlpha((0.3 * 255).round())),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
