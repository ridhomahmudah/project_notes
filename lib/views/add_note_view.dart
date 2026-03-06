import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../services/theme.dart';
import 'package:intl/intl.dart';

class AddNoteView extends StatelessWidget {
  final themeController = Get.find<ThemeController>();

  AddNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isDark = themeController.isDarkMode.value;
      String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

      return Scaffold(
        backgroundColor: isDark ? Themes.darkBg : Colors.white,
        
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent, 
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new, 
              color: isDark ? Colors.white : Themes.lightPrimary,
            ),
            onPressed: () => Get.back(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // ISI DI SINI: Logika untuk menyimpan catatan
                // Contoh: Tampilkan snackbar sebagai placeholder
                Get.snackbar(
                  "Simpan Catatan", 
                  "Fitur simpan belum diimplementasikan",
                  backgroundColor: isDark ? const Color(0xFF1E1E1F) : Colors.grey[200],
                  colorText: isDark ? Colors.white : Colors.black87,
                );
              },
              child: Text(
                "Simpan", 
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.blueAccent : Themes.lightPrimary,
                ),
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. INPUT JUDUL DENGAN EMOJI
              Row(
                children: [
                  const Text("💡", style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "New Ideas",
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. BANNER IMAGE (Bulat di sudut sesuai gambar)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/Add notes.jpg', // Pastikan filenya ada
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              // 3. INPUT ISI CATATAN (RUMPANG)
              TextField(
                maxLines: null,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Tulis catatanmu di sini...", // ISI DI SINI: Hint teks
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),

        // 4. BOTTOM BAR (STATUS EDIT & TOOLS)
        bottomNavigationBar: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1F) : Colors.grey[100],
            border: Border(
              top: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
            ),
          ),
          child: Row(
            children: [
              Text(
                "Last edited on $formattedTime", // ISI DI SINI: Jam edit
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black45,
                  fontSize: 14,
                ),
              ),
              
              const Spacer(),
              Icon(
                Icons.search, 
                color: isDark ? Colors.white70 : Colors.black54
              ),
              const SizedBox(width: 20),
              // Icon Menu Titik Tiga
              Icon(
                Icons.more_vert, 
                color: isDark ? Colors.white70 : Colors.black54
              ),
            ],
          ),
        ),
      );
    });
  }
}