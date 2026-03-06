import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../controllers/splash_controller.dart';

class AppPages {
  static const INITIAL = '/splash';

  static final routes = [
    GetPage(
      name: '/splash',
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    // Tambahkan route Home nanti di sini
    // GetPage(name: '/home', page: () => HomeView()), 
  ];
}