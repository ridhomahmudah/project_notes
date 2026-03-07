import 'dart:ui';
import 'package:amuba_notes/services/file_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NotePreviewHelper {
  final dynamic themeController;
  final dynamic homeController;
  final Widget Function({
    required int id,
    required String title,
    required String content,
    required String date,
    bool isPreview,
  })
  bubbleNoteItemBuilder;

  // States
  bool _isCreatingNew = false;
  bool _isEditMode = false;
  final _selectedCategoriesToDelete = <String>[].obs;

  NotePreviewHelper({
    required this.themeController,
    required this.homeController,
    required this.bubbleNoteItemBuilder,
  });

  void showNotePreview(
    BuildContext context, {
    required int id,
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
                              id: id,
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
                            color: isDark ? Colors.grey[900] : Colors.white,
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
                              _buildMenuItem(
                                Icons.list,
                                "Add to List",
                                () => _showAddToListSheet(context, id),
                              ),
                              const Divider(
                                height: 1,
                                indent: 15,
                                endIndent: 15,
                              ),
                              _buildMenuItem(Icons.download, "Download ZIP", () {
                                // Panggil helper di sini
                                FileHelper.downloadNoteAsZip(
                                  title: title,
                                  imagePath:
                                      "",
                                  content: content,
                                );
                              }),
                              const Divider(
                                height: 1,
                                indent: 15,
                                endIndent: 15,
                              ),
                              _buildMenuItem(
                                Icons.delete_outline,
                                "Delete Note",
                                () {
                                  homeController.deleteNote(id);
                                },
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

  void _showAddToListSheet(BuildContext context, int noteId) {
    bool isDark = themeController.isDarkMode.value;
    _isCreatingNew = false;
    _isEditMode = false;
    _selectedCategoriesToDelete.clear();
    TextEditingController newListController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.black : Colors.grey[200],
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      _isCreatingNew
                          ? _buildNewListLayout(
                            context,
                            setSheetState,
                            newListController,
                            isDark,
                          )
                          : _buildMainListLayout(
                            context,
                            setSheetState,
                            isDark,
                            noteId,
                          ),
                ),
              );
            },
          ),
    );
  }

  // --- VIEW 1: MAIN LIST ---
  Widget _buildMainListLayout(
    BuildContext context,
    StateSetter setSheetState,
    bool isDark,
    int noteId,
  ) {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- HEADER ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.cancel,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ),
            Text(
              _isEditMode ? "Delete Categories" : "Add to List",
              style: GoogleFonts.montserrat(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            TextButton(
              onPressed: () => setSheetState(() => _isEditMode = !_isEditMode),
              child: Text(
                _isEditMode ? "Cancel" : "Edit",
                style: GoogleFonts.montserrat(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // SOLUSI OVERFLOW: Gunakan Flexible + SingleChildScrollView agar dinamis
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height *
                  0.4, // Batasi tinggi 40% layar
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isEditMode)
                    GestureDetector(
                      onTap: () => setSheetState(() => _isCreatingNew = true),
                      child: _buildSheetOption(
                        icon: Icons.add,
                        title: "New List",
                        isDark: isDark,
                      ),
                    ),
                  const SizedBox(height: 10),

                  // FIX GETX ERROR
                  Obx(() {
                    // Pastikan kita "menyentuh" variabel .obs agar Obx mendaftarkan listener
                    final allCategories = homeController.categories;
                    final selectedToDelete =
                        _selectedCategoriesToDelete
                            .toList(); // Pantau seleksi hapus

                    final displayCats =
                        allCategories.where((cat) => cat != "Semua").toList();

                    if (displayCats.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "No categories available",
                          style: GoogleFonts.montserrat(
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children:
                          displayCats.map<Widget>((cat) {
                            bool isSelectedToDelete = selectedToDelete.contains(
                              cat,
                            );

                            return GestureDetector(
                              onTap: () {
                                if (_isEditMode) {
                                  // Gunakan setSheetState untuk UI lokal, tapi variabelnya tetap .obs
                                  if (isSelectedToDelete) {
                                    _selectedCategoriesToDelete.remove(cat);
                                  } else {
                                    _selectedCategoriesToDelete.add(cat);
                                  }
                                  setSheetState(
                                    () {},
                                  ); // Trigger refresh StatefulBuilder
                                } else {
                                  homeController.moveNoteToCategory(
                                    noteId,
                                    cat,
                                  );
                                  Get.back();
                                  Get.snackbar(
                                    "Success",
                                    "Note moved to $cat",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor:
                                        isDark
                                            ? Colors.grey[900]
                                            : Colors.white,
                                    colorText:
                                        isDark ? Colors.white : Colors.black,
                                  );
                                }
                              },
                              child: _buildSheetOption(
                                icon: Icons.folder_open,
                                title: cat,
                                isDark: isDark,
                                trailing:
                                    _isEditMode
                                        ? _buildDeleteCheckbox(
                                          isSelectedToDelete,
                                        )
                                        : _buildRadioCircle(
                                          isDark,
                                          cat ==
                                              homeController
                                                  .selectedCategory
                                                  .value,
                                        ),
                              ),
                            );
                          }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Tombol Finish
        Obx(() {
          final count = _selectedCategoriesToDelete.length;
          return _buildFinishButton(
            isDark,
            _isEditMode ? "Delete Selected ($count)" : "Finish",
            () {
              if (_isEditMode) {
                if (_selectedCategoriesToDelete.isNotEmpty) {
                  // Salin list untuk menghindari error saat loop penghapusan
                  final toDelete = List<String>.from(
                    _selectedCategoriesToDelete,
                  );
                  for (var cat in toDelete) {
                    homeController.removeCategory(cat);
                  }
                  _selectedCategoriesToDelete.clear();
                }
                setSheetState(() => _isEditMode = false);
              } else {
                Get.back();
              }
            },
            color: (_isEditMode && count > 0) ? Colors.redAccent : null,
          );
        }),
      ],
    );
  }

  // --- VIEW 2: NEW LIST INPUT ---
  Widget _buildNewListLayout(
    BuildContext context,
    StateSetter setSheetState,
    TextEditingController controller,
    bool isDark,
  ) {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSheetHeader(
          isDark,
          "Create New List",
          () => setSheetState(() => _isCreatingNew = false),
          Icons.arrow_back_ios_new,
        ),
        const SizedBox(height: 25),
        _buildNewListInput(controller, isDark),
        const SizedBox(height: 40),
        _buildFinishButton(isDark, "Save & Finish", () {
          if (controller.text.isNotEmpty) {
            homeController.addCategory(controller.text);
            setSheetState(() => _isCreatingNew = false);
            controller.clear();
          }
        }),
      ],
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildDeleteCheckbox(bool isSelected) => Icon(
    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
    color: isSelected ? Colors.redAccent : Colors.grey,
  );

  Widget _buildRadioCircle(bool isDark, bool isSelected) => Icon(
    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
    color: isSelected ? Colors.green : (isDark ? Colors.white38 : Colors.grey),
  );

  Widget _buildSheetOption({
    required IconData icon,
    required String title,
    required bool isDark,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
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
    return ListTile(
      leading: Icon(
        icon,
        color: customColor ?? (isDark ? Colors.white : Colors.black87),
        size: 22,
      ),
      title: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          color: customColor ?? (isDark ? Colors.white : Colors.black87),
        ),
      ),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }

  Widget _buildNewListInput(TextEditingController controller, bool isDark) {
    return TextField(
      controller: controller,
      autofocus: true,
      style: GoogleFonts.montserrat(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: "Enter list name...",
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSheetHeader(
    bool isDark,
    String title,
    VoidCallback onAction,
    IconData icon,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onAction,
          icon: Icon(
            icon,
            color: isDark ? Colors.white38 : Colors.grey,
            size: 20,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildFinishButton(
    bool isDark,
    String label,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              color ??
              (isDark ? const Color(0xFF4E342E) : const Color(0xFF2D1B08)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
