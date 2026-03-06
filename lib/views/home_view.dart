import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../services/theme.dart';

class HomeView extends StatelessWidget {
  // Gunakan Get.find karena ThemeController sudah di-put di main.dart
  final themeController = Get.find<ThemeController>();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan Obx pada Scaffold agar warna background ikut berubah instan
      backgroundColor: context.theme.scaffoldBackgroundColor,
      drawer: Drawer(
        child: Column(
          children: [
            Obx(() => DrawerHeader(
              decoration: BoxDecoration(
                // Menggunakan themeController.isDarkMode.value agar reaktif
                color: themeController.isDarkMode.value 
                    ? Themes.darkPrimary 
                    : Themes.lightPrimary,
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
            )),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text("Semua Catatan"),
              onTap: () => Get.back(),
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
      appBar: AppBar(
        title: const Text("Amuba Notes"),
        actions: [
          IconButton(
            // Obx di sini sudah benar untuk memantau perubahan icon
            icon: Obx(() => Image.asset(
                  themeController.isDarkMode.value
                      ? 'assets/images/sun_icon.png'
                      : 'assets/images/moon_icon.png',
                  width: 24,
                  height: 24,
                  // Jika icon gambar tidak ada, gunakan icon bawaan flutter sebagai cadangan
                  errorBuilder: (context, error, stackTrace) => Icon(
                    themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
                  ),
                )),
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
    // Membungkus card dengan Obx agar warna card berubah saat toggle theme
    return Obx(() => Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: themeController.isDarkMode.value 
          ? const Color(0xFF252526) 
          : Colors.white,
      child: ListTile(
        leading: Container(width: 4, height: 40, color: accentColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeController.isDarkMode.value ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          "Sentuh untuk melihat detail...",
          style: TextStyle(
            color: themeController.isDarkMode.value ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    ));
  }
}