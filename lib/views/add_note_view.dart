import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/theme_controller.dart';
import '../controllers/add_note_controller.dart';
import '../controllers/home_controller.dart';
import '../services/theme.dart';
import '../widgets/home/note_bubble_item.dart';

class AddNoteView extends StatelessWidget {
  final themeController = Get.find<ThemeController>();
  final addNoteController = Get.put(AddNoteController());

  final isSearchingInNote = false.obs;
  final searchText = "".obs;

  AddNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = themeController.isDarkMode.value;

    final highlightedNoteController = SearchTextEditingController(
      searchTarget: searchText,
      highlightColor: Colors.orangeAccent,
    )..text = addNoteController.noteController.text;

    highlightedNoteController.addListener(() {
      addNoteController.noteController.text = highlightedNoteController.text;
    });

    return Scaffold(
      backgroundColor: isDark ? Themes.darkBg : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: _buildBackButton(isDark),
        actions: [_buildSaveButton(isDark)],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleInput(isDark),
            const SizedBox(height: 20),
            _buildImageArea(isDark),
            const SizedBox(height: 24),
            _buildContentInput(highlightedNoteController, isDark),

            // --- SISIPAN BARU: Section Lampiran Card ---
            _buildAttachedNotesSection(isDark),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => _buildBottomBar(context, isDark)),
    );
  }

  // --- HELPER BARU: Menampilkan list catatan terlampir ---
  Widget _buildAttachedNotesSection(bool isDark) {
    return Obx(() {
      if (addNoteController.attachedNotes.isEmpty)
        return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 40),
          Text(
            "Catatan Terlampir",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: addNoteController.attachedNotes.length,
            itemBuilder: (context, index) {
              final attached = addNoteController.attachedNotes[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color:
                        attached['color'] != null && attached['color'] != 0
                            ? Color(attached['color']).withOpacity(0.5)
                            : Colors.transparent,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    attached['title'] ?? "Tanpa Judul",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    attached['note'] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed:
                        () => addNoteController.removeAttachedNote(
                          attached['id'],
                        ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildBackButton(bool isDark) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 5),
            Text(
              "Kembali",
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
      child: ElevatedButton(
        onPressed: () => addNoteController.saveNoteToDB(),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Themes.amubaYellow : Themes.lightPrimary,
          foregroundColor: isDark ? Themes.lightPrimary : Themes.amubaWhite,
          shape: const StadiumBorder(),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 25),
        ),
        child: const Text(
          "Simpan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTitleInput(bool isDark) {
    return Row(
      children: [
        const Text("💡", style: TextStyle(fontSize: 28)),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: addNoteController.titleController,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: "Judul Catatan",
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageArea(bool isDark) {
    return Obx(() {
      final path = addNoteController.selectedImagePath.value;
      if (path.isEmpty) return const SizedBox.shrink();

      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              File(path),
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: GestureDetector(
              onTap: () => addNoteController.selectedImagePath.value = '',
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildContentInput(TextEditingController controller, bool isDark) {
    return TextField(
      controller: controller,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: TextStyle(
        fontSize: 18,
        height: 1.5,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: "Tulis sesuatu yang menarik...",
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        left: 20,
        right: 20,
        top: 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1F) : Colors.grey[100],
        border: Border(
          top: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Row(
        children: [
          if (isSearchingInNote.value)
            Expanded(
              child: TextField(
                autofocus: true,
                onChanged: (val) => searchText.value = val,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Cari kata...",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      isSearchingInNote.value = false;
                      searchText.value = "";
                    },
                  ),
                ),
              ),
            )
          else ...[
            Text(
              "Last edited $formattedTime",
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black45,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, size: 25),
              onPressed: () => isSearchingInNote.value = true,
              color: isDark ? Colors.white70 : Themes.lightPrimary,
            ),
            IconButton(
              icon: const Icon(Icons.note_add_outlined, size: 25),
              onPressed: () => _showInsertNoteDialog(context),
              color: isDark ? Colors.white70 : Themes.lightPrimary,
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz, size: 25),
              onPressed: () => _showExtrasMenu(context),
              color: isDark ? Colors.white70 : Themes.lightPrimary,
            ),
          ],
        ],
      ),
    );
  }

  void _showInsertNoteDialog(BuildContext context) {
    final homeController = Get.find<HomeController>();
    bool isDark = themeController.isDarkMode.value;

    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: isDark ? Themes.darkBg : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Text(
            "Pilih Catatan",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Obx(() {
              final list = homeController.notesList;
              if (list.isEmpty)
                return const Center(child: Text("Tidak ada catatan"));

              return GridView.builder(
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final Map<String, dynamic> note = list[index];
                  return GestureDetector(
                    onTap: () {
                      // LOGIKA SISIPAN: Lampirkan sebagai Card
                      addNoteController.attachNote(note);

                      if (note['imagePath'] != null &&
                          addNoteController.selectedImagePath.value.isEmpty) {
                        addNoteController.selectedImagePath.value =
                            note['imagePath'];
                      }
                      Get.back();
                    },
                    child: AbsorbPointer(
                      child: NoteBubbleItem(
                        id: note['id'] ?? 0,
                        title: note['title'] ?? "Tanpa Judul",
                        content: note['note'] ?? "",
                        date: note['date'] ?? "",
                        colorValue: note['color'],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showExtrasMenu(BuildContext context) {
    bool isDark = themeController.isDarkMode.value;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1F) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                onPressed: () => Get.back(),
              ),
            ),
            _buildExtrasHeader("CHANGE LABEL"),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _colorOption(Colors.red),
                _colorOption(Colors.orange),
                _colorOption(Colors.blue),
                _colorOption(Colors.green),
              ],
            ),
            const SizedBox(height: 25),
            const Divider(color: Colors.white10),
            _buildExtrasHeader("EXTRAS"),

            // 1. TAMBAHKAN INI: Supaya bisa upload/pilih gambar dulu
            _menuItem(Icons.image_outlined, "Upload Gambar", "Galeri", () {
              Get.back();
              addNoteController.pickImage();
            }, isDark),

            // 2. EDIT INI: Hapus yang double, sisakan satu untuk ke Editor
            _menuItem(Icons.edit_outlined, "Beri Garis", "Editor", () {
              Get.back();
              addNoteController.goToImageEditor();
            }, isDark),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExtrasHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _colorOption(Color color) {
    return GestureDetector(
      onTap: () {
        addNoteController.updateColor(color.value);
      },
      child: Obx(
        () => Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            // Beri border putih/hitam jika warna ini sedang terpilih
            border:
                addNoteController.selectedColor.value == color.value
                    ? Border.all(color: Colors.white, width: 3)
                    : Border.all(color: Colors.black12, width: 1),
            boxShadow: [
              if (addNoteController.selectedColor.value == color.value)
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
            ],
          ),
          child:
              addNoteController.selectedColor.value == color.value
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      trailing:
          sub.isNotEmpty
              ? Text(sub, style: const TextStyle(color: Colors.grey))
              : null,
    );
  }
}

class SearchTextEditingController extends TextEditingController {
  final RxString searchTarget;
  final Color highlightColor;
  SearchTextEditingController({
    required this.searchTarget,
    this.highlightColor = Colors.yellow,
  });

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (searchTarget.value.isEmpty) return TextSpan(text: text, style: style);
    final children = <TextSpan>[];
    final pattern = RegExp(
      RegExp.escape(searchTarget.value),
      caseSensitive: false,
    );
    final matches = pattern.allMatches(text);
    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex)
        children.add(
          TextSpan(text: text.substring(lastIndex, match.start), style: style),
        );
      children.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: style?.copyWith(
            backgroundColor: highlightColor,
            color: Colors.black,
          ),
        ),
      );
      lastIndex = match.end;
    }
    if (lastIndex < text.length)
      children.add(TextSpan(text: text.substring(lastIndex), style: style));
    return TextSpan(children: children, style: style);
  }
}
