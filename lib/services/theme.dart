import 'package:flutter/material.dart';

class Themes {
  // Warna Custom Sesuai Request
  static const Color darkBg = Color(0xFF19191A);
  static const Color lightPrimary = Color(0xFF281608);
  static const Color darkPrimary = Color(0xFF626265);

  // Warna Aksen untuk Kategori Catatan
  static const Color amubaGrey = Color(0xFFC8C5CB);
  static const Color amubaYellow = Color(0xFFF9EEE2);
  static const Color amubaRed = Color(0xFFE53935);
  static const Color amubaOrange = Color(0xFFFB8C00);
  static const Color amubaBlue = Color(0xFF1E88E5);
  static const Color amubaGreen = Color(0xFF43A047);
  static const Color amubaWhite = Color(0xFFFFFFFF);

// TEMA TERANG
  static final light = ThemeData.light().copyWith(
    useMaterial3: true, // Pastikan ini aktif jika pakai Flutter terbaru
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      // PENTING: Matikan tint agar warna lightPrimary tidak pudar/putih
      surfaceTintColor: Colors.transparent, 
    ),
    // Tambahan: Warna icon agar konsisten
    iconTheme: const IconThemeData(color: lightPrimary),
  );

  // TEMA GELAP
  static final dark = ThemeData.dark().copyWith(
    useMaterial3: true,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      // PENTING: Matikan tint agar warna darkPrimary keluar sempurna
      surfaceTintColor: Colors.transparent, 
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
