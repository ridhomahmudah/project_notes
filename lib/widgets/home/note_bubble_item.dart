import 'package:amuba_notes/services/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';

class NoteBubbleItem extends StatelessWidget {
  final int id;
  final String title;
  final String content;
  final String date;

  NoteBubbleItem({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  // --- FUNGSI HELPER HIGHLIGHT ---
  List<TextSpan> _getHighlightedText(String text, String query, bool isDark, {bool isTitle = false}) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final String lowerCaseText = text.toLowerCase();
    final String lowerCaseQuery = query.toLowerCase();

    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = lowerCaseText.indexOf(lowerCaseQuery, start)) != -1) {
      // Teks sebelum kata yang cocok
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }

      // Kata yang cocok (Diberi Underline & Warna berbeda)
      spans.add(TextSpan(
        text: text.substring(indexOfMatch, indexOfMatch + query.length),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          backgroundColor:
                isDark ?  Themes.lightPrimary : Themes.amubaYellow,
        ),
      ));

      start = indexOfMatch + query.length;
    }

    // Sisa teks setelah kata terakhir yang cocok
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }


  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      bool isDark = themeController.isDarkMode.value;
      String query = homeController.searchQuery.value;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- JUDUL DENGAN HIGHLIGHT ---
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                children: _getHighlightedText(title, query, isDark, isTitle: true),
              ),
            ),

            const SizedBox(height: 8),

            // --- DESKRIPSI (ISI) DENGAN HIGHLIGHT ---
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 100),
                child: SingleChildScrollView(
                  child: RichText(
                    maxLines: 4,
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

            // Tanggal (Tetap biasa)
            Text(
              date,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    });
  }
}
