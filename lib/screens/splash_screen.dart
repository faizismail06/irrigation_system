// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/home_screen.dart';
import '../themes/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan warna dari tema gelap
    final backgroundColor = AppTheme.darkBackground;
    final primaryColor = const Color(0xFF2196F3); // warna biru

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              backgroundColor.withBlue(30),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animasi plant growing
              Container(
                height: 200,
                width: 200,
                margin: const EdgeInsets.only(bottom: 30),
                child: Lottie.network(
                  'https://lottie.host/50f73630-2b59-4bd0-95c4-894d2dbdaf90/nsUwCQIUaV.json',
                  controller: _animationController,
                  onLoaded: (composition) {
                    _animationController
                      ..duration = composition.duration
                      ..forward();
                  },
                  fit: BoxFit.contain,
                ),
              ),

              // Title
              Text(
                'SMART IRRIGATION',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOutQuad),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Sistem Irigasi Otomatis DRY/WET',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 800.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOutQuad),

              const SizedBox(height: 40),

              // Loading indicator
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey.shade800,
                    color: primaryColor,
                    minHeight: 6,
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 1200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
