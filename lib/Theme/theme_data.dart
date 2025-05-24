import 'package:flutter/material.dart';
class NewsAppTheme {
  // Color Constants
  static const Color _background = Color(0xFF0F0F0F);      // Almost black
  static const Color _surface = Color(0xFF1F1F1F);        // Deep grey
  static const Color _cardSurface = Color(0xFF2F2F2F);    // Elevated grey
  static const Color _primaryText = Color(0xFFFFFFFF);     // Pure white
  static const Color _secondaryText = Color(0xFF9F9F9F);   // Medium grey
  static const Color _accent = Color(0xFFFF4757);          // Vibrant red

  // Additional utility colors
  static const Color _divider = Color(0xFF404040);
  static const Color _border = Color(0xFF333333);
  static const Color _success = Color(0xFF00D4AA);
  static const Color _warning = Color(0xFFFFB800);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: _accent,
        onPrimary: _primaryText,
        secondary: _accent,
        onSecondary: _primaryText,
        surface: _surface,
        onSurface: _primaryText,
        background: _background,
        onBackground: _primaryText,
        error: _accent,
        onError: _primaryText,
        outline: _border,
        surfaceVariant: _cardSurface,
        onSurfaceVariant: _secondaryText,
      ),

      // Scaffold
      scaffoldBackgroundColor: _background,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: _primaryText,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black26,
        titleTextStyle: TextStyle(
          color: _primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: _primaryText),
        actionsIconTheme: IconThemeData(color: _primaryText),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: _cardSurface,
        elevation: 2,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        // Headlines for article titles
        headlineLarge: TextStyle(
          color: _primaryText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          color: _primaryText,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          color: _primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600,

        ),

        // Body text for article content
        bodyLarge: TextStyle(
          color: _primaryText,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: _primaryText,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: _secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          height: 1.4,
        ),

        // Labels and captions
        labelLarge: TextStyle(
          color: _secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: _secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          color: _secondaryText,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: _primaryText,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryText,
          side: const BorderSide(color: _border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: _secondaryText,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: _divider,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _accent,
        unselectedItemColor: _secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: _accent,
        unselectedLabelColor: _secondaryText,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: _accent, width: 2),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _surface,
        labelStyle: const TextStyle(color: _primaryText),
        secondaryLabelStyle: const TextStyle(color: _secondaryText),
        selectedColor: _accent.withOpacity(0.2),
        side: const BorderSide(color: _border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        hintStyle: const TextStyle(color: _secondaryText),
        labelStyle: const TextStyle(color: _secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accent),
        ),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        tileColor: _cardSurface,
        textColor: _primaryText,
        iconColor: _secondaryText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  // Custom Colors for News App Specific Elements
  static const Color breakingNewsRed = _accent;
  static const Color categoryBlue = Color(0xFF4A9EFF);
  static const Color successGreen = _success;
  static const Color warningOrange = _warning;

  // Text Styles for News App
  static const TextStyle breakingNewsStyle = TextStyle(
    color: breakingNewsRed,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle categoryStyle = TextStyle(
    color: categoryBlue,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static const TextStyle timestampStyle = TextStyle(
    color: _secondaryText,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
}
