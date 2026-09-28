import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void finishSplash(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              // ==================================================
              // Icon
              // ==================================================
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1EDFF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 52,
                  color: Color(0xFF3478F6),
                ),
              ),

              const SizedBox(height: 32),

              // ==================================================
              // Title
              // ==================================================
              Text(
                'به اپلیکیشن ارزیابی صنف خوش آمدید!',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.notoSansArabic(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF172B5B),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // Description
              // ==================================================
              Text(
                'صنف‌ها، اعضا و ارزیابی‌ها را مدیریت کنید و نتایج را به صورت Excel دریافت کنید.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.notoSansArabic(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7182A8),
                  height: 1.9,
                ),
              ),

              const Spacer(),

              // ==================================================
              // Start Button
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => finishSplash(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3478F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'شروع کنید',
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
