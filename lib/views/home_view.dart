import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../services/theme.dart';

class HomeView extends StatelessWidget {
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            // Header Menu
            DrawerHeader(
              decoration: BoxDecoration(
                color:
                    Get.isDarkMode ? Themes.darkPrimary : Themes.lightPrimary,
              ),
              child: const Center(
                child: Text(
                  "AMUBA MENU",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Item Menu
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text("Semua Catatan"),
              onTap: () => Get.back(), // Tutup menu
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Kategori"),
              onTap: () {},
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Pengaturan"),
              onTap: () {},
            ),
          ],
        ),
      ),
      // -------------------------------
      appBar: AppBar(
        title: const Text("Amuba Notes"),
        // Icon menu akan otomatis muncul di sebelah kiri title karena ada Drawer
        actions: [
          IconButton(
            icon: Obx(
              () => Image.asset(
                themeController.isDarkMode.value
                    ? 'assets/images/sun_icon.png'
                    : 'assets/images/moon_icon.png',
                width: 24, // Sesuaikan ukuran
                height: 24,
              ),
            ),
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
    );
  }

  Widget _noteCard(String title, Color accentColor) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      // Background card menyesuaikan tema
      color: Get.isDarkMode ? const Color(0xFF252526) : Colors.grey[50],
      child: ListTile(
        leading: Container(width: 4, color: accentColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // Teks otomatis hitam di light, putih di dark sesuai ThemeData
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: const Text("Sentuh untuk melihat detail..."),
      ),
    );
  }
}
