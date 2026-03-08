import 'dart:io';

import 'package:amuba_notes/services/db_helper.dart';
import 'package:archive/archive_io.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeController extends GetxController {
  final List<String> months = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
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

    loadCategories();
  }

  // --- LOGIKA DATABASE ---

  void getNotes() async {
    // Mengambil data terbaru dari SQLite
    List<Map<String, dynamic>> notes = await DBHelper.query();
    notesList.assignAll(notes);
    print("Data dimuat: ${notesList.length} catatan");
    if (notes.isNotEmpty) {
      print("Contoh format tanggal dari DB: ${notes[0]['date']}");
    }
  }

  // Hapus satu catatan (Swipe atau Long Press)
  void deleteNote(int id) async {
    await DBHelper.delete(id);
    getNotes(); // Refresh list setelah hapus
  }

  // --- LOGIKA BULAN ---

  void nextMonth() {
    searchQuery.value = ""; // Reset search saat ganti bulan
    if (currentMonthIndex.value < months.length - 1) {
      currentMonthIndex.value++;
    } else {
      currentMonthIndex.value = 0;
    }
  }

  void prevMonth() {
    searchQuery.value = ""; // Reset search saat ganti bulan
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

  void loadCategories() async {
    List<Map<String, dynamic>> data = await DBHelper.getCategories();
    if (data.isNotEmpty) {
      // Ubah Map ke List<String>
      categories.assignAll(data.map((e) => e['name'].toString()).toList());
    } else {
      categories.assignAll(["Semua"]);
    }
  }

  // Tambah kategori dan simpan ke DB
  void addCategory(String name) async {
    if (name.isNotEmpty && !categories.contains(name)) {
      await DBHelper.insertCategory(name); // Simpan ke SQLite
      loadCategories(); // Refresh list
    }
  }

  void moveNoteToCategory(int id, String categoryName) async {
    // 1. Update di Database SQLite
    // Pastikan di DBHelper kamu punya fungsi updateCategory(id, name)
    await DBHelper.updateNoteCategory(id, categoryName);

    // 2. Refresh data di aplikasi agar UI terupdate
    getNotes();

    print("Catatan ID $id sekarang masuk kategori: $categoryName");
  }

  void removeCategory(String name) async {
    if (name != "Semua") {
      await DBHelper.deleteCategory(name); // Hapus dari SQLite
      loadCategories(); // Refresh list categories
      if (selectedCategory.value == name) selectedCategory.value = "Semua";
      getNotes(); // Refresh catatan
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
  }

  bool isNoteSelected(int id) => selectedNoteIds.contains(id);

  // SEARCH
  var searchQuery = "".obs;

  // --- LOGIKA FILTER (BULAN SEBAGAI FILTER UTAMA) ---

  List<Map<String, dynamic>> get filteredNotes {
    // TAHAP 1: FILTER BULAN (Filter Utama)
    List<Map<String, dynamic>> step1 =
        notesList.where((note) {
          try {
            String dateStr = note['date'].toString();
            DateFormat inputFormat = DateFormat("dd MMMM yyyy, hh:mm a");
            DateTime noteDate = inputFormat.parse(dateStr);
            return noteDate.month == (currentMonthIndex.value + 1);
          } catch (e) {
            return false;
          }
        }).toList();

    // TAHAP 2: FILTER KATEGORI
    List<Map<String, dynamic>> step2;
    if (selectedCategory.value == "Semua") {
      // Jika pilih "Semua", jangan filter apa-apa, ambil hasil dari step 1
      step2 = step1;
    } else {
      // Jika pilih kategori spesifik (misal: 'Favorit'), saring yang cocok saja
      step2 =
          step1.where((note) {
            return note['category'] == selectedCategory.value;
          }).toList();
    }

    // TAHAP 3: FILTER SEARCH
    if (searchQuery.value.isEmpty) {
      return step2;
    } else {
      return step2.where((note) {
        final title = note['title']?.toString().toLowerCase() ?? "";
        final content = note['note']?.toString().toLowerCase() ?? "";
        final query = searchQuery.value.toLowerCase();
        return title.contains(query) || content.contains(query);
      }).toList();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void downloadSelectedNotesAsZip() async {
  if (selectedNoteIds.isEmpty) return;

  try {
    // 1. Inisialisasi ZIP Encoder
    final encoder = ZipFileEncoder();
    final directory = await getTemporaryDirectory();
    String timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final zipPath = '${directory.path}/AmubaNotes_$timeStamp.zip';
    
    encoder.create(zipPath);

    // 2. Loop melalui ID yang dipilih
    for (int id in selectedNoteIds) {
      // Cari data note berdasarkan ID
      final note = notesList.firstWhere((n) => n['id'] == id);
      String title = note['title'] ?? "Untitled_$id";
      String content = note['note'] ?? "";
      String date = note['date'] ?? "";
      String? imagePath = note['imagePath'];

      // Bersihkan karakter judul agar aman jadi nama file
      String safeTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '_');

      // 3. Tambahkan File Teks (.txt) untuk setiap catatan
      final textFile = File('${directory.path}/$safeTitle.txt');
      await textFile.writeAsString("Judul: $title\nTanggal: $date\n\n$content");
      encoder.addFile(textFile);

      // 4. Tambahkan Gambar jika ada (beri nama sesuai judul catatan)
      if (imagePath != null && imagePath.isNotEmpty) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          // Mendapatkan ekstensi file asli
          String extension = imagePath.split('.').last;
          // Menambahkan ke ZIP dengan nama yang unik agar tidak bentrok
          encoder.addFile(imageFile, '$safeTitle.$extension');
        }
      }
    }

    encoder.close();

    // 5. Trigger Share Sheet untuk menyimpan/mengirim ZIP
    await Share.shareXFiles(
      [XFile(zipPath)], 
      text: 'Ekspor ${selectedNoteIds.length} Catatan AMUBA'
    );

    // Opsional: Matikan mode seleksi setelah berhasil
    toggleSelectionMode();

  } catch (e) {
    print("Error ZIP: $e");
    Get.snackbar("Error", "Gagal membuat file ZIP");
  }
}
}
