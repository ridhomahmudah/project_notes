import 'dart:ui';

import 'package:amuba_notes/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/theme_controller.dart';
import '../services/theme.dart';

class HomeView extends StatelessWidget {
  final themeController = Get.find<ThemeController>();
  // Tambahkan inisialisasi HomeController
  final homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    // Bungkus Scaffold dengan Obx agar perubahan tema terdeteksi secara menyeluruh
    return Obx(
      () => Scaffold(
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
                print("Aksi Select Notes dijalankan");
                // Tambahkan logika seleksi di sini
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Select Notes',
                  child: Row(
                    // Gunakan Row agar Icon dan Teks berjejer kesamping
                    children: [
                      Icon(
                        Icons.checklist,
                        size: 20,
                        color:
                            themeController.isDarkMode.value
                                ? Colors.white
                                : Colors.black,
                      ),
                      const SizedBox(width: 12), // Jarak antara icon dan teks
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
                themeController.isDarkMode.value ? Colors.white : Colors.black,
          ),
          backgroundColor:
              themeController.isDarkMode.value ? Themes.darkBg : Colors.white,
          elevation: 0,
          actions: [
            // Tombol Toggle Tema
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
              _searchCard(),
              const SizedBox(height: 12),
              Obx(() => _noteCard(homeController.currentMonthName)),
              const SizedBox(height: 12),

              // TAMBAHKAN INI: Baris Kategori
              _categorySort(),

              const SizedBox(height: 16),

              Expanded(child: _buildNotesList()),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 30.0, right: 10.0),
          child: SizedBox(
            width: 70, // Tentukan lebar (default biasanya sekitar 56)
            height: 70, // Tentukan tinggi
            child: FloatingActionButton(
              onPressed: () {
                print("Tambah Catatan Baru");
              },
              backgroundColor:
                  themeController.isDarkMode.value
                      ? Themes.darkPrimary
                      : Themes.lightPrimary,
              elevation:
                  6, // Tambah elevation agar bayangannya lebih terasa saat besar
              shape: const CircleBorder(),
              // Jangan lupa perbesar juga ukuran Icon-nya
              child: const Icon(Icons.add, size: 30, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _noteCard(String title) {
    // Gunakan isDarkMode.value agar card juga reaktif
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
            // Tombol Panah Kiri
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: contentColor,
              ),
              onPressed: () => homeController.prevMonth(),
            ),

            // Judul di Tengah
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center, // Memastikan teks rata tengah
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: contentColor,
                ),
              ),
            ),

            // Tombol Panah Kanan
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: contentColor,
              ),
              onPressed: () => homeController.nextMonth(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchCard() {
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
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: contentColor,
                ),
                cursorColor: contentColor,
                decoration: InputDecoration(
                  hintText: "Cari catatan...",
                  hintStyle: GoogleFonts.montserrat(
                    color: contentColor.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (value) {
                  // Logika pencarian
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categorySort() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // BouncingScrollPhysics agar saat di-scroll ada efek pantulan yang smooth
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 1. Daftar Kategori dari Controller
          ...homeController.categories.map((category) {
            return Obx(() {
              bool isSelected =
                  homeController.selectedCategory.value == category;
              bool isDark = themeController.isDarkMode.value;

              return GestureDetector(
                onTap: () => homeController.changeCategory(category),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  // PERBESAR PADDING: Horizontal 20, Vertical 12
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? (isDark
                                ? Themes.darkPrimary
                                : Themes.lightPrimary)
                            : (isDark ? Themes.amubaGrey : Themes.darkBg),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Themes.amubaGrey,
                    ),
                  ),
                ),
              );
            });
          }).toList(),

          // 2. Tombol Tambah (+) berada di paling kanan daftar
          Obx(() {
            bool isDark = themeController.isDarkMode.value;
            return GestureDetector(
              onTap: () {
                // Aksi tambah kategori (misal: munculkan dialog input)
                print("Tambah Kategori Baru");
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Themes.darkPrimary : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    // Contoh data dummy, nanti bisa kamu ganti dengan data dari controller
    return GridView.builder(
      itemCount: 4, // Ganti dengan homeController.notes.length
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Menampilkan 2 kolom kesamping
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9, // Atur tinggi rendahnya bubble
      ),
      itemBuilder: (context, index) {
        return _bubbleNoteItem(
          title: "Judul Catatan $index",
          content: "Ini adalah isi catatan yang sangat rahasia dan penting...",
          date: "24 Mei 2024",
        );
      },
    );
  }

  Widget _bubbleNoteItem({
    required String title,
    required String content,
    required String date,
    bool isPreview = false,
  }) {
    bool isDark = themeController.isDarkMode.value;

    return GestureDetector(
      // KETIKA DIKLIK TAHAN
      onLongPress: () {
        _showNotePreview(
          Get.context!,
          title: title,
          content: content,
          date: date,
        );
      },
      onTap: () {
        print("Buka detail catatan");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Warna bubble: agak terang di dark mode, putih bersih di light mode
          color: isDark ? Themes.darkPrimary : Themes.amubaGrey,
          borderRadius: BorderRadius.circular(20), // Membuat bubble membulat
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            isPreview 
          ? Text(
              content,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            )
          : Expanded( 
              child: Text(
                content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                // Warna background date: kuning amuba untuk light, abu-abu gelap untuk dark
                color: Themes.amubaRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                date,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  // Warna teks date menyesuaikan tema
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotePreview(
    BuildContext context, {
    required String title,
    required String content,
    required String date,
  }) {
    bool isDark = themeController.isDarkMode.value;

    showDialog(
      context: context,
      builder:
          (context) => Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                // 1. Efek Blur Background
                GestureDetector(
                  onTap: () => Get.back(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  ),
                ),

                // 2. Konten Bubble di Pinggir Kiri
                Align(
                  alignment:
                      Alignment
                          .centerLeft, // UBAH: dari centerRight ke centerLeft
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16), 
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start, // UBAH: konten di dalam column rata kiri
                      children: [
                        // Tampilan Bubble Besar
                        Container(
                          width: double.infinity,
                          child: IntrinsicHeight(
                            child: _bubbleNoteItem(
                              title: title,
                              content: content,
                              date: date,
                              isPreview: true,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 3. Menu di Bawah Bubble (Rata kiri juga)
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          decoration: BoxDecoration(
                            color: isDark ? Themes.darkPrimary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuItem(Icons.list, "Add to List", () {}),
                              const Divider(
                                height: 1,
                                indent: 15,
                                endIndent: 15,
                              ),
                              _buildMenuItem(
                                Icons.download,
                                "Download ZIP",
                                () {},
                              ),
                              const Divider(
                                height: 1,
                                indent: 15,
                                endIndent: 15,
                              ),
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

  Widget _buildMenuItem(
    IconData icon,
    String text,
    VoidCallback onTap, {
    Color? customColor,
  }) {
    bool isDark = themeController.isDarkMode.value;

    // PERBAIKAN: Warna teks/icon harus kontras dengan background menu
    // Jika Dark Mode (bg menu gelap), maka teks harus putih. Begitu sebaliknya.
    Color contentColor = isDark ? Colors.white : Colors.black87;

    return ListTile(
      leading: Icon(
        icon,
        // Gunakan customColor jika ada (misal merah untuk hapus), jika tidak gunakan contentColor
        color: customColor ?? contentColor,
        size: 22,
      ),
      title: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: customColor ?? contentColor,
        ),
      ),
      onTap: () {
        Get.back(); // Menutup dialog
        onTap(); // Menjalankan fungsi
      },
    );
  }
}
