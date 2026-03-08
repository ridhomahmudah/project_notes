import 'dart:io';
import 'dart:ui'; // Diperlukan untuk ImageFilter

import 'package:amuba_notes/controllers/add_note_controller.dart';
import 'package:amuba_notes/services/theme.dart';
import 'package:amuba_notes/views/add_note_view.dart';
import 'package:amuba_notes/widgets/home/note_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';

class NoteBubbleItem extends StatelessWidget {
  final int id;
  final String title;
  final String content;
  final String date;
  final String imagePath;
  final bool isPreview;
  final int? colorValue;

  NoteBubbleItem({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imagePath = '',
    this.isPreview = false,
    this.colorValue, // Opsional
  });

  // --- FUNGSI HELPER HIGHLIGHT ---
  List<TextSpan> _getHighlightedText(
    String text,
    String query,
    bool isDark, {
    bool isTitle = false,
  }) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return [TextSpan(text: text)];
    }
    final List<TextSpan> spans = [];
    final String lowerCaseText = text.toLowerCase();
    final String lowerCaseQuery = query.toLowerCase();
    int start = 0;
    int indexOfMatch;
    while ((indexOfMatch = lowerCaseText.indexOf(lowerCaseQuery, start)) !=
        -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }
      spans.add(
        TextSpan(
          text: text.substring(indexOfMatch, indexOfMatch + query.length),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            backgroundColor: isDark ? Themes.lightPrimary : Themes.amubaYellow,
          ),
        ),
      );
      start = indexOfMatch + query.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final themeController = Get.find<ThemeController>();

    final previewHelper = NotePreviewHelper(
      themeController: themeController,
      homeController: homeController,
      bubbleNoteItemBuilder: ({
        required id,
        required title,
        required content,
        required date,
        bool isPreview = false,
      }) {
        return NoteBubbleItem(
          id: id,
          title: title,
          content: content,
          date: date,
          isPreview: isPreview,
        );
      },
    );

    return Obx(() {
      bool isDark = themeController.isDarkMode.value;
      String query = homeController.searchQuery.value;
      bool isSelected = homeController.isNoteSelected(id);
      bool selectionMode = homeController.isSelectionMode.value;

      return GestureDetector(
        onTap: () {
          if (selectionMode) {
            homeController.toggleNoteSelection(id);
          } else {
            if (Get.isDialogOpen ?? false) Get.back();
            final addNoteController = Get.put(AddNoteController());
            addNoteController.currentId = id;
            addNoteController.titleController.text = title;
            addNoteController.noteController.text = content;
            addNoteController.selectedImagePath.value = imagePath;
            addNoteController.selectedColor.value = colorValue ?? 0;
            Get.to(() => AddNoteView(), transition: Transition.rightToLeft);
          }
        },

        onLongPress:
            isPreview
                ? null
                : () {
                  HapticFeedback.mediumImpact();

                  if (selectionMode) {
                    // Jika sedang mode pilih banyak, Long Press berfungsi untuk toggle seleksi juga
                    homeController.toggleNoteSelection(id);
                  } else {
                    // JIKA MODE NORMAL: Munculkan Preview (Inilah yang Anda inginkan)
                    previewHelper.showNotePreview(
                      context, // Pastikan urutan argumen sesuai dengan definisi di helper
                      id: id,
                      title: title,
                      content: content,
                      date: date,
                    );
                  }
                },
        // Menggunakan AnimatedContainer agar transisi saat dipilih lebih halus
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          // Jika dipilih, bubble sedikit membesar (scale up) agar terlihat di atas blur
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                    : [BoxShadow(color: Colors.transparent)],
          ),
          child: Stack(
            children: [
              // KONTEN UTAMA BUBBLE
              Container(
                width: double.infinity, // Pastikan memenuhi lebar grid
                height: double.infinity, // Pastikan memenuhi tinggi grid
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color:
                        isSelected
                            ? Themes.lightPrimary
                            : (isDark ? Colors.white10 : Colors.grey[200]!),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: isSelected ? 25 : 0),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (imagePath.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(imagePath),
                          width: double.infinity,
                          height: isPreview ? 200 : 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Expanded(
                      child: RichText(
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            height: 1.3,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          children: _getHighlightedText(
                            content,
                            homeController.searchQuery.value,
                            isDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Di dalam Column NoteBubbleItem, bagian tanggal:
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // KUNCI UTAMA: Jika colorValue ada, gunakan warna itu dengan opacity
                        color:
                            colorValue != null && colorValue != 0
                                ? Color(colorValue!)
                                : (isDark
                                    ? Colors.white10
                                    : Colors.black.withOpacity(
                                      0.05,
                                    )), // Warna default
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        date,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          // Warna teks juga ikut sedikit berubah agar serasi
                          color:
                              isDark
                                      ? Colors.white
                                      : Colors.black),
                        
                      ),
                    ),
                  ],
                ),
              ),

              // ICON CHECKLIST (Hanya muncul saat dipilih)
              if (isSelected)
                Positioned(
                  top: 10, // Jarak dari ATAS (di dalam bubble)
                  right: 10, // Jarak dari KANAN (di dalam bubble)
                  child: Container(
                    decoration: const BoxDecoration(
                      color:
                          Colors
                              .white, // Background putih agar icon bulat sempurna
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 22, // Ukuran disesuaikan
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
