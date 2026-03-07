import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../services/theme.dart';

class MonthSelectorCard extends StatelessWidget {
  final String title;

  MonthSelectorCard({required this.title});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final homeController = Get.find<HomeController>();

    return Obx(() {
      bool isDark = themeController.isDarkMode.value;
      Color contentColor = isDark ? Colors.white : Colors.black;

      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        color: isDark ? Themes.darkPrimary : Themes.amubaYellow,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 18, color: contentColor),
                onPressed: homeController.isSelectionMode.value ? null : () => homeController.prevMonth(),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: contentColor,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 18, color: contentColor),
                onPressed: homeController.isSelectionMode.value ? null : () => homeController.nextMonth(),
              ),
            ],
          ),
        ),
      );
    });
  }
}