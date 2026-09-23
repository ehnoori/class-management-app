
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/images/photo_1.jpg',
      'title': 'به اپلیکیشن ارزیابی صنف خوش آمدید!',
      'description':
          'با استفاده از این برنامه می‌توانید مشخصات صنف و اعضای آن را ثبت و ارزیابی کنید.',
    },
    {
      'image': 'assets/images/photo_2.jpg',
      'title': 'صنف‌های خود را مدیریت کنید',
      'description':
          'صنف جدید ایجاد کنید، اعضا را اضافه کنید و اطلاعات صنف‌ها را مدیریت کنید.',
    },
    {
      'image': 'assets/images/photo_3.jpg',
      'title': 'گزارش خود را دریافت کنید',
      'description':
          'پس از تکمیل ارزیابی، گزارش خود را به صورت Excel یا PDF دریافت کنید.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // رفتن به صفحه بعد یا پایان Onboarding
  void nextPage() {
    if (currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }

  // ذخیره اینکه کاربر Onboarding را دیده است
  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // Onboarding Pages
            // =========================
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,

                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },

                itemBuilder: (context, index) {
                  return _buildPage(
                    image: pages[index]['image']!,
                    title: pages[index]['title']!,
                    description: pages[index]['description']!,
                  );
                },
              ),
            ),

            // =========================
            // Page Indicator
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => _buildIndicator(index),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // Next / Start Button
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: nextPage,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3478F6),
                    foregroundColor: Colors.white,
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  child: Text(
                    currentPage == pages.length - 1
                        ? 'شروع کنید'
                        : 'ادامه',

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // =========================
  // Onboarding Page
  // =========================

  Widget _buildPage({
    required String image,
    required String title,
    required String description,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // Image
            SizedBox(
              height: 330,
              width: double.infinity,

              child: Image.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 25),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,

              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172B5B),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,

              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF7182A8),
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // Page Indicator
  // =========================

  Widget _buildIndicator(int index) {
    final bool isActive = currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      margin: const EdgeInsets.symmetric(horizontal: 5),

      width: isActive ? 24 : 9,
      height: 9,

      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF3478F6)
            : const Color(0xFFD2D9E8),

        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}