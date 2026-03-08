import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  final box = GetStorage();
  
  // Variabel untuk mengontrol mulainya animasi
  var startAnimation = false.obs;

  @override
  void onReady() {
    super.onReady();
    _startAnimationAndTimer();
  }

  void _startAnimationAndTimer() async {
    // Tunggu sebentar setelah splash muncul, lalu mulai animasi
    await Future.delayed(const Duration(milliseconds: 100));
    startAnimation.value = true; // Picu animasi di View

    // Total waktu splash screen (termasuk durasi animasi)
    await Future.delayed(const Duration(seconds: 3));

    // Cek onboarding seperti logika sebelumnya
    bool hasSeenOnboarding = box.read('hasSeenOnboarding') ?? false;

    if (hasSeenOnboarding) {
      Get.offAllNamed('/home'); // Ganti dengan route utama Anda
    } else {
      Get.offAllNamed('/onboarding');
    }
  }
}