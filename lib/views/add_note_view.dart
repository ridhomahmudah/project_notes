import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../services/theme.dart';
import 'package:intl/intl.dart';
import 'package:amuba_notes/controllers/add_note_controller.dart';

class AddNoteView extends StatelessWidget {
  final themeController = Get.find<ThemeController>();
  final addNoteController = Get.put(AddNoteController());

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
                Get.snackbar("Sukses", "Catatan disimpan");
              },
              child: Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.blueAccent : Themes.lightPrimary)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Judul
              Row(
                children: [
                  const Text("💡", style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
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

              // 2. Banner Image (Sekarang pakai addNoteController)
              GestureDetector(
                onTap: () => addNoteController.pickImage(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: addNoteController.selectedImagePath.value == ''
                      ? Container(
                          height: 250,
                          width: double.infinity,
                          color: isDark ? Colors.white10 : Colors.black12,
                          child: Icon(Icons.add_a_photo, size: 50, color: isDark ? Colors.white38 : Colors.black26),
                        )
                      : Image.file(
                          File(addNoteController.selectedImagePath.value),
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Isi Catatan
              TextField(
                maxLines: null,
                style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : Colors.black87),
                decoration: const InputDecoration(
                  hintText: "Tulis catatanmu di sini...",
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
        
        // 4. Bottom Bar
        bottomNavigationBar: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1F) : Colors.grey[100],
            border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
          ),
          child: Row(
            children: [
              Text("Last edited on $formattedTime", style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 14)),
              const Spacer(),
              Icon(Icons.search, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(width: 20),
              Icon(Icons.more_vert, color: isDark ? Colors.white70 : Colors.black54),
            ],
          ),
        ),
      );
    });
  }
}