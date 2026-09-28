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
  // ============================================================
  // Variables
  // ============================================================

  List<ClassModel> classes = [];

  bool isLoading = true;

  // ذخیره وضعیت باز یا بسته بودن اعضای هر صنف
  final Set<int> expandedClasses = {};

  // ============================================================
  // Init
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  // ============================================================
  // دریافت صنوف از Isar
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

  // ============================================================
  // باز / بسته کردن اعضای صنف
  // ============================================================

  void _toggleMembers(int classId) {
    setState(() {
      if (expandedClasses.contains(classId)) {
        expandedClasses.remove(classId);
      } else {
        expandedClasses.add(classId);
      }
    });
  }

  // ============================================================
  // Build
  // ============================================================
late String classTime;
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
                  child: CircularProgressIndicator(
                    color: purpleColor,
                  ),
                )
              : classes.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: purpleColor,
                      onRefresh: _refreshClasses,
                      child: ListView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
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
    final bool isExpanded =
        expandedClasses.contains(classModel.id);

    return Container(
      width: double.infinity,

      margin: EdgeInsets.only(
        bottom: screenHeight * 0.018,
      ),

      padding: EdgeInsets.all(
        screenWidth * 0.045,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
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
          // Header - نام صنف
          // ====================================================

          Row(
            textDirection: TextDirection.rtl,
            children: [
              // آیکون صنف
              Container(
                width: screenWidth * 0.14,
                height: screenWidth * 0.14,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7FF),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: purpleColor,
                  size: screenWidth * 0.075,
                ),
              ),

              SizedBox(
                width: screenWidth * 0.035,
              ),

              // نام صنف
              Expanded(
                child: Wrap(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // عنوان
                    Text(
                      'نام صنف:',
                      textDirection:
                          TextDirection.rtl,
                      style:
                          GoogleFonts.notoSansArabic(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                        color: const Color(
                          0xFF172B5B,
                        ),
                      ),
                    ),

                    // نام وارد شده
                    Text(
                      classModel.className,
                      textDirection:
                          TextDirection.rtl,
                      style:
                          GoogleFonts.notoSansArabic(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.normal,
                        color: const Color(
                          0xFF26364D,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(
            height: screenHeight * 0.018,
          ),

          // ====================================================
          // استاد
          // ====================================================

          _buildInfoRow(
            icon: Icons.person_rounded,
            title: 'استاد',
            value: classModel.teacherName,
            iconColor: const Color(0xFF1565E8),
            backgroundColor:
                const Color(0xFFE6F0FF),
            screenWidth: screenWidth,
          ),
const SizedBox(height: 10),

_buildInfoRow(
  icon: Icons.access_time_rounded,
  title: 'تایم درسی',
  value: classModel.classTime,
  iconColor: const Color(0xFF8E44AD),
  backgroundColor: const Color(0xFFF0E5F7),
  screenWidth: screenWidth,
),
          const SizedBox(height: 10),

          // ====================================================
          // تعداد اعضا
          // ====================================================

          _buildInfoRow(
            icon: Icons.groups_rounded,
            title: 'تعداد اعضا',
            value:
                '${classModel.members.length} نفر',
            iconColor: const Color(0xFF239B56),
            backgroundColor:
                const Color(0xFFDDF3E5),
            screenWidth: screenWidth,
          ),

          const SizedBox(height: 15),

          // ====================================================
          // دکمه اعضای صنف
          // ====================================================

          InkWell(
            borderRadius:
                BorderRadius.circular(14),

            onTap: () {
              _toggleMembers(classModel.id);
            },

            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 250),

              width: double.infinity,

              padding:
                  const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 13,
              ),

              decoration: BoxDecoration(
                color: isExpanded
                    ? const Color(0xFFEDE7FF)
                    : const Color(0xFFF7F9FC),

                borderRadius:
                    BorderRadius.circular(14),

                border: Border.all(
                  color: isExpanded
                      ? const Color(0xFFD9CCFF)
                      : const Color(0xFFE8EDF4),
                ),
              ),

              child: Row(
                textDirection:
                    TextDirection.rtl,

                children: [
                  // =================================================
                  // آیکون اعضا
                  // =================================================

                  Container(
                    width: 36,
                    height: 36,

                    decoration: BoxDecoration(
                      color: isExpanded
                          ? Colors.white
                          : const Color(
                              0xFFE6F0FF,
                            ),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),

                    child: Icon(
                      Icons.people_alt_rounded,
                      size: 19,
                      color: isExpanded
                          ? const Color(
                              0xFF7C4DFF,
                            )
                          : const Color(
                              0xFF1565E8,
                            ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // =================================================
                  // عنوان اعضای صنف + تعداد
                  // =================================================

                  Expanded(
                    child: Wrap(
                      textDirection:
                          TextDirection.rtl,
                      crossAxisAlignment:
                          WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        // عنوان
                        Text(
                          'اعضای صنف:',
                          textDirection:
                              TextDirection.rtl,
                          style:
                              GoogleFonts.notoSansArabic(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.bold,
                            color: const Color(
                              0xFF172B5B,
                            ),
                          ),
                        ),

                        // تعداد
                        Text(
                          '${classModel.members.length} نفر',
                          textDirection:
                              TextDirection.rtl,
                          style:
                              GoogleFonts.notoSansArabic(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.normal,
                            color: const Color(
                              0xFF7C8DA8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // فلش باز / بسته
                  // =================================================

                  AnimatedRotation(
                    duration:
                        const Duration(
                      milliseconds: 250,
                    ),

                    turns:
                        isExpanded ? 0.5 : 0,

                    child: const Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      size: 25,
                      color:
                          Color(0xFF7C4DFF),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ====================================================
          // Members List
          // ====================================================

          AnimatedCrossFade(
            duration:
                const Duration(milliseconds: 300),

            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,

            firstChild: const SizedBox(
              width: double.infinity,
            ),

            secondChild: Padding(
              padding:
                  const EdgeInsets.only(top: 10),
              child:
                  _buildMembersList(classModel),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Members List
  // ============================================================

  Widget _buildMembersList(
    ClassModel classModel,
  ) {
    // ----------------------------------------------------------
    // اگر عضو وجود نداشته باشد
    // ----------------------------------------------------------

    if (classModel.members.isEmpty) {
      return Container(
        width: double.infinity,

        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius:
              BorderRadius.circular(13),
        ),

        child: Text(
          'هیچ عضوی ثبت نشده است',
          textDirection:
              TextDirection.rtl,
          textAlign: TextAlign.center,

          style:
              GoogleFonts.notoSansArabic(
            fontSize: 12,
            fontWeight:
                FontWeight.normal,
            color:
                const Color(0xFFD94B4B),
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // لیست اعضا
    // ----------------------------------------------------------

    return Column(
      children: List.generate(
        classModel.members.length,
        (index) {
          final student =
              classModel.members[index];

          return Container(
            width: double.infinity,

            margin:
                const EdgeInsets.only(
              bottom: 7,
            ),

            padding:
                const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),

            decoration: BoxDecoration(
              color:
                  const Color(0xFFFAFBFD),
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color:
                    const Color(0xFFE8EDF4),
              ),
            ),

            child: Row(
              textDirection:
                  TextDirection.rtl,

              children: [
                // =================================================
                // شماره
                // =================================================

                Container(
                  width: 29,
                  height: 29,
                  alignment:
                      Alignment.center,

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFE1EDFF),
                    borderRadius:
                        BorderRadius.circular(9),
                  ),

                  child: Text(
                    '${index + 1}',
                    style:
                        GoogleFonts.notoSansArabic(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          const Color(
                        0xFF1565E8,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // =================================================
                // نام شاگرد
                // =================================================

                Expanded(
                  child: Text(
                    student,
                    textDirection:
                        TextDirection.rtl,
                    textAlign:
                        TextAlign.right,

                    style:
                        GoogleFonts.notoSansArabic(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.normal,
                      color:
                          const Color(
                        0xFF26364D,
                      ),
                    ),
                  ),
                ),

                const Icon(
                  Icons
                      .person_outline_rounded,
                  size: 20,
                  color:
                      Color(0xFF9AA8BA),
                ),
              ],
            ),
          );
        },
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

      padding:
          const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: 12,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius:
            BorderRadius.circular(13),
      ),

      child: Row(
        textDirection:
            TextDirection.rtl,

        children: [
          // =====================================================
          // آیکون
          // =====================================================

          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 19,
            ),
          ),

          const SizedBox(width: 10),

          // =====================================================
          // عنوان + مقدار
          // =====================================================

          Expanded(
            child: Wrap(
              textDirection:
                  TextDirection.rtl,

              crossAxisAlignment:
                  WrapCrossAlignment.center,

              spacing: 6,
              runSpacing: 4,

              children: [
                // عنوان
                Text(
                  '$title:',
                  textDirection:
                      TextDirection.rtl,

                  style:
                      GoogleFonts.notoSansArabic(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        const Color(
                      0xFF172B5B,
                    ),
                  ),
                ),

                // مقدار وارد شده
                Text(
                  value,
                  textDirection:
                      TextDirection.rtl,

                  style:
                      GoogleFonts.notoSansArabic(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.normal,
                    color:
                        const Color(
                      0xFF26364D,
                    ),
                  ),
                ),
              ],
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
        physics:
            const AlwaysScrollableScrollPhysics(),

        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 25,
          ),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              // =================================================
              // آیکون
              // =================================================

              Container(
                width: 90,
                height: 90,

                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xFFEDE7FF),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.school_outlined,
                  size: 45,
                  color:
                      Color(0xFF7C4DFF),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // عنوان
              // =================================================

              Text(
                'هنوز هیچ صنفی ثبت نشده است',
                textDirection:
                    TextDirection.rtl,
                textAlign:
                    TextAlign.center,

                style:
                    GoogleFonts.notoSansArabic(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      const Color(
                    0xFF172B5B,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // =================================================
              // توضیحات
              // =================================================

              Text(
                'بعد از ایجاد صنف، تمام اطلاعات آن '
                'در این صفحه نمایش داده می‌شود.',

                textDirection:
                    TextDirection.rtl,

                textAlign:
                    TextAlign.center,

                style:
                    GoogleFonts.notoSansArabic(
                  fontSize: 12,
                  height: 1.7,
                  color:
                      const Color(
                    0xFF7C8DA8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}