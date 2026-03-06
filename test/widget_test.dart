import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:amuba_notes/main.dart';
import 'package:amuba_notes/controllers/theme_controller.dart';

void main() {
  testWidgets('Amuba Notes Splash Load Test', (WidgetTester tester) async {
    // 1. Inisialisasi GetStorage untuk testing
    GetStorage.init();

    // 2. Inject ThemeController yang dibutuhkan MyApp
    final themeController = Get.put(ThemeController());

    // 3. Build app dan masukkan themeController sebagai argumen
    await tester.pumpWidget(MyApp(themeController: themeController));

    // 4. Verifikasi apakah teks Splash muncul (contoh: Nama Aplikasi)
    expect(find.text('AMUBA Notes'), findsOneWidget);
  });
}