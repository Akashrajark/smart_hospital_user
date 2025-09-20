import 'package:flutter/material.dart';

import '../value/color.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    surface: backgroundColor,
    secondary: secondaryColor,
    shadow: shadowColor,
    outline: Colors.grey.shade700,
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      side: BorderSide(color: Colors.grey.shade300, width: 2),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.withAlpha(100), width: 2),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.withAlpha(100), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.withAlpha(100), width: 2),
    ),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: primaryColorDarkMode,
    surface: backgroundColorDarkMode,
    secondary: secondaryColorDarkMode,
    shadow: shadowColorDarkMode,
  ),
);
