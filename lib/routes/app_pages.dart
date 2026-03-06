import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../views/home_view.dart'; 
import '../controllers/splash_controller.dart';

abstract class Routes {
  static const SPLASH = '/splash';
  static const HOME = '/home';
}

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(), // Hapus 'const' karena HomeView menggunakan Get.find
    ),
  ];
}