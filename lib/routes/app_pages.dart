import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../views/home_view.dart'; 
import '../controllers/splash_controller.dart';
import '../views/onboarding_view.dart';
import '../views/add_note_view.dart';

abstract class Routes {
  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const ONBOARDING = '/onboarding';
  static const ADD_NOTE = '/add-note';
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
      page: () => HomeView(), 
    ),

    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingView(),
    ),

    GetPage(
      name: Routes.ADD_NOTE,
      page: () => AddNoteView(),
    ),
  ];
}