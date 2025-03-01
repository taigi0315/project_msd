import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 앱 전체의 테마와 색상을 정의하는 클래스
/// 중세 판타지 스타일의 디자인을 위한 색상과 텍스트 스타일을 포함합니다.
class AppTheme {
  // 디버깅을 위한 출력
  static void _debugPrint(String message) {
    // ignore: avoid_print
    print('🎨 AppTheme: $message');
  }

  // 앱의 주요 색상
  static const Color primaryColor = Color(0xFF8C3D2B); // 고대 붉은색
  static const Color secondaryColor = Color(0xFFD4AF37); // 금색
  static const Color backgroundColor = Color(0xFFF5E9D1); // 양피지 색상
  static const Color textColor = Color(0xFF2D2D2D); // 깊은 검정색
  static const Color accentColor = Color(0xFF3E6A63); // 포레스트 그린
  static const Color cardColor = Colors.white; // 카드 배경색

  // 수치 색상 
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF2196F3);

  // 레벨 진행률을 나타내는 색상
  static const Color experienceColor = Color(0xFF8C6D2E);
  
  // 각 클랜 멤버 역할에 대한 색상
  static const Map<String, Color> roleColors = {
    'leader': Color(0xFFCA8A04), // 골드 - 리더
    'warrior': Color(0xFFB91C1C), // 레드 - 전사
    'mage': Color(0xFF1D4ED8), // 블루 - 메이지
    'healer': Color(0xFF15803D), // 그린 - 힐러
    'scout': Color(0xFF7E22CE), // 퍼플 - 정찰병
  };

  // 텍스트 테마 정의
  static TextTheme getTextTheme() {
    _debugPrint('텍스트 테마 생성');
    return TextTheme(
      displayLarge: GoogleFonts.cinzel(
        fontSize: 32, 
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.cinzel(
        fontSize: 28, 
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: GoogleFonts.cinzel(
        fontSize: 24, 
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.cinzel(
        fontSize: 22, 
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.cinzel(
        fontSize: 20, 
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.cinzel(
        fontSize: 18, 
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.lato(
        fontSize: 18, 
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.lato(
        fontSize: 16, 
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.lato(
        fontSize: 14, 
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16, 
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14, 
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12, 
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
    );
  }

  // 앱 테마 생성
  static ThemeData getAppTheme() {
    _debugPrint('앱 테마 생성');
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      hintColor: secondaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: textColor,
        onError: Colors.white,
      ),
      textTheme: getTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: errorColor, width: 1.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
} 