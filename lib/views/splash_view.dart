import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amuba_notes/controllers/splash_controller.dart';
import 'package:amuba_notes/controllers/theme_controller.dart';
import 'package:amuba_notes/services/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      bool isDark = themeController.isDarkMode.value;
      // Ambil status animasi dari controller
      bool animate = controller.startAnimation.value;

      return Scaffold(
        backgroundColor: isDark ? Themes.darkBg : const Color(0xFFFBFBFF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- ANIMASI UNTUK LOGO ---
              AnimatedOpacity(
                duration: const Duration(
                  milliseconds: 1500,
                ), // Durasi muncul perlahan
                curve: Curves.easeOut,
                opacity: animate ? 1.0 : 0.0, // Dari transparan ke muncul penuh
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.fastOutSlowIn,
                  scale:
                      animate ? 1.0 : 0.8, // Dari agak kecil ke ukuran normal
                  child: PhysicalModel(
                    color: Colors.transparent,
                    elevation: 8,
                    shadowColor: isDark ? Colors.black : Colors.black54,
                    borderRadius: BorderRadius.zero,
                    child: const Image(
                      image: AssetImage('assets/images/Splash.png'),
                      width: 140,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // --- ANIMASI UNTUK TEKS ---
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                // Beri sedikit delay agar teks muncul setelah logo (UX Tip)
                curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                opacity: animate ? 1.0 : 0.0,
                child: Text(
                  'AMUBA Notes',
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2D1B08),
                    letterSpacing: 1.1,
                    shadows: [
                      const Shadow(
                        blurRadius: 4,
                        color: Colors.black45,
                        offset: Offset(0.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
