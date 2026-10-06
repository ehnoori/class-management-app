import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'class_list_screen.dart';
import 'class_management_screen.dart';
import 'excel_files_screen.dart';
import 'question_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color backgroundColor = Color(0xFFF4F7FC);
  static const Color primaryTextColor = Color(0xFF172B5B);
  static const Color secondaryTextColor = Color(0xFF68758A);

  static const Color primaryBlue = Color(0xFF1565E8);
  static const Color lightBlue = Color(0xFF42A5F5);

  static const Color purple = Color(0xFF6A3CA3);
  static const Color excelGreen = Color(0xFF2E9B57);

  // ============================================================
  // باز کردن صفحه ایجاد صنف
  // ============================================================

  Future<void> openClassManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ClassManagementScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // باز کردن لیست صنوف
  // ============================================================

  Future<void> openClassList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ClassListScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // باز کردن فایل‌های Excel
  // ============================================================

  Future<void> openExcelFiles() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExcelFilesScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // باز کردن صفحه سوالات
  // ============================================================

  Future<void> openQuestionManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QuestionManagementScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,

        // ========================================================
        // APP BAR
        // ========================================================

        appBar: AppBar(
          elevation: 0,
          backgroundColor: backgroundColor,
          centerTitle: true,

          title: Text(
            'مدیریت صنف‌ها',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.vazirmatn(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
        ),

        // ========================================================
        // BODY
        // ========================================================

        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),

            child: Column(
              children: [
                // Hero
                _buildHero(),

                const SizedBox(height: 14),

                // ایجاد صنف
                _buildCreateClassButton(),

                const SizedBox(height: 14),

                // لیست صنوف
                _buildClassListCard(),

                const SizedBox(height: 14),

                // Excel
                _buildExcelFilesCard(),
              ],
            ),
          ),
        ),

        // ========================================================
        // BOTTOM NAVIGATION
        // ========================================================

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,

          type: BottomNavigationBarType.fixed,

          backgroundColor: Colors.white,

          elevation: 10,

          selectedItemColor: primaryBlue,

          unselectedItemColor: secondaryTextColor,

          selectedLabelStyle: GoogleFonts.vazirmatn(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),

          unselectedLabelStyle: GoogleFonts.vazirmatn(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),

          // ======================================================
          // وقتی روی آیتم‌ها کلیک شود
          // ======================================================

          onTap: (index) {
            // خانه
            if (index == 0) {
              return;
            }

            // سوالات
            if (index == 1) {
              openQuestionManagement();
              return;
            }
          },

          items: const [
            // ====================================================
            // خانه
            // ====================================================

            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
              ),
              activeIcon: Icon(
                Icons.home_rounded,
              ),
              label: 'خانه',
            ),

            // ====================================================
            // سوالات
            // ====================================================

            BottomNavigationBarItem(
              icon: Icon(
                Icons.quiz_rounded,
              ),
              activeIcon: Icon(
                Icons.quiz_rounded,
              ),
              label: 'سوالات',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primaryBlue,
            lightBlue,
          ],

          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),

        borderRadius: BorderRadius.circular(22),
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'مدیریت صنف‌ها',

                  textAlign: TextAlign.right,

                  style: GoogleFonts.vazirmatn(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'صنف‌ها، سوالات و ارزیابی‌های خود را مدیریت کنید.',

                  textAlign: TextAlign.right,

                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    height: 1.7,
                    color: Colors.white.withValues(
                      alpha: 0.9,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          const Icon(
            Icons.school_rounded,
            size: 60,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ایجاد صنف جدید
  // ============================================================

  Widget _buildCreateClassButton() {
    return _buildMenuCard(
      title: 'ایجاد صنف جدید',
      icon: Icons.add_circle_outline_rounded,
      iconColor: primaryBlue,
      onTap: openClassManagement,
    );
  }

  // ============================================================
  // لیست صنوف
  // ============================================================

  Widget _buildClassListCard() {
    return _buildMenuCard(
      title: 'لیست تمام صنوف ایجاد شده',
      icon: Icons.groups_rounded,
      iconColor: purple,
      onTap: openClassList,
    );
  }

  // ============================================================
  // فایل‌های Excel
  // ============================================================

  Widget _buildExcelFilesCard() {
    return _buildMenuCard(
      title: 'فایل‌های تبدیل شده به اکسل',
      icon: Icons.table_chart_rounded,
      iconColor: excelGreen,
      onTap: openExcelFiles,
    );
  }

  // ============================================================
  // کارت اصلی
  // متن راست - آیکون چپ
  // ============================================================

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: Colors.grey.withValues(
                alpha: 0.10,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),

                blurRadius: 12,

                offset: const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),

          // LTR برای اینکه آیکون سمت چپ باشد
          child: Directionality(
            textDirection: TextDirection.ltr,

            child: Row(
              children: [
                // ==================================================
                // آیکون سمت چپ
                // ==================================================

                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    color: iconColor.withValues(
                      alpha: 0.10,
                    ),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 14),

                // ==================================================
                // متن سمت راست
                // ==================================================

                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,

                    child: Text(
                      title,

                      textAlign: TextAlign.right,

                      style: GoogleFonts.vazirmatn(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}