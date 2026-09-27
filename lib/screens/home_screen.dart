import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'class_list_screen.dart';
import 'class_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // Constants
  // ============================================================

  static const Color backgroundColor = Color(0xFFF0F6FF);

  static const Color primaryTextColor = Color(0xFF172B5B);

  static const Color secondaryTextColor = Color(0xFF52627A);

  static const Color primaryBlue = Color(0xFF1565E8);

  static const Color lightBlue = Color(0xFF42A5F5);

  static const Color purpleColor =
      Color.fromARGB(255, 106, 60, 163);

  // ============================================================
  // Open Class Management
  // ============================================================

  Future<void> openClassManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ClassManagementScreen(),
      ),
    );
  }

  // ============================================================
  // Open Class List
  // ============================================================

  Future<void> openClassList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ClassListScreen(),
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery =
        MediaQuery.of(context);

    final double screenWidth =
        mediaQuery.size.width;

    final double screenHeight =
        mediaQuery.size.height;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // AppBar
      // ========================================================

      appBar: _buildAppBar(),

      // ========================================================
      // Body
      // ========================================================

      body: _buildBody(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),

      // ========================================================
      // Bottom Navigation
      // ========================================================

      bottomNavigationBar:
          _buildBottomNavigationBar(),
    );
  }

  // ============================================================
  // AppBar
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor,

      elevation: 0,

      surfaceTintColor: Colors.transparent,

      title: const Text(''),

      leading: IconButton(
        onPressed: () {},

        icon: const Icon(
          Icons.menu,
          color: primaryTextColor,
        ),
      ),

      actions: [
        IconButton(
          onPressed: () {},

          icon: const Icon(
            Icons.person,
            color: primaryTextColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Body
  // ============================================================

  Widget _buildBody({
    required double screenWidth,
    required double screenHeight,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [

          // ====================================================
          // Header Image
          // ====================================================

          _buildHeaderImage(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),

          SizedBox(
            height: screenHeight * 0.018,
          ),

          // ====================================================
          // Title
          // ====================================================

          _buildTitle(
            screenWidth: screenWidth,
          ),

          SizedBox(
            height: screenHeight * 0.01,
          ),

          // ====================================================
          // Description
          // ====================================================

          _buildDescription(
            screenWidth: screenWidth,
          ),

          SizedBox(
            height: screenHeight * 0.03,
          ),

          // ====================================================
          // Create Class Button
          // ====================================================

          _buildCreateClassButton(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),

          SizedBox(
            height: screenHeight * 0.018,
          ),

          // ====================================================
          // Class List Card
          // ====================================================

          _buildClassListCard(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),

          SizedBox(
            height: screenHeight * 0.02,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Header Image
  // ============================================================

  Widget _buildHeaderImage({
    required double screenWidth,
    required double screenHeight,
  }) {
    return Image.asset(
      'assets/images/photo_1.jpg',

      width: screenWidth,

      height: screenHeight * 0.44,

      fit: BoxFit.cover,
    );
  }

  // ============================================================
  // Title
  // ============================================================

  Widget _buildTitle({
    required double screenWidth,
  }) {
    return Text(
      'مدیریت و ایجاد صنف',

      textDirection: TextDirection.rtl,

      textAlign: TextAlign.center,

      style: GoogleFonts.notoSansArabic(
        fontSize: screenWidth * 0.055,

        fontWeight: FontWeight.bold,

        color: primaryTextColor,
      ),
    );
  }

  // ============================================================
  // Description
  // ============================================================

  Widget _buildDescription({
    required double screenWidth,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.07,
      ),

      child: Text(
        'برای ایجاد و مدیریت صنف خود از گزینه زیر استفاده کنید.',

        textAlign: TextAlign.center,

        textDirection: TextDirection.rtl,

        style: GoogleFonts.notoSansArabic(
          fontSize: screenWidth * 0.037,

          color: secondaryTextColor,
        ),
      ),
    );
  }

  // ============================================================
  // Create Class Button
  // ============================================================

  Widget _buildCreateClassButton({
    required double screenWidth,
    required double screenHeight,
  }) {
    return GestureDetector(
      onTap: openClassManagement,

      child: Container(
        width: screenWidth * 0.7,

        height: screenHeight * 0.065,

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              lightBlue,
              primaryBlue,
            ],

            begin: Alignment.centerLeft,

            end: Alignment.centerRight,
          ),

          borderRadius:
              BorderRadius.circular(30),

          boxShadow: [
            BoxShadow(
              color:
                  primaryBlue.withOpacity(0.25),

              blurRadius: 18,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            // ==================================================
            // Add Icon
            // ==================================================

            Container(
              width: screenWidth * 0.12,

              height: screenWidth * 0.12,

              decoration:
                  const BoxDecoration(
                color: Colors.white,

                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.add_rounded,

                size: screenWidth * 0.075,

                color: primaryBlue,
              ),
            ),

            SizedBox(
              width: screenWidth * 0.035,
            ),

            // ==================================================
            // Button Text
            // ==================================================

            Text(
              'ایجاد صنف جدید',

              textDirection:
                  TextDirection.rtl,

              style:
                  GoogleFonts.notoSansArabic(
                fontSize:
                    screenWidth * 0.045,

                fontWeight:
                    FontWeight.w700,

                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Class List Card
  // ============================================================

  Widget _buildClassListCard({
    required double screenWidth,
    required double screenHeight,
  }) {
    return GestureDetector(

      // ========================================================
      // مهم:
      // با کلیک روی این کانتینر صفحه لیست صنوف باز می‌شود.
      // ========================================================

      onTap: openClassList,

      child: Container(
        width: screenWidth * 0.9,

        height: screenHeight * 0.13,

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(15),

          border: Border.all(
            color: Colors.black,
            width: 0.5,
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.08),

              blurRadius: 10,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [

            // ==================================================
            // Icon
            // ==================================================

            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.05,

                right: screenWidth * 0.04,
              ),

              child: Icon(
                Icons.article_rounded,

                color: purpleColor,

                size: screenWidth * 0.11,
              ),
            ),

            // ==================================================
            // Text
            // ==================================================

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: screenWidth * 0.03,
                ),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  crossAxisAlignment:
                      CrossAxisAlignment.end,

                  children: [

                    Text(
                      'لیست صنوف',

                      textDirection:
                          TextDirection.rtl,

                      textAlign:
                          TextAlign.right,

                      style:
                          GoogleFonts.notoSansArabic(
                        fontSize:
                            screenWidth * 0.045,

                        fontWeight:
                            FontWeight.bold,

                        color: Colors.black,
                      ),
                    ),

                    SizedBox(
                      height:
                          screenHeight * 0.008,
                    ),

                    Text(
                      'مشاهده و مدیریت صنوف ثبت شده',

                      textDirection:
                          TextDirection.rtl,

                      textAlign:
                          TextAlign.right,

                      style:
                          GoogleFonts.notoSansArabic(
                        fontSize:
                            screenWidth * 0.027,

                        color:
                            Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // Arrow
            // ==================================================

            Padding(
              padding: EdgeInsets.only(
                right: screenWidth * 0.025,
              ),

              child: Icon(
                Icons
                    .arrow_forward_ios_rounded,

                size: screenWidth * 0.045,

                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Bottom Navigation
  // ============================================================

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,

      selectedItemColor:
          purpleColor,

      unselectedItemColor:
          Colors.grey,

      type:
          BottomNavigationBarType.fixed,

      items: const [

        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_outlined,
          ),

          activeIcon: Icon(
            Icons.home,
          ),

          label: 'خانه',
        ),

        BottomNavigationBarItem(
          icon: Icon(
            Icons.output_outlined,
          ),

          activeIcon: Icon(
            Icons.output,
          ),

          label: 'خروجی',
        ),
      ],
    );
  }
}