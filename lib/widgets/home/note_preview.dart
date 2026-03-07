import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// Sesuaikan import di bawah ini dengan lokasi file asli project Anda
// import 'package:your_app/controllers/theme_controller.dart';
// import 'package:your_app/controllers/home_controller.dart';
// import 'package:your_app/utils/themes.dart';

class NotePreviewHelper {
  final dynamic themeController; // Ganti dynamic dengan tipe ThemeController Anda
  final dynamic homeController;  // Ganti dynamic dengan tipe HomeController Anda
  final Widget Function({
    required int id,
    required String title,
    required String content,
    required String date,
    bool isPreview,
  }) bubbleNoteItemBuilder;

  NotePreviewHelper({
    required this.themeController,
    required this.homeController,
    required this.bubbleNoteItemBuilder,
  });

  void showNotePreview(
    BuildContext context, {
    required String title,
    required String content,
    required String date,
  }) {
    bool isDark = themeController.isDarkMode.value;

    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: IntrinsicHeight(
                        child: bubbleNoteItemBuilder(
                          id: 0,
                          title: title,
                          content: content,
                          date: date,
                          isPreview: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white, // Sesuaikan Themes.darkPrimary
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(Icons.list, "Add to List", () {
                            _showAddToListSheet(context);
                          }),
                          const Divider(height: 1, indent: 15, endIndent: 15),
                          _buildMenuItem(Icons.download, "Download ZIP", () {}),
                          const Divider(height: 1, indent: 15, endIndent: 15),
                          _buildMenuItem(
                            Icons.delete_outline,
                            "Delete Note",
                            () {},
                            customColor: Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String text, VoidCallback onTap, {Color? customColor}) {
    bool isDark = themeController.isDarkMode.value;
    Color contentColor = isDark ? Colors.white : Colors.black87;

    return ListTile(
      leading: Icon(icon, color: customColor ?? contentColor, size: 22),
      title: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: customColor ?? contentColor,
        ),
      ),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }

  void _showAddToListSheet(BuildContext context) {
    bool isDark = themeController.isDarkMode.value;
    bool isCreatingNew = false;
    TextEditingController newListController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.black : Colors.grey[200], // Sesuaikan Themes.darkBg
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSheetHeader(isDark),
                const SizedBox(height: 15),
                isCreatingNew
                    ? _buildNewListInput(newListController, isDark)
                    : GestureDetector(
                        onTap: () => setSheetState(() => isCreatingNew = true),
                        child: _buildSheetOption(
                          icon: Icons.segment,
                          title: "New List",
                          isDark: isDark,
                        ),
                      ),
                const SizedBox(height: 10),
                ...homeController.categories.map(
                  (cat) => _buildSheetOption(
                    icon: Icons.folder_open,
                    title: cat,
                    isDark: isDark,
                    trailing: _buildRadioCircle(isDark),
                    onDelete: () => homeController.categories.remove(cat),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF4E342E) : const Color(0xFF2D1B08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      "Finish",
                      style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widget pendukung (Private) ---
  Widget _buildSheetHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 40),
        Text("Add to List", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        IconButton(onPressed: () => Get.back(), icon: Icon(Icons.cancel, color: isDark ? Colors.white38 : Colors.grey[400])),
      ],
    );
  }

  Widget _buildRadioCircle(bool isDark) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isDark ? Colors.white38 : Colors.black54, width: 1.5),
      ),
    );
  }

  Widget _buildNewListInput(TextEditingController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit, color: Colors.red, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              style: GoogleFonts.montserrat(fontSize: 15, color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Enter list name...",
                hintStyle: GoogleFonts.montserrat(color: isDark ? Colors.white38 : Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetOption({required IconData icon, required String title, required bool isDark, Widget? trailing, VoidCallback? onDelete}) {
    bool showDelete = title.toLowerCase() != "new list" && onDelete != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey),
            ),
            child: Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null) trailing,
              if (showDelete) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}