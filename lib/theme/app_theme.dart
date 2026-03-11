import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === New Production Color Palette ===
  static const Color bg         = Color(0xFF0F172A); // Deep dark blue
  static const Color surface    = Color(0xFF1E293B); // Dark gray surface
  static const Color card       = Color(0xFF1E293B); // Card bg
  static const Color cardAlt    = Color(0xFF263248); // Slightly lighter card
  static const Color primary    = Color(0xFF1D4ED8); // Electric blue
  static const Color accent     = Color(0xFF38BDF8); // Neon cyan
  static const Color accentSoft = Color(0xFF7DD3FC); // Soft cyan
  static const Color spamRed    = Color(0xFFEF4444); // Red for spam
  static const Color hamGreen   = Color(0xFF22C55E); // Green for safe
  static const Color warnYellow = Color(0xFFF59E0B); // Warning yellow
  static const Color purple     = Color(0xFF818CF8); // Subtle purple accent
  static const Color textPrimary   = Color(0xFFF1F5F9); // Near-white
  static const Color textSecondary = Color(0xFF94A3B8); // Muted slate
  static const Color textMuted     = Color(0xFF475569); // Very muted
  static const Color border     = Color(0xFF1E3A5F); // Subtle border

  // Glass card decoration helper
  static BoxDecoration glassCard({Color? borderColor, double radius = 16}) =>
      BoxDecoration(
        color: card.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? border.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        primaryColor: primary,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: surface,
          error: spamRed,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: border.withValues(alpha: 0.5)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
          labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
          prefixIconColor: textMuted,
          suffixIconColor: textMuted,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surface,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.inter(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: accent,
          unselectedItemColor: textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        dividerTheme: DividerThemeData(color: border.withValues(alpha: 0.5)),
      );
}
