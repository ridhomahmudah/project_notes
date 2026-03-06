import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _startTimer();
  }

  void _startTimer() async {
    await Future.delayed(const Duration(seconds: 3));
    // Pindah ke halaman utama dan hapus Splash dari stack
    Get.offAllNamed('/onboarding'); // Ganti dengan nama route yang benar untuk onboarding
  }
}