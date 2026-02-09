import 'package:flutter/material.dart';

class AppTheme {
  // Primary: #D32F2F (Blood Red), Secondary: #FFEBEE (Light Red), Error: #B00020, Success: #17B26A
  static const Color primaryColor = Color(0xFFD32F2F); // Red 700
  static const Color secondaryColor =
      Color(0xFFEF5350); // Red 400 (lighter for contrast)
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF17B26A);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceVariantColor = Color(0xFFFAFAFA); // Almost white

  // Dark Mode Colors
  static const Color darkPrimaryColor =
      Color(0xFFFF6B6B); // Adjusted Red for Dark Mode
  static const Color darkSurfaceColor = Color(0xFF000000); // True Black
  static const Color darkSurfaceVariantColor =
      Color(0xFF121212); // Slightly lighter black for cards

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
        surfaceContainerHighest: surfaceVariantColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surfaceVariantColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryColor,
        primary: darkPrimaryColor,
        // secondary: secondaryColor, // Can adjust if needed
        error: errorColor,
        surface: darkSurfaceColor,
        surfaceContainerHighest: darkSurfaceVariantColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkSurfaceColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurfaceVariantColor, // Darker bar for dark mode
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceVariantColor,
        elevation:
            0, // Flat look often better in dark mode, or keep slight elevation
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white10)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.black, // Dark text on light red button
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariantColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white70,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
      ),
    );
  }
}
