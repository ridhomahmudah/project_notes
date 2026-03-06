import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../services/theme.dart';

class HomeView extends StatelessWidget {
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    // Bungkus Scaffold dengan Obx agar perubahan tema terdeteksi secara menyeluruh
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: const Text("Amuba Notes"),
        // KUNCI: Tentukan warna background secara manual berdasarkan status isDarkMode
        backgroundColor: themeController.isDarkMode.value 
            ? Themes.darkPrimary  // Warna saat Dark Mode
            : Themes.lightPrimary, // Warna saat Light Mode
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(themeController.isDarkMode.value 
                ? Icons.light_mode 
                : Icons.dark_mode),
            onPressed: () => themeController.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _noteCard("Catatan Merah", Themes.amubaRed),
            _noteCard("Ide Bisnis", Themes.amubaOrange),
            _noteCard("Daftar Belanja", Themes.amubaBlue),
            _noteCard("Tugas Amuba", Themes.amubaGreen),
          ],
        ),
      ),
    ));
  }

  Widget _noteCard(String title, Color accentColor) {
    // Gunakan isDarkMode.value agar card juga reaktif
    bool isDark = themeController.isDarkMode.value;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF252526) : Colors.grey[50],
      child: ListTile(
        leading: Container(width: 4, color: accentColor),
        title: Text(title, style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black
        )),
        subtitle: Text(
          "Sentuh untuk melihat detail...",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
      ),
    );
  }
}