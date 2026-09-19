import 'dart:async';

import 'package:flutter/material.dart';

import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? splashTimer;

  @override
  void initState() {
    super.initState();

    splashTimer = Timer(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingPage(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF999999),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Center(
            child: AspectRatio(
              aspectRatio: 393 / 852,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee'
                      '?auto=format&fit=crop&w=1000&q=90',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF287EB8),
                        );
                      },
                    ),

                    // طبقة اللون الأزرق فوق الصورة
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x775FA6D4),
                            Color(0xBB075F9C),
                            Color(0xDD004E86),
                          ],
                        ),
                      ),
                    ),

                    // اسم التطبيق في منتصف الشاشة
                    Align(
                      alignment: const Alignment(0, 0.06),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Bayan Travel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              shadows: [
                                Shadow(
                                  color: Color(0x33000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 9),

                          // شعار قريب من الشكل البنفسجي في Figma
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFFB02E),
                                  Color(0xFFF249A0),
                                  Color(0xFF7928CA),
                                ],
                              ).createShader(bounds);
                            },
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
