import 'package:amuba_notes/services/db_helper.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final List<String> months = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember",
  ];

  var currentMonthIndex = 0.obs;
  // Ini adalah data asli dari database
  var notesList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    currentMonthIndex.value = DateTime.now().month - 1;
    // WAJIB panggil getNotes saat init agar data muncul saat aplikasi dibuka
    getNotes(); 
  }

  // --- LOGIKA DATABASE ---
  
  void getNotes() async {
    // Mengambil data terbaru dari SQLite
    List<Map<String, dynamic>> notes = await DBHelper.query();
    notesList.assignAll(notes); 
    print("Data dimuat: ${notesList.length} catatan");
  }

  // Hapus satu catatan (Swipe atau Long Press)
  void deleteNote(int id) async {
    await DBHelper.delete(id); 
    getNotes(); // Refresh list setelah hapus
  }

  // --- LOGIKA BULAN ---

  void nextMonth() {
    if (currentMonthIndex.value < months.length - 1) {
      currentMonthIndex.value++;
    } else {
      currentMonthIndex.value = 0; 
    }
  }

  void prevMonth() {
    if (currentMonthIndex.value > 0) {
      currentMonthIndex.value--;
    } else {
      currentMonthIndex.value = months.length - 1;
    }
  }

  String get currentMonthName => months[currentMonthIndex.value];

  // --- LOGIKA KATEGORI ---
  
  var categories = <String>["Semua"].obs;
  var selectedCategory = "Semua".obs;

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  void addCategory(String name) {
    if (name.isNotEmpty && !categories.contains(name)) {
      categories.add(name);
    }
  }

  void removeCategory(String name) {
    if (name != "Semua") {
      categories.remove(name);
      if (selectedCategory.value == name) selectedCategory.value = "Semua";
    }
  }

  // --- LOGIKA SELEKSI (MULTIPLE DELETE) ---
  
  var isSelectionMode = false.obs;
  // Simpan ID dari database, bukan index List, agar lebih akurat saat hapus
  var selectedNoteIds = <int>[].obs; 

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedNoteIds.clear();
    }
  }

  void toggleNoteSelection(int id) {
    if (selectedNoteIds.contains(id)) {
      selectedNoteIds.remove(id);
    } else {
      selectedNoteIds.add(id);
    }

    if (selectedNoteIds.isEmpty) isSelectionMode.value = false;
  }

  // Fitur Select All (Mengikuti jumlah data di database)
  void selectAll() {
    if (selectedNoteIds.length == notesList.length) {
      selectedNoteIds.clear();
      isSelectionMode.value = false;
    } else {
      // Ambil semua ID dari notesList
      selectedNoteIds.assignAll(notesList.map((e) => e['id'] as int).toList());
      isSelectionMode.value = true;
    }
  }

  // Fitur Hapus Massal dari SQLite
  void deleteSelectedNotes() async {
    if (selectedNoteIds.isEmpty) return;

    for (int id in selectedNoteIds) {
      await DBHelper.delete(id); // Hapus satu-satu berdasarkan ID yang dipilih
    }

    // Reset state
    selectedNoteIds.clear();
    isSelectionMode.value = false;
    
    // Tarik data terbaru
    getNotes();

    Get.snackbar(
      "Berhasil",
      "Catatan telah dibersihkan",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  bool isNoteSelected(int id) => selectedNoteIds.contains(id);
}