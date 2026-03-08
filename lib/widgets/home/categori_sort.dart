import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../services/theme.dart';

class CategorySortBar extends StatelessWidget {
  final HomeController homeController = Get.find();
  final ThemeController themeController = Get.find();

  void _showAddCategorySheet(BuildContext context) {
    final TextEditingController categoryController = TextEditingController();
    final isDark = themeController.isDarkMode.value;

    Get.bottomSheet(
      Container(
        // Padding disesuaikan agar tidak mepet keyboard
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? Themes.darkPrimary : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar (Garis kecil di atas sheet)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // TITLE: NEW LIST
              Text(
                "New List",
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 15),

              // INPUT FIELD
              TextField(
                controller: categoryController,
                autofocus: true, // Langsung fokus saat muncul
                style: GoogleFonts.montserrat(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "Ex: Favorit",
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                  filled: true,
                  fillColor:
                      isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: isDark ? Themes.amubaYellow : Themes.lightPrimary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // BUTTON: FINISH
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Themes.amubaYellow : Themes.lightPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    String name = categoryController.text.trim();
                    if (name.isNotEmpty) {
                      homeController.addCategory(name);
                      Get.back(); // Tutup sheet
                    }
                  },
                  child: Text(
                    "Finish",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true, // Wajib true agar input tidak tertutup keyboard
      backgroundColor: Colors.transparent,
    );
  }

  @override
Widget build(BuildContext context) {
  // Gunakan Obx di level terluar build agar bisa mendeteksi perubahan selectionMode
  return Obx(() {
    bool isSelectionActive = homeController.isSelectionMode.value;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      // Kurangi opacity jika mode seleksi aktif (efek visual non-aktif)
      opacity: isSelectionActive ? 0.5 : 1.0,
      child: IgnorePointer(
        // Menonaktifkan semua interaksi klik jika mode seleksi aktif
        ignoring: isSelectionActive,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Daftar Kategori
              Row(
                children: homeController.categories.map((category) {
                  bool isSelected =
                      homeController.selectedCategory.value == category;
                  bool isDark = themeController.isDarkMode.value;

                  return GestureDetector(
                    onTap: () {
                      homeController.changeCategory(category);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? Themes.darkPrimary : Themes.lightPrimary)
                            : (isDark ? Themes.darkBg : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Tombol Tambah (+)
              GestureDetector(
                onTap: () => _showAddCategorySheet(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeController.isDarkMode.value
                        ? Themes.darkPrimary
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 20,
                    color: themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
}
}