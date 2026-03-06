import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // 1. Tambahkan variabel reaktif .obs
  // Ini yang akan dipantau oleh Obx di View
  var isDarkMode = false.obs;

  @override
  void onInit() {
    // 2. Isi nilai isDarkMode sesuai data yang tersimpan saat pertama buka
    isDarkMode.value = _loadThemeFromBox();
    super.onInit();
  }

  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  void toggleTheme() {
    if (isDarkMode.value) {
      Get.changeThemeMode(ThemeMode.light);
      _saveThemeToBox(false);
      isDarkMode.value = false; // 3. Update nilai reaktifnya
    } else {
      Get.changeThemeMode(ThemeMode.dark);
      _saveThemeToBox(true);
      isDarkMode.value = true;  // 4. Update nilai reaktifnya
    }
  }

  void _saveThemeToBox(bool isDarkModeValue) => _box.write(_key, isDarkModeValue);
}