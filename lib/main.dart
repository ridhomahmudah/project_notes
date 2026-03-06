import 'package:amuba_notes/services/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:amuba_notes/controllers/theme_controller.dart';
import 'package:amuba_notes/routes/app_pages.dart';
import 'package:amuba_notes/services/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await DBHelper.initDb(); // Inisialisasi database sebelum runApp
  final themeController = Get.put(ThemeController());

  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;
  
  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AMUBA Notes",
      
      // Konfigurasi Tema
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: themeController.theme,

      // Konfigurasi Navigasi (Splash sebagai awal)
      // AppPages.INITIAL harus berisi '/splash'
      initialRoute: AppPages.INITIAL, 
      getPages: AppPages.routes,
      
      // Hapus 'home: HomeView()', karena sudah diatur oleh initialRoute
    );
  }
}