import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/class_model.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  List<ClassModel> classes = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  // ============================================================
  // دریافت تمام صنوف از Isar
  // ============================================================

  Future<void> _loadClasses() async {
    try {
   final isar = await IsarService.getInstance();

final result = await isar.classModels.where().findAll();

      if (!mounted) return;

      setState(() {
        classes = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load Classes Error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // Refresh
  // ============================================================

  Future<void> _refreshClasses() async {
    await _loadClasses();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const purpleColor = Color(0xFF7C4DFF);
    const backgroundColor = Color(0xFFF3F7FC);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // AppBar
      // ========================================================
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,

        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF172B5B),
            ),
          ),
        ),

        title: Text(
          'لیست صنوف',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.notoSansArabic(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF172B5B),
          ),
        ),
      ),

      // ========================================================
      // Body
      // ========================================================
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.015,
          ),

          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: purpleColor),
                )
              : classes.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: purpleColor,
                  onRefresh: _refreshClasses,

                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),

                    itemCount: classes.length,

                    itemBuilder: (context, index) {
                      final classModel = classes[index];

                      return _buildClassCard(
                        classModel,
                        screenWidth,
                        screenHeight,
                        purpleColor,
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  // ============================================================
  // Class Card
  // ============================================================

  Widget _buildClassCard(
    ClassModel classModel,
    double screenWidth,
    double screenHeight,
    Color purpleColor,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: screenHeight * 0.018),
      padding: EdgeInsets.all(screenWidth * 0.045),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: const Color(0xFFE2E8F0)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          // ====================================================
          // Header
          // ====================================================

          Row(
            textDirection: TextDirection.rtl,

            children: [
              // Icon
              Container(
                width: screenWidth * 0.14,
                height: screenWidth * 0.14,

                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7FF),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Icon(
                  Icons.school_rounded,
                  color: purpleColor,
                  size: screenWidth * 0.075,
                ),
              ),

              SizedBox(width: screenWidth * 0.035),

              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    Text(
                      classModel.className,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: GoogleFonts.notoSansArabic(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF172B5B),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'نام صنف',
                      textDirection: TextDirection.rtl,

                      style: GoogleFonts.notoSansArabic(
                        fontSize: screenWidth * 0.027,
                        color: const Color(0xFF8A98AB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.018),

          // ====================================================
          // Teacher
          // ====================================================
          _buildInfoRow(
            icon: Icons.person_rounded,
            title: 'استاد',
            value: classModel.teacherName,
            iconColor: const Color(0xFF1565E8),
            backgroundColor: const Color(0xFFE6F0FF),
            screenWidth: screenWidth,
          ),

          const SizedBox(height: 10),

          // ====================================================
          // Class Type
          // ====================================================
          _buildInfoRow(
            icon: Icons.category_rounded,
            title: 'نوع صنف',
            value: classModel.classType,
            iconColor: const Color(0xFF7C4DFF),
            backgroundColor: const Color(0xFFEDE7FF),
            screenWidth: screenWidth,
          ),

          const SizedBox(height: 10),

          // ====================================================
          // Members Count
          // ====================================================
          _buildInfoRow(
            icon: Icons.groups_rounded,
            title: 'تعداد اعضا',
            value: '${classModel.members.length} نفر',
            iconColor: const Color(0xFF239B56),
            backgroundColor: const Color(0xFFDDF3E5),
            screenWidth: screenWidth,
          ),

          const SizedBox(height: 15),

          // ====================================================
          // Members Title
          // ====================================================
          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),

            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(13),
            ),

            child: Row(
              textDirection: TextDirection.rtl,

              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  size: 19,
                  color: Color(0xFF1565E8),
                ),

                const SizedBox(width: 8),

                Text(
                  'اعضای صنف',
                  textDirection: TextDirection.rtl,

                  style: GoogleFonts.notoSansArabic(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF172B5B),
                  ),
                ),

                const Spacer(),

                Text(
                  '${classModel.members.length} نفر',
                  textDirection: TextDirection.rtl,

                  style: GoogleFonts.notoSansArabic(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7C8DA8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ====================================================
          // تمام اعضا
          // ====================================================
          if (classModel.members.isEmpty)
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(13),
              ),

              child: Text(
                'هیچ عضوی ثبت نشده است',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,

                style: GoogleFonts.notoSansArabic(
                  fontSize: 12,
                  color: const Color(0xFFD94B4B),
                ),
              ),
            )
          else
            Column(
              children: List.generate(classModel.members.length, (index) {
                final student = classModel.members[index];

                return Container(
                  width: double.infinity,

                  margin: const EdgeInsets.only(bottom: 7),

                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFBFD),
                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: const Color(0xFFE8EDF4)),
                  ),

                  child: Row(
                    textDirection: TextDirection.rtl,

                    children: [
                      // شماره
                      Container(
                        width: 29,
                        height: 29,

                        alignment: Alignment.center,

                        decoration: BoxDecoration(
                          color: const Color(0xFFE1EDFF),
                          borderRadius: BorderRadius.circular(9),
                        ),

                        child: Text(
                          '${index + 1}',

                          style: GoogleFonts.notoSansArabic(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1565E8),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // نام شاگرد
                      Expanded(
                        child: Text(
                          student,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,

                          style: GoogleFonts.notoSansArabic(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF26364D),
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: Color(0xFF9AA8BA),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // Info Row
  // ============================================================

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color backgroundColor,
    required double screenWidth,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(13),
      ),

      child: Row(
        textDirection: TextDirection.rtl,

        children: [
          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(icon, color: iconColor, size: 19),
          ),

          const SizedBox(width: 10),

          Text(
            '$title:',
            textDirection: TextDirection.rtl,

            style: GoogleFonts.notoSansArabic(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF7C8DA8),
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              value,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,

              maxLines: 2,
              overflow: TextOverflow.ellipsis,

              style: GoogleFonts.notoSansArabic(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF26364D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Empty State
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                width: 90,
                height: 90,

                decoration: const BoxDecoration(
                  color: Color(0xFFEDE7FF),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.school_outlined,
                  size: 45,
                  color: Color(0xFF7C4DFF),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'هنوز هیچ صنفی ثبت نشده است',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,

                style: GoogleFonts.notoSansArabic(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF172B5B),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'بعد از ایجاد صنف، تمام اطلاعات آن در این صفحه نمایش داده می‌شود.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,

                style: GoogleFonts.notoSansArabic(
                  fontSize: 12,
                  height: 1.7,
                  color: const Color(0xFF7C8DA8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
