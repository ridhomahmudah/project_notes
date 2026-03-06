import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/theme_controller.dart';
import '../services/theme.dart';

class HomeView extends StatelessWidget {
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    // Bungkus Scaffold dengan Obx agar perubahan tema terdeteksi secara menyeluruh
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(
            "AMUBA Notes",
            style: GoogleFonts.montserrat(
              fontSize: 24,
              color:
                  themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black45,
                  offset: Offset(0.0, 4.0),
                ),
              ],
            ),
          ),
          iconTheme: IconThemeData(
            color:
                themeController.isDarkMode.value ? Colors.white : Colors.black,
          ),
          // KUNCI: Tentukan warna background secara manual berdasarkan status isDarkMode
          backgroundColor:
              themeController.isDarkMode.value
                  ? Themes.darkBg // Warna saat Dark Mode
                  : Colors.white, // Warna saat Light Mode
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                themeController.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => themeController.toggleTheme(),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _noteCard("Catatan Merah"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noteCard(String title) {
  // Gunakan isDarkMode.value agar card juga reaktif
  bool isDark = themeController.isDarkMode.value;
  Color contentColor = isDark ? Colors.white : Colors.black;

  return Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 12),
    color: isDark ? Themes.darkPrimary : Themes.amubaYellow,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Panah Kiri
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 18, color: contentColor),
            onPressed: () {
              // Aksi panah kiri
            },
          ),
          
          // Judul di Tengah
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center, // Memastikan teks rata tengah
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: contentColor,
              ),
            ),
          ),
          
          // Tombol Panah Kanan
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 18, color: contentColor),
            onPressed: () {
              // Aksi panah kanan
            },
          ),
        ],
      ),
    ),
  );
}
}
