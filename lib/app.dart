import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_colors.dart';
import 'models/theme_store.dart';
import 'screens/dashboard_page.dart';
import 'screens/email_verification_page.dart';
import 'screens/splash_page.dart';

class BayanTravelApp extends StatelessWidget {
  const BayanTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeStore.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bayan Travel',

          themeMode: themeMode,

          // Light Mode
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            textTheme: GoogleFonts.poppinsTextTheme(),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.blue,
              primary: AppColors.blue,
              brightness: Brightness.light,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              labelStyle: GoogleFonts.poppins(
                color: AppColors.grey,
              ),
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFFA5A5A5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: AppColors.blue,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: AppColors.blue,
                  width: 1.7,
                ),
              ),
            ),
          ),

          // Dark Mode
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF101418),
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.dark().textTheme,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.blue,
              primary: AppColors.blue,
              brightness: Brightness.dark,
            ),
            cardColor: const Color(0xFF1C2228),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1C2228),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              labelStyle: GoogleFonts.poppins(
                color: const Color(0xFFB8C0C8),
              ),
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF808991),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: Color(0xFF3D8FD8),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: AppColors.blue,
                  width: 1.7,
                ),
              ),
            ),
          ),

          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase is still checking login status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final User? user = snapshot.data;

        // No logged-in user
        if (user == null) {
          return const SplashPage();
        }

        // Logged in but email is not verified
        if (!user.emailVerified) {
          return const EmailVerificationPage();
        }

        // Logged in + verified
        return const DashboardPage();
      },
    );
  }
}
