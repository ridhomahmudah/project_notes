import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/home_controller.dart';
import '../controllers/theme_controller.dart';
import '../routes/app_pages.dart';
import '../services/theme.dart';
import '../widgets/home/categori_sort.dart';
import '../widgets/home/delete_confirmation_sheet.dart';
import '../widgets/home/month_selector_card.dart';
import '../widgets/home/note_bubble_item.dart';
import '../widgets/home/search_card.dart';

class HomeView extends StatelessWidget {
  final themeController = Get.find<ThemeController>();
  final homeController = Get.put(HomeController());

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: themeController.isDarkMode.value ? Themes.darkBg : Colors.white,
        appBar: AppBar(
          leading: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: themeController.isDarkMode.value ? Themes.darkPrimary : Colors.white,
            onSelected: (value) {
              if (value == 'Select Notes') {
                homeController.toggleSelectionMode();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'Select Notes',
                child: Row(
                  children: [
                    Icon(
                      Icons.checklist,
                      size: 20,
                      color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Select Notes",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          title: Text(
            homeController.isSelectionMode.value
                ? "${homeController.selectedNoteIds.length} Selected"
                : "AMUBA Notes",
            style: GoogleFonts.montserrat(
              fontSize: 24,
              color: themeController.isDarkMode.value ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: themeController.isDarkMode.value ? Themes.darkBg : Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () => themeController.toggleTheme(),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => MonthSelectorCard(title: homeController.currentMonthName)),
              const SizedBox(height: 12),
              SearchCard(),
              const SizedBox(height: 12),
              CategorySortBar(),
              const SizedBox(height: 16),
              Expanded(child: _buildNotesList()),
            ],
          ),
        ),
        floatingActionButton: Obx(() => homeController.isSelectionMode.value 
          ? const SizedBox.shrink() 
          : Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: 70,
                height: 70,
                child: FloatingActionButton(
                  onPressed: () async {
                    await Get.toNamed(Routes.ADD_NOTE);
                    homeController.getNotes();
                  },
                  backgroundColor: themeController.isDarkMode.value ? Themes.darkPrimary : Themes.lightPrimary,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, size: 30, color: Colors.white),
                ),
              ),
            )),
        bottomNavigationBar: _buildBottomSelectionBar(context),
      ),
    );
  }

  // --- Widget Bar Seleksi Bawah ---
  Widget _buildBottomSelectionBar(BuildContext context) {
    return Obx(() {
      if (!homeController.isSelectionMode.value) return const SizedBox.shrink();

      bool isDark = themeController.isDarkMode.value;

      return Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1F) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${homeController.selectedNoteIds.length} Catatan Terpilih",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            IconButton(
              onPressed: () {
                if (homeController.selectedNoteIds.isNotEmpty) {
                  DeleteConfirmationSheet.show(context);
                }
              },
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.redAccent,
                size: 30,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNotesList() {
    return Obx(() {
      final currentNotes = homeController.filteredNotes;

      if (currentNotes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/note0.png',
                width: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text("Belum ada catatan", style: GoogleFonts.montserrat(color: Colors.grey)),
            ],
          ),
        );
      }

      return GridView.builder(
        itemCount: currentNotes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final note = currentNotes[index];
          return NoteBubbleItem(
            id: note['id'],
            title: note['title'] ?? "Tanpa Judul",
            content: note['note'] ?? "",
            date: note['date'] ?? "",
            // Jangan lupa tambahkan parameter color di NoteBubbleItem jika ingin warnanya muncul
          );
        },
      );
    });
  }
}