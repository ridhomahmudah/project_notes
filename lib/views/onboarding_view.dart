import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';
import '../services/theme.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan warna background dari Themes yang kamu buat
      backgroundColor: Themes.darkBg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Gambar Utama
            Image.asset('assets/images/Add notes-bro.png', fit: BoxFit.contain),
            const SizedBox(height: 60),

            // 2. Teks Sambutan
            const Text(
              "Halo 👋 Selamat datang!\nSemua ide pentingmu bisa dimulai dari sini.",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 100),

            // 3. Tombol "Let's Get Started" (RUMPANG)
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Themes.darkPrimary, // Warna tombol sesuai tema gelap
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // ISI DI SINI: Gunakan GetX untuk pindah ke Home
                  // Pastikan user tidak bisa kembali ke sini (offAll)
                  Get.offAllNamed(
                    Routes.HOME,
                  ); // Ganti dengan nama route yang benar
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Let's Get Started",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 12),
                    // ISI DI SINI: Tambahkan Icon panah ke kanan
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
