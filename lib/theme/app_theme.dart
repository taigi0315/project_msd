import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

/// App theme and color definitions
/// Bright, fun fantasy-style design with playful colors and text styles
class AppTheme {
  // Debug output helper
  static void _debugPrint(String message) {
    // ignore: avoid_print
    print('🎨 AppTheme: $message');
  }

  // Updated color palette - brighter and more playful
  static const Color primaryColor = Color(0xFF5E60CE); // Vibrant purple
  static const Color secondaryColor = Color(0xFFFFBE0B); // Sunny yellow
  static const Color backgroundColor = Color(0xFFF0F4FF); // Light sky blue
  static const Color textColor = Color(0xFF333333); // Softer black
  static const Color accentColor = Color(0xFF64DFDF); // Bright teal
  static const Color cardColor = Colors.white; // Card background

  // Status colors with more vibrant tones
  static const Color successColor = Color(0xFF4ADE80); // Brighter green
  static const Color errorColor = Color(0xFFF87171); // Softer red
  static const Color warningColor = Color(0xFFFBBF24); // Bright amber
  static const Color infoColor = Color(0xFF60A5FA); // Friendly blue

  // XP progress color - more exciting
  static const Color experienceColor = Color(0xFFFF9F1C); // Bright orange
  
  // List of fun fantasy-themed colors for particles and effects
  static const List<Color> funColors = [
    Color(0xFFFF9F1C), // Orange
    Color(0xFF4ADE80), // Green
    Color(0xFF60A5FA), // Blue
    Color(0xFFFFBE0B), // Yellow
    Color(0xFF5E60CE), // Purple
    Color(0xFF64DFDF), // Teal
    Color(0xFFF87171), // Red
    Color(0xFFFFD166), // Gold
    Color(0xFFEF476F), // Pink
    Color(0xFF06D6A0), // Mint
  ];
  
  // Role colors - more vibrant and playful
  static const Map<String, Color> roleColors = {
    'leader': Color(0xFFFACC15), // Bright gold - Leader
    'warrior': Color(0xFFEF4444), // Vibrant red - Warrior
    'mage': Color(0xFF3B82F6), // Electric blue - Mage
    'healer': Color(0xFF10B981), // Emerald green - Healer
    'scout': Color(0xFF8B5CF6), // Vibrant purple - Scout
  };

  /// 재미있는 랜덤 색상을 생성합니다
  static Color getRandomColor() {
    final random = Random();
    return funColors[random.nextInt(funColors.length)];
  }

  // Text theme definition with more playful fonts
  static TextTheme getTextTheme() {
    _debugPrint('Creating text theme');
    return TextTheme(
      displayLarge: GoogleFonts.baloo2(
        fontSize: 32, 
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.baloo2(
        fontSize: 28, 
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: GoogleFonts.baloo2(
        fontSize: 24, 
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.baloo2(
        fontSize: 22, 
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.baloo2(
        fontSize: 20, 
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.baloo2(
        fontSize: 18, 
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.quicksand(
        fontSize: 18, 
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.quicksand(
        fontSize: 16, 
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.quicksand(
        fontSize: 14, 
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.quicksand(
        fontSize: 16, 
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.quicksand(
        fontSize: 14, 
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: GoogleFonts.quicksand(
        fontSize: 12, 
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
    );
  }
  
  // Get complete app theme
  static ThemeData getAppTheme() {
    _debugPrint('Creating app theme');
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textColor,
        onBackground: textColor,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      textTheme: getTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 3,
          textStyle: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          textStyle: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade300;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: backgroundColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: accentColor,
        contentTextStyle: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 