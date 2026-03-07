import 'dart:io';

import 'package:amuba_notes/controllers/add_note_controller.dart';
import 'package:amuba_notes/routes/app_pages.dart';
import 'package:amuba_notes/services/theme.dart';
import 'package:amuba_notes/views/add_note_view.dart';
import 'package:amuba_notes/widgets/home/note_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan untuk HapticFeedback
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';
// Import helper preview kamu di sini
// import '../../helpers/note_preview_helper.dart';

class NoteBubbleItem extends StatelessWidget {
  final int id;
  final String title;
  final String content;
  final String date;
  final String imagePath;
  final bool isPreview; // Tambahkan parameter ini

  NoteBubbleItem({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imagePath = '',
    this.isPreview = false, // Default false
  });

  // --- FUNGSI HELPER HIGHLIGHT (Tetap sama seperti punyamu) ---
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

    // Inisialisasi Preview Helper
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

      return GestureDetector(
        // 1. Klik Biasa: Buka Edit Note
        onTap: () {
          if (homeController.isSelectionMode.value) {
            homeController.toggleNoteSelection(id);
          } else {
            if (Get.isDialogOpen ?? false) Get.back();

            // Ambil controller dan isi datanya untuk Mode Edit
            final addNoteController = Get.put(AddNoteController());
            addNoteController.currentId = id;
            addNoteController.titleController.text = title;
            addNoteController.noteController.text = content;
            addNoteController.selectedImagePath.value = imagePath;

            Get.to(
              () => AddNoteView(),
              transition: Transition.rightToLeft,
            );
          }
        },

        // 2. KLIK TAHAN: Munculkan Preview
        onLongPress:
            isPreview
                ? null
                : () {
                  HapticFeedback.mediumImpact(); // Getaran HP biar kerasa premium
                  previewHelper.showNotePreview(
                    id: id,
                    context,
                    title: title,
                    content: content,
                    date: date,
                  );
                },

        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey[200]!,
            ),
            // Tambahkan shadow jika sedang mode preview agar melayang
            boxShadow:
                isPreview
                    ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ]
                    : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  children: _getHighlightedText(
                    title,
                    query,
                    isDark,
                    isTitle: true,
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
                    height: isPreview ? 150 : 80, // Jika preview, gambar lebih besar
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: SingleChildScrollView(
                    // Matikan scroll jika hanya preview kecil
                    physics:
                        isPreview
                            ? const NeverScrollableScrollPhysics()
                            : const BouncingScrollPhysics(),
                    child: RichText(
                      maxLines:
                          isPreview
                              ? 10
                              : 4, // Preview bisa menampilkan lebih banyak baris
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        children: _getHighlightedText(content, query, isDark),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                date,
                style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    });
  }
}
