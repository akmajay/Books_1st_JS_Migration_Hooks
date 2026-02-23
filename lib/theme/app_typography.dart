import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme get textTheme => TextTheme(
    // Display
    displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
    
    // Headlines
    headlineLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600),
    
    // Titles
    titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
    titleSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
    
    // Body
    bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
    
    // Labels
    labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
  );
}
