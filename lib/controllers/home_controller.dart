import 'package:get/get.dart';

class HomeController extends GetxController {
  final List<String> months = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember"
  ];

  // Index bulan sekarang (0-11)
  var currentMonthIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // SET KE BULAN SEKARANG SAAT APP DIBUKA
    currentMonthIndex.value = DateTime.now().month - 1;
  }

  void nextMonth() {
    if (isSelectionMode.value) return; // Kunci jika sedang memilih
    currentMonthIndex.value = (currentMonthIndex.value + 1) % 12;
  }
  void prevMonth() {
    if (isSelectionMode.value) return; // Kunci jika sedang memilih
    currentMonthIndex.value = (currentMonthIndex.value - 1 + 12) % 12;
  }

  String get currentMonthName => months[currentMonthIndex.value];

  // --- LOGIKA KATEGORI ---
  // Gunakan .obs pada List agar UI reaktif saat menambah/menghapus item
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

  // --- LOGIKA SELEKSI & CATATAN ---
  var isSelectionMode = false.obs;
  var selectedNotes = <int>[].obs; 
  
  // Dummy total item untuk simulasi Select All (Ganti dengan length list catatan asli Anda nanti)
  int get totalNotesCount => 10; 

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedNotes.clear();
    }
  }

  void toggleNoteSelection(int index) {
    if (selectedNotes.contains(index)) {
      selectedNotes.remove(index);
    } else {
      selectedNotes.add(index);
    }
    
    // Otomatis matikan mode seleksi jika tidak ada lagi yang terpilih
    if (selectedNotes.isEmpty) isSelectionMode.value = false;
  }

  // Fitur Select All
  void selectAll() {
    if (selectedNotes.length == totalNotesCount) {
      selectedNotes.clear();
      isSelectionMode.value = false;
    } else {
      selectedNotes.assignAll(List.generate(totalNotesCount, (index) => index));
    }
  }

  // Fitur Hapus Catatan
  void deleteSelectedNotes() {
    // Logika hapus data dari database/list asli Anda di sini
    print("Menghapus index: $selectedNotes");
    
    // Reset state setelah hapus
    selectedNotes.clear();
    isSelectionMode.value = false;
    
    Get.snackbar(
      "Berhasil", 
      "Catatan yang dipilih telah dihapus",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  bool isNoteSelected(int index) => selectedNotes.contains(index);
}