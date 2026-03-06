import 'dart:ui';

import 'package:amuba_notes/controllers/home_controller.dart';
import 'package:amuba_notes/routes/app_pages.dart';
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
                homeController.toggleSelectionMode();
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
            homeController.isSelectionMode.value
                ? "${homeController.selectedNotes.length} Selected" // Ganti dengan variabel list seleksi Anda
                : "AMUBA Notes",
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
          padding: const EdgeInsets.all(30.0), // Sesuaikan padding
          child: SizedBox(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              onPressed: () {
                // HAPUS: print("Tambah Catatan Baru");
                // GANTI DENGAN INI:
                Get.toNamed(Routes.ADD_NOTE);
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
        // Di dalam Scaffold
        bottomNavigationBar: Obx(() {
          // Pastikan mode seleksi aktif sebelum menampilkan bar ini
          if (!homeController.isSelectionMode.value)
            return const SizedBox.shrink();

          // DEFINISIKAN isDark di sini agar bisa digunakan di bawahnya
          bool isDark = themeController.isDarkMode.value;

          return Container(
            height: 70,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? Themes.darkPrimary : Colors.white,
              borderRadius: BorderRadius.circular(30),
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
                // Tombol Select All
                TextButton.icon(
                  onPressed: () => homeController.selectAll(),
                  icon: Icon(Icons.select_all, color: Themes.lightPrimary, size: 40),
                  label: Text(
                    "Select All",
                    style: GoogleFonts.montserrat(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Tombol Hapus
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    bool isDark = themeController.isDarkMode.value;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Themes.darkBg : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar tinggi mengikuti konten
          children: [
            // Handle Bar (Garis kecil di paling atas)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // 1. GAMBAR/IKON
            // Anda bisa ganti Icon ini dengan Image.asset('assets/delete_illustration.png')
            Container(
              padding: const EdgeInsets.all(20),
              child: Image.asset('images/delete.png'),
            ),

            const SizedBox(height: 20),

            // 2. TULISAN KONFIRMASI
            Text(
              "Yakin ingin menghapus?",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Catatan yang dihapus tidak dapat dikembalikan.",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            // 3. TOMBOL YES & NO
            Row(
              children: [
                // Tombol NO
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "No",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Tombol YES
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      homeController
                          .deleteSelectedNotes(); // Panggil fungsi hapus
                      Get.back(); // Tutup bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Yes, Delete",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Memberi ruang di paling bawah
          ],
        ),
      ),
      isScrollControlled: true, // Agar bisa menyesuaikan tinggi konten
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
              onPressed:
                  homeController.isSelectionMode.value
                      ? null
                      : () => homeController.prevMonth(),
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
              onPressed:
                  homeController.isSelectionMode.value
                      ? null
                      : () => homeController.nextMonth(),
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
                enabled: !homeController.isSelectionMode.value,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color:
                      homeController.isSelectionMode.value
                          ? contentColor.withOpacity(
                            0.3,
                          ) // Redupkan warna saat mati
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
                onTap:
                    homeController.isSelectionMode.value
                        ? null
                        : () => homeController.changeCategory(category),
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
                print("Dialog Tambah Kategori Baru");
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
      itemCount: 10, // Ganti dengan homeController.notes.length
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Menampilkan 2 kolom kesamping
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9, // Atur tinggi rendahnya bubble
      ),
      itemBuilder: (context, index) {
        return _bubbleNoteItem(
          index: index,
          title: "Judul Catatan $index",
          content: "Ini adalah isi catatan yang sangat rahasia dan penting...",
          date: "24 Mei 2024",
        );
      },
    );
  }

  Widget _bubbleNoteItem({
    int? index,
    required String title,
    required String content,
    required String date,
    bool isPreview = false,
  }) {
    bool isDark = themeController.isDarkMode.value;

    return Obx(() {
      bool isSelected =
          (index != null) ? homeController.isNoteSelected(index) : false;
      bool selectionMode = homeController.isSelectionMode.value;

      return GestureDetector(
        onLongPress:
            selectionMode
                ? null
                : () {
                  _showNotePreview(
                    Get.context!,
                    title: title,
                    content: content,
                    date: date,
                  );
                },
        onTap: () {
          if (selectionMode) {
            homeController.toggleNoteSelection(index!);
          } else {
            print("Buka detail catatan");
          }
        },
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Themes.darkPrimary : Themes.amubaGrey,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected
                          ? (isDark ? Colors.blueAccent : Themes.lightPrimary)
                          : (isDark
                              ? Colors.white10
                              : Colors.grey.withOpacity(0.1)),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                  // Menggunakan Flexible agar tidak overflow di dalam GridView
                  Flexible(
                    child: Text(
                      content,
                      maxLines: isPreview ? 10 : 4,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Themes.amubaRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      date,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // PERBAIKAN: Menggunakan Positioned, bukan PositionContainer
            if (selectionMode)
              Positioned(
                right: 8,
                top: 8,
                child: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color:
                      isSelected
                          ? (isDark ? Colors.blueAccent : Themes.lightPrimary)
                          : Colors.grey,
                  size: 24,
                ),
              ),

            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25), // Hitam transparan
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        ),
      );
    });
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
                              _buildMenuItem(Icons.list, "Add to List", () {
                                // Tutup dialog preview dulu
                                Get.back();
                                // Baru munculkan bottom sheet
                                _showAddToListSheet(context);
                              }),
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

  void _showAddToListSheet(BuildContext context) {
    bool isDark = themeController.isDarkMode.value;
    bool isCreatingNew = false;
    TextEditingController newListController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Themes.darkBg : Colors.grey[200],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (context) => StatefulBuilder(
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

                    // LOGIKA NEW LIST: Switch ke TextField saat ditekan
                    isCreatingNew
                        ? _buildNewListInput(newListController, isDark)
                        : GestureDetector(
                          onTap:
                              () => setSheetState(() => isCreatingNew = true),
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

                    // FINISH BUTTON DENGAN WARNA BERBEDA
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark
                                  ? const Color(0xFF4E342E)
                                  : const Color(0xFF2D1B08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Finish",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildSheetHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 40),
        Text(
          "Add to List",
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.cancel,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioCircle(bool isDark) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white38 : Colors.black54,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildNewListInput(TextEditingController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Themes.darkPrimary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Themes.amubaRed.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: Themes.amubaRed, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Enter list name...",
                hintStyle: GoogleFonts.montserrat(
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pendukung untuk item list di dalam sheet
  Widget _buildSheetOption({
    required IconData icon,
    required String title,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onDelete,
  }) {
    // Logika Otomatis: Jika title bukan 'New List', tampilkan tombol hapus
    bool showDelete = title.toLowerCase() != "new list" && onDelete != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Themes.darkPrimary : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Ikon Bulat
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white10 : Themes.amubaGrey!,
              ),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),

          // Judul
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),

          // Area Aksi Kanan
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null) trailing,

              // TOMBOL HAPUS OTOMATIS
              if (showDelete) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
