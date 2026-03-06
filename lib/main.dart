import 'package:amuba_notes/controllers/theme_controller.dart';
import 'package:amuba_notes/services/theme.dart';
import 'package:amuba_notes/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Wajib untuk GetStorage
  
  final themeController = Get.put(ThemeController());

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Amuba Notes", 
    theme: Themes.light,
    darkTheme: Themes.dark,
    themeMode: themeController.theme, 
    home: HomeView(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "AMUBA Notes",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}