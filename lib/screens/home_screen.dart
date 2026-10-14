import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'class_list_screen.dart';
import 'class_management_screen.dart';
import 'excel_files_screen.dart';

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

  // باز کردن صفحه ایجاد صنف
  Future<void> openClassManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClassManagementScreen()),
    );

    if (!mounted) return;
    setState(() {});
  }

  // باز کردن لیست صنوف
  Future<void> openClassList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClassListScreen()),
    );

    if (!mounted) return;
    setState(() {});
  }

  // باز کردن فایل‌های Excel
  Future<void> openExcelFiles() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExcelFilesScreen()),
    );

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // اندازه صفحه با MediaQuery
    final mediaQuery = MediaQuery.of(context);

    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;

    // اندازه‌ها متناسب با عرض و ارتفاع صفحه
    final double horizontalPadding = (screenWidth * 0.05).clamp(12.0, 28.0);

    final double sectionSpacing = (screenHeight * 0.018).clamp(10.0, 20.0);

    final double titleFontSize = (screenWidth * 0.05).clamp(18.0, 24.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,

        appBar: AppBar(
          elevation: 0,
          backgroundColor: backgroundColor,
          centerTitle: true,
          title: Text(
            'مدیریت صنف‌ها',
            style: GoogleFonts.vazirmatn(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              screenHeight * 0.012,
              horizontalPadding,
              screenHeight * 0.035,
            ),
            child: Column(
              children: [
                _buildHero(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),

                SizedBox(height: sectionSpacing),

                _buildCreateClassButton(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),

                SizedBox(height: sectionSpacing),

                _buildClassListCard(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),

                SizedBox(height: sectionSpacing),

                _buildExcelFilesCard(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ],
            ),
          ),
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 10,
          selectedItemColor: primaryBlue,
          unselectedItemColor: secondaryTextColor,

          selectedLabelStyle: GoogleFonts.vazirmatn(
            fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
            fontWeight: FontWeight.w500,
          ),

          unselectedLabelStyle: GoogleFonts.vazirmatn(
            fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
            fontWeight: FontWeight.w400,
          ),

          onTap: (index) {
            if (index == 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('صفحه مدیریت سوالات هنوز وصل نشده است.'),
                ),
              );
            }
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'خانه',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz_rounded),
              activeIcon: Icon(Icons.quiz_rounded),
              label: 'سوالات',
            ),
          ],
        ),
      ),
    );
  }

  // Hero
  Widget _buildHero({
    required double screenWidth,
    required double screenHeight,
  }) {
    final double padding = (screenWidth * 0.055).clamp(16.0, 28.0);

    final double iconSize = (screenWidth * 0.14).clamp(42.0, 68.0);

    final double headingSize = (screenWidth * 0.052).clamp(19.0, 25.0);

    final double descriptionSize = (screenWidth * 0.032).clamp(12.0, 16.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryBlue, lightBlue],
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
                    fontSize: headingSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: screenHeight * 0.009),

                Text(
                  'صنف‌ها، سوالات و ارزیابی‌های خود را مدیریت کنید.',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.vazirmatn(
                    fontSize: descriptionSize,
                    height: 1.7,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: screenWidth * 0.025),

          Icon(Icons.school_rounded, size: iconSize, color: Colors.white),
        ],
      ),
    );
  }

  // ایجاد صنف جدید
  Widget _buildCreateClassButton({
    required double screenWidth,
    required double screenHeight,
  }) {
    return _buildMenuCard(
      title: 'ایجاد صنف جدید',
      icon: Icons.add_circle_outline_rounded,
      iconColor: primaryBlue,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      onTap: openClassManagement,
    );
  }

  // لیست صنوف
  Widget _buildClassListCard({
    required double screenWidth,
    required double screenHeight,
  }) {
    return _buildMenuCard(
      title: 'لیست تمام صنوف ایجاد شده',
      icon: Icons.groups_rounded,
      iconColor: purple,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      onTap: openClassList,
    );
  }

  // فایل‌های Excel
  Widget _buildExcelFilesCard({
    required double screenWidth,
    required double screenHeight,
  }) {
    return _buildMenuCard(
      title: 'فایل‌های تبدیل شده به اکسل',
      icon: Icons.table_chart_rounded,
      iconColor: excelGreen,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      onTap: openExcelFiles,
    );
  }

  // کارت عمومی
  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onTap,
  }) {
    final double iconBoxSize = (screenWidth * 0.125).clamp(44.0, 54.0);

    final double iconSize = (screenWidth * 0.07).clamp(23.0, 30.0);

    final double cardPadding = (screenWidth * 0.045).clamp(14.0, 22.0);

    final double titleSize = (screenWidth * 0.038).clamp(13.0, 17.0);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: cardPadding,
            vertical: (screenHeight * 0.023).clamp(14.0, 24.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: iconSize),
                ),

                SizedBox(width: screenWidth * 0.035),

                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      title,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.vazirmatn(
                        fontSize: titleSize,
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
