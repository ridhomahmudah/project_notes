import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amuba_notes/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFBFBFF), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Frame Foto Profil
            PhysicalModel(
              color: Colors.transparent,
              elevation: 8,
              shadowColor: Colors.black54,
              borderRadius: BorderRadius.zero,
              child: Image(
                image: AssetImage('assets/images/Splash.png'),
                width: 140,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 32),
            // Nama Aplikasi
            Text(
              'AMUBA Notes',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1B08),
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}