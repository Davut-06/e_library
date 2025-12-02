import 'package:e_lib/utils/colors.dart';
import 'package:flutter/material.dart';

// ------------------------------------------------------------------
// 1. СВЕТЛАЯ ТЕМА
// ------------------------------------------------------------------
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  fontFamily: 'Plus Jakarta Sans',

  // -- ЦВЕТОВАЯ СХЕМА (ColorScheme) --
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: Color(0xFF9094B8),
    onSecondary: Colors.white,
    tertiary: Color(0xffDFE5EF),
    onTertiary: Colors.white,
    error: AppColors.actionTertiary,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: Color(0xFF4E4639),
    outline: Color(0xFF807667),
    onInverseSurface: Color(0xFFF8EFE7),
    inverseSurface: AppColors.primary,
    inversePrimary: Color(0xFF5775CD),
    background: AppColors.backgroundColor,
    onBackground: AppColors.textPrimary,
  ),

  // -- НАСТРОЙКИ ВИДЖЕТОВ --
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),

  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.lightGray),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    isDense: true,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
  ),

  cardTheme: const CardThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
  ),

  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),

  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),

  chipTheme: const ChipThemeData(backgroundColor: Color(0xFFF5F9FD)),
);

// ------------------------------------------------------------------
// 2. ТЕМНАЯ ТЕМА
// ------------------------------------------------------------------
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  fontFamily: 'Plus Jakarta Sans',

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: Colors.black,
    secondary: Color(0xFF9094B8),
    onSecondary: Colors.black,
    tertiary: Color(0xFF2A2D32),
    onTertiary: Colors.white,
    error: AppColors.actionTertiary,
    onError: Colors.black,
    surface: Color(0xFF1A1C1E),
    onSurface: Colors.white,
    onSurfaceVariant: Color(0xFFCAC5BD),
    outline: Color(0xFF5F5B53),
    inverseSurface: Color(0xFFF8EFE7),
    onInverseSurface: Color(0xFF1A1C1E),
    inversePrimary: Color(0xFF5775CD),
    background: Color(0xFF121314),
    onBackground: Colors.white,
  ),

  appBarTheme: const AppBarTheme(
    centerTitle: false,
    backgroundColor: Color(0xFF1A1C1E),
    foregroundColor: Colors.white,
  ),

  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.lightGray),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    isDense: true,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
  ),

  cardTheme: const CardThemeData(
    color: Color(0xFF1A1C1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
  ),

  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),

  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),

  chipTheme: const ChipThemeData(backgroundColor: Color(0xFF2A2D32)),
);
