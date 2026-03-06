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
    // DateTime.now().month menghasilkan angka 1-12, jadi kita -1
    currentMonthIndex.value = DateTime.now().month - 1;
  }

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

  // Daftar Kategori
  final List<String> categories = ["Semua"];
  
  // Kategori yang sedang dipilih (reaktif)
  var selectedCategory = "Semua".obs;

  void changeCategory(String category) {
    selectedCategory.value = category;
  }
}