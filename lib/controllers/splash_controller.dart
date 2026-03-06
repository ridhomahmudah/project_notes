import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _startTimer();
  }

  void _startTimer() async {
    // Delay 3 detik sesuai standar Splash Screen
    await Future.delayed(const Duration(seconds: 3));
    // Pindah ke halaman utama dan hapus Splash dari stack
    Get.offAllNamed('/home'); 
  }
}