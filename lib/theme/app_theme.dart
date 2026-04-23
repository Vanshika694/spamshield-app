import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === New Production Color Palette (Locked to Dark) ===
  static const Color bg         = Color(0xFF0F172A); 
  static const Color surface    = Color(0xFF1E293B); 
  static const Color card       = Color(0xFF1E293B); 
  static const Color cardAlt    = Color(0xFF263248); 
  static const Color primary    = Color(0xFF1D4ED8); 
  static const Color accent     = Color(0xFF38BDF8); 
  static const Color accentSoft = Color(0xFF7DD3FC); 
  static const Color spamRed    = Color(0xFFEF4444); 
  static const Color hamGreen   = Color(0xFF22C55E); 
  static const Color warnYellow = Color(0xFFF59E0B); 
  static const Color purple     = Color(0xFF818CF8); 
  static const Color textPrimary   = Color(0xFFF1F5F9); 
  static const Color textSecondary = Color(0xFF94A3B8); 
  static const Color textMuted     = Color(0xFF475569); 
  static const Color border     = Color(0xFF1E3A5F); 

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
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF1D4ED8),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1D4ED8),
          secondary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
          error: Color(0xFFEF4444),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: const Color(0xFFF1F5F9),
          displayColor: const Color(0xFFF1F5F9),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF1E3A5F)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E293B),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
          ),
          hintStyle: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 14),
          labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
          prefixIconColor: const Color(0xFF475569),
          suffixIconColor: const Color(0xFF475569),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.inter(
            color: const Color(0xFFF1F5F9),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: Color(0xFFF1F5F9)),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1E293B),
          selectedItemColor: const Color(0xFF38BDF8),
          unselectedItemColor: const Color(0xFF475569),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D4ED8),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFF1E3A5F)),
      );
}
