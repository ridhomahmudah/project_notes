import 'dart:ui';

import 'package:amuba_notes/controllers/home_controller.dart';
import 'package:amuba_notes/routes/app_pages.dart';
import 'package:amuba_notes/widgets/home/categori_sort.dart';
import 'package:amuba_notes/widgets/home/delete_confirmation_sheet.dart';
import 'package:amuba_notes/widgets/home/month_selector_card.dart';
import 'package:amuba_notes/widgets/home/note_bubble_item.dart';
import 'package:amuba_notes/widgets/home/search_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/theme_controller.dart';
import '../services/theme.dart';

class HomeView extends StatelessWidget {
  final themeController = Get.find<ThemeController>();
  final homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        // Menangani klik di area kosong (selain bubble)
        onTap: () {
          if (homeController.isSelectionMode.value) {
            homeController.toggleSelectionMode();
          }
        },
        behavior:
            HitTestBehavior
                .opaque, // Memastikan area kosong tetap menangkap klik
        child: Scaffold(
          appBar: AppBar(
            leading: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color:
                  themeController.isDarkMode.value
                      ? Themes.darkPrimary
                      : Colors.white,
              onSelected: (value) {
                if (value == 'Select Notes') {
                  homeController.toggleSelectionMode();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'Select Notes',
                    child: Row(
                      children: [
                        Icon(
                          Icons.checklist,
                          size: 20,
                          color:
                              themeController.isDarkMode.value
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Select Notes",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color:
                                themeController.isDarkMode.value
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
            title: Text(
              "AMUBA Notes",
              style: GoogleFonts.montserrat(
                fontSize: 24,
                color:
                    themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
                fontWeight: FontWeight.bold,
                shadows: [
                  const Shadow(
                    blurRadius: 4,
                    color: Colors.black45,
                    offset: Offset(0.0, 2.0),
                  ),
                ],
              ),
            ),
            iconTheme: IconThemeData(
              color:
                  themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
            ),
            backgroundColor:
                themeController.isDarkMode.value ? Themes.darkBg : Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  themeController.isDarkMode.value
                      ? Icons.light_mode
                      : Icons.dark_mode,
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
                Obx(
                  () =>
                      MonthSelectorCard(title: homeController.currentMonthName),
                ),
                const SizedBox(height: 12),
                SearchCard(),
                const SizedBox(height: 12),
                CategorySortBar(),
                const SizedBox(height: 16),
                Expanded(child: _buildNotesList()),
              ],
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                onPressed: () async {
                  await Get.toNamed(Routes.ADD_NOTE);
                  homeController.getNotes();
                },
                backgroundColor:
                    themeController.isDarkMode.value
                        ? Themes.darkPrimary
                        : Themes.lightPrimary,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            ),
          ),
          bottomNavigationBar: Obx(() {
            if (!homeController.isSelectionMode.value)
              return const SizedBox.shrink();

            bool isDark = themeController.isDarkMode.value;
            int selectedCount = homeController.selectedNoteIds.length;

            return Container(
              height: 70,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: isDark ? Themes.darkPrimary : Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => homeController.selectAll(),
                    icon: Icon(
                      Icons.select_all,
                      color: isDark ? Colors.white70 : Themes.lightPrimary,
                      size: 28,
                    ),
                    tooltip: "Select All",
                  ),
                  Expanded(
                    child: Text(
                      "$selectedCount Selected",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed:
                            () => homeController.downloadSelectedNotesAsZip(),
                        icon: Icon(
                          Icons.download_rounded,
                          color: isDark ? Colors.blueAccent : Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        onPressed: () => DeleteConfirmationSheet.show(context),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
  // _buildNotesList tetap sama seperti sebelumnya...

  Widget _buildNotesList() {
    return Obx(() {
      // Gunakan filteredNotes agar tampilan berubah saat mencari
      final currentNotes = homeController.filteredNotes;

      if (currentNotes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20), // Kecilkan jarak atas
              Flexible(
                // Ganti Image.asset dengan Flexible berisi Image
                child: Image.asset(
                  'assets/images/note0.png',
                  width: 300,
                  fit: BoxFit.contain, // Pastikan gambar proporsional
                ),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        itemCount: currentNotes.length, // Pakai length dari currentNotes
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final note = currentNotes[index]; // Ambil data dari hasil filter
          return NoteBubbleItem(
            id: note['id'] ?? 0, // Tambahkan null safety untuk ID
            title: note['title'] ?? "Tanpa Judul",
            content: note['note'] ?? "",
            date: note['date'] ?? "",
            imagePath: note['imagePath'] ?? "",
            // PERBAIKAN: Hapus titik setelah 'note' dan pastikan mengambil key 'color'
            colorValue: note['color'] ?? 0,
          );
        },
      );
    });
  }
}
