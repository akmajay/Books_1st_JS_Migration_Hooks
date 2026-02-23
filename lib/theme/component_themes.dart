import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComponentThemes {
  static AppBarTheme appBar(ColorScheme scheme) => AppBarTheme(
    backgroundColor: scheme.surface,
    foregroundColor: scheme.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: false,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 20, fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
  );
  
  static CardThemeData card(ColorScheme scheme) => CardThemeData(
    color: scheme.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: scheme.outline.withAlpha((0.3 * 255).round())),
    ),
  );
  
  static ElevatedButtonThemeData elevatedButton(ColorScheme scheme) =>
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  
  static OutlinedButtonThemeData outlinedButton(ColorScheme scheme) =>
    OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  
  static InputDecorationTheme inputDecoration(ColorScheme scheme) =>
    InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withAlpha((0.5 * 255).round()),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  
  static BottomNavigationBarThemeData bottomNav(ColorScheme scheme) =>
    BottomNavigationBarThemeData(
      backgroundColor: scheme.surface,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.onSurface.withAlpha((0.5 * 255).round()),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  
  static ChipThemeData chip(ColorScheme scheme) => ChipThemeData(
    backgroundColor: scheme.surfaceContainerHighest,
    selectedColor: scheme.primary.withAlpha((0.15 * 255).round()),
    labelStyle: GoogleFonts.inter(fontSize: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  );
  
  static BottomSheetThemeData bottomSheet(ColorScheme scheme) =>
    BottomSheetThemeData(
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      dragHandleSize: const Size(32, 4),
      showDragHandle: true,
    );
  
  static FloatingActionButtonThemeData fab(ColorScheme scheme) =>
    FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
}
