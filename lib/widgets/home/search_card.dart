import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';

class SearchCard extends StatelessWidget {
  final HomeController homeController = Get.find();
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isDark = themeController.isDarkMode.value;
      Color contentColor = isDark ? Colors.white : Colors.black;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 18.0),
          child: Row(
            children: [
              Icon(Icons.search, color: contentColor.withOpacity(0.6), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  enabled: !homeController.isSelectionMode.value,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: homeController.isSelectionMode.value
                        ? contentColor.withOpacity(0.3)
                        : contentColor,
                  ),
                  cursorColor: contentColor,
                  decoration: InputDecoration(
                    hintText: "Cari catatan...",
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    hintStyle: GoogleFonts.montserrat(
                      color: contentColor.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    homeController.updateSearchQuery(value);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}