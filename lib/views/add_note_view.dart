import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/theme_controller.dart';
import '../controllers/add_note_controller.dart';
import '../services/theme.dart';

class AddNoteView extends StatelessWidget {
  final themeController = Get.find<ThemeController>();
  final addNoteController = Get.put(AddNoteController());

  AddNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isDark = themeController.isDarkMode.value;
      // Ambil waktu sekarang untuk tampilan di bawah
      String formattedTime = DateFormat(
        'dd MMM yyyy, hh:mm a',
      ).format(DateTime.now());

      return Scaffold(
        backgroundColor: isDark ? Themes.darkBg : Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Obx(() {
            bool isDark = themeController.isDarkMode.value;
            return GestureDetector(
              onTap: () => Get.back(),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Kembali",
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
              child: Obx(() {
                bool isDark = themeController.isDarkMode.value;
                return ElevatedButton(
                  onPressed: () => addNoteController.saveNoteToDB(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Themes.amubaYellow : Themes.lightPrimary,

                    foregroundColor:
                        isDark ? Themes.lightPrimary : Themes.amubaWhite,
                    shape: const StadiumBorder(),
                    side: BorderSide(
                      color:
                          isDark
                              ? Colors.transparent
                              : Themes.lightPrimary.withOpacity(0.2),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                  ),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                );
              }),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. INPUT JUDUL
              Row(
                children: [
                  const Text("💡", style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: addNoteController.titleController,
                      autofocus: true, // Langsung fokus saat buka halaman
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Judul Catatan",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. BANNER IMAGE
              GestureDetector(
                onTap: () => addNoteController.pickImage(),
                child: Obx(
                  () => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child:
                        addNoteController.selectedImagePath.value == ''
                            ? Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.black12,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      isDark ? Colors.white10 : Colors.black12,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color:
                                        isDark
                                            ? Colors.white38
                                            : Colors.black26,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Tambah Gambar (Opsional)",
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? Colors.white38
                                              : Colors.black26,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Stack(
                              children: [
                                Image.file(
                                  File(
                                    addNoteController.selectedImagePath.value,
                                  ),
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                                // Tombol Hapus Gambar
                                Positioned(
                                  right: 10,
                                  top: 10,
                                  child: GestureDetector(
                                    onTap:
                                        () =>
                                            addNoteController
                                                .selectedImagePath
                                                .value = '',
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. INPUT ISI CATATAN
              TextField(
                controller: addNoteController.noteController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Tulis sesuatu yang menarik...",
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),

        // 4. BOTTOM BAR
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                10, // Mengikuti keyboard
            left: 20,
            right: 20,
            top: 10,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1F) : Colors.grey[100],
            border: Border(
              top: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
            ),
          ),
          child: Row(
            children: [
              Text(
                "Terakhir diedit $formattedTime",
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black45,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.search, size: 25),
                onPressed: () {},
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 25),
                onPressed: () {},
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),
      );
    });
  }
}
