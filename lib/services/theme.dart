import 'package:flutter/material.dart';

class Themes {
  // Warna Custom Sesuai Request
  static const Color darkBg = Color(0xFF19191A);
  static const Color lightPrimary = Color(0xFF281608);
  static const Color darkPrimary = Color(0xFF626265);
  
  // Warna Aksen untuk Kategori Catatan
  static const Color amubaYellow = Color(0xFFF9EEE2);
  static const Color amubaRed = Color(0xFFE53935);
  static const Color amubaOrange = Color(0xFFFB8C00);
  static const Color amubaBlue = Color(0xFF1E88E5);
  static const Color amubaGreen = Color(0xFF43A047);

  // TEMA TERANG
  static final light = ThemeData.light().copyWith(
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightPrimary,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );

  // TEMA GELAP
  static final dark = ThemeData.dark().copyWith(
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkPrimary,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}