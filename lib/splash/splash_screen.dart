import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconScale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _iconScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.65, curve: Curves.elasticOut),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 1, curve: Curves.easeIn),
    );

    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  TextStyle _style(double size, Color color, FontWeight weight) {
    return GoogleFonts.notoSansArabic(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.7,
    );
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF3478F6);
    const navy = Color(0xFF172B5B);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              const Spacer(flex: 2),

              ScaleTransition(
                scale: _iconScale,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(42),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE7F0FF), Color(0xFFD6E5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blue.withValues(alpha: 0.16),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.assignment_rounded,
                        size: 86,
                        color: blue,
                      ),
                      Positioned(
                        right: 15,
                        bottom: 15,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF16B89A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF5F8FF),
                              width: 4,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 27,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    children: [
                      Text(
                        'به اپلیکیشن ارزیابی صنف',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: _style(25, navy, FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'خوش آمدید!',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: _style(27, blue, FontWeight.w800),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'صنف‌ها، اعضا و ارزیابی‌ها را به آسانی '
                        'مدیریت کنید و نتایج را به صورت فایل '
                        'Excel دریافت کنید.',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: _style(
                          15,
                          const Color(0xFF7182A8),
                          FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              FadeTransition(
                opacity: _fade,
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _start,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: blue.withValues(alpha: 0.28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 28),
                        child: Text(
                          'شروع کنید',
                          textDirection: TextDirection.rtl,
                          style: _style(17, Colors.white, FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
