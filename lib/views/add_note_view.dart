import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/theme_controller.dart';
import '../controllers/add_note_controller.dart';
import '../services/theme.dart';

// --- CUSTOM CONTROLLER UNTUK HIGHLIGHT ---
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
      if (match.start > lastIndex) {
        children.add(
          TextSpan(text: text.substring(lastIndex, match.start), style: style),
        );
      }
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

    if (lastIndex < text.length) {
      children.add(TextSpan(text: text.substring(lastIndex), style: style));
    }

    return TextSpan(children: children, style: style);
  }
}

class AddNoteView extends StatelessWidget {
  final themeController = Get.find<ThemeController>();
  final addNoteController = Get.put(AddNoteController());
  
  final isSearchingInNote = false.obs;
  final searchText = "".obs;

  AddNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    final highlightedNoteController = SearchTextEditingController(
      searchTarget: searchText,
      highlightColor: Colors.orangeAccent,
    )..text = addNoteController.noteController.text;

    highlightedNoteController.addListener(() {
      addNoteController.noteController.text = highlightedNoteController.text;
    });

    return Obx(() {
      bool isDark = themeController.isDarkMode.value;
      String formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

      return Scaffold(
        backgroundColor: isDark ? Themes.darkBg : Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: GestureDetector(
            onTap: () => Get.back(),
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios_new, size: 18, color: isDark ? Colors.white : Colors.black),
                  const SizedBox(width: 5),
                  Text("Kembali", style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black)),
                ],
              ),
            ),
          ),
          actions: [
            Padding(
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
                child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("💡", style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: addNoteController.titleController,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "Judul Catatan",
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => addNoteController.pickImage(),
                child: Obx(() => ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: addNoteController.selectedImagePath.value == ''
                      ? Container(
                          height: 200, width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: isDark ? Colors.white38 : Colors.black26),
                              const SizedBox(height: 8),
                              Text("Tambah Gambar (Opsional)", style: TextStyle(color: isDark ? Colors.white38 : Colors.black26)),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            Image.file(File(addNoteController.selectedImagePath.value), width: double.infinity, height: 250, fit: BoxFit.cover),
                            Positioned(
                              right: 10, top: 10,
                              child: GestureDetector(
                                onTap: () => addNoteController.selectedImagePath.value = '',
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                )),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: highlightedNoteController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(fontSize: 18, height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Tulis sesuatu yang menarik...",
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),

        // --- BOTTOM BAR ---
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            left: 20, right: 20, top: 10,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1F) : Colors.grey[100],
            border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
          ),
          child: Obx(() => Row(
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
                  "Terakhir diedit $formattedTime",
                  style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search, size: 25),
                  onPressed: () => isSearchingInNote.value = true,
                  color: isDark ? Colors.white70 : Themes.lightPrimary,
                ),
                IconButton(
                  icon: const Icon(Icons.note_add_outlined, size: 25),
                  onPressed: () => print("Sisipkan catatan lain"),
                  color: isDark ? Colors.white70 : Themes.lightPrimary,
                ),
                IconButton(
                  icon: const Icon(Icons.file_download_outlined, size: 25),
                  onPressed: () => print("Download catatan"),
                  color: isDark ? Colors.white70 : Themes.lightPrimary,
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 25),
                  onPressed: () => _showExtrasMenu(context),
                  color: isDark ? Colors.white70 : Themes.lightPrimary,
                ),
              ],
            ],
          )),
        ),
      );
    });
  }

  // --- FITUR EXTRAS MENU ---
  void _showExtrasMenu(BuildContext context) {
    bool isDark = themeController.isDarkMode.value;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1F) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.cancel_outlined, color: isDark ? Colors.white38 : Colors.black38),
              ),
            ),
            const Text("CHANGE LABEL", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            const Text("EXTRAS", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            _menuItem(Icons.upload_outlined, "Upload Gambar", "Pilih Gambar", () {
              Get.back();
              addNoteController.pickImage();
            }, isDark),
            _menuItem(Icons.edit_outlined, "Beri Garis", "", () {}, isDark),
            _menuItem(Icons.delete_outline, "Delete Note", "", () {}, isDark, isDelete: true),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _colorOption(Color color) {
    return Container(width: 35, height: 35, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  Widget _menuItem(IconData icon, String title, String sub, VoidCallback onTap, bool isDark, {bool isDelete = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDelete ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black87)),
      title: Text(title, style: TextStyle(color: isDelete ? Colors.redAccent : (isDark ? Colors.white : Colors.black))),
      trailing: sub.isNotEmpty ? Text(sub, style: const TextStyle(color: Colors.grey)) : null,
    );
  }
}