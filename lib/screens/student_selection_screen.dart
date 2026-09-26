import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'evaluation_screen.dart';

import '../models/class_model.dart';

class StudentSelectionScreen extends StatefulWidget {
  final ClassModel classModel;

  const StudentSelectionScreen({super.key, required this.classModel});

  @override
  State<StudentSelectionScreen> createState() => _StudentSelectionScreenState();
}

class _StudentSelectionScreenState extends State<StudentSelectionScreen> {
  int? selectedIndex;

  // ==================================================
  // Continue
  // ==================================================

  void continueToQuestions() {
    if (selectedIndex == null) {
      _showMessage('لطفاً یک شاگرد را انتخاب کنید');
      return;
    }

    final String selectedStudent = widget.classModel.members[selectedIndex!];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvaluationScreen(
          classModel: widget.classModel,
          studentName: selectedStudent,
        ),
      ),
    );
  }

  // ==================================================
  // Message
  // ==================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.notoSansArabic(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ==================================================
  // Build
  // ==================================================

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final List<String> students = widget.classModel.members;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),

      // ==================================================
      // AppBar
      // ==================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F7FC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
          'انتخاب شاگرد',
          style: GoogleFonts.notoSansArabic(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF172B5B),
          ),
        ),
      ),

      // ==================================================
      // Body
      // ==================================================
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.055,
            8,
            screenWidth * 0.055,
            20,
          ),
          child: Column(
            children: [
              // ==================================================
              // Header
              // ==================================================

              _buildHeader(students.length),

              const SizedBox(height: 18),

              // ==================================================
              // Students
              // ==================================================
              Expanded(
                child: students.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          return _buildStudentItem(
                            name: students[index],
                            index: index,
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // Continue Button
              // ==================================================
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================
  // Header
  // ==================================================

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3478F6), Color(0xFF1565E8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565E8).withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'انتخاب شاگرد',
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'یک شاگرد را برای ارزیابی انتخاب کنید',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.88),
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '$count شاگرد',
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // Student Item
  // ==================================================

  Widget _buildStudentItem({required String name, required int index}) {
    final bool isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: isSelected ? const Color(0xFF3478F6) : const Color(0xFFE4EAF3),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // ==================================================
              // Checkbox
              // ==================================================

              Checkbox(
                value: isSelected,
                activeColor: const Color(0xFF1565E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedIndex = index;
                    } else {
                      selectedIndex = null;
                    }
                  });
                },
              ),

              const SizedBox(width: 4),

              // ==================================================
              // Student Icon
              // ==================================================
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE1EDFF)
                      : const Color(0xFFF1F5FA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: isSelected
                      ? const Color(0xFF1565E8)
                      : const Color(0xFF7C8DA8),
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              // ==================================================
              // Name
              // ==================================================
              Expanded(
                child: Text(
                  name,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: const Color(0xFF172B5B),
                  ),
                ),
              ),

              // ==================================================
              // Number
              // ==================================================
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE1EDFF)
                      : const Color(0xFFF3F6FA),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFF1565E8)
                        : const Color(0xFF7C8DA8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================
  // Continue Button
  // ==================================================

  Widget _buildContinueButton() {
    final bool enabled = selectedIndex != null;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: enabled ? continueToQuestions : null,

        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),

        label: Text(
          'ادامه',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.notoSansArabic(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565E8),
          disabledBackgroundColor: const Color(0xFFB7C9E8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // ==================================================
  // Empty State
  // ==================================================

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'هیچ شاگردی برای این صنف ثبت نشده است',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: GoogleFonts.notoSansArabic(
          fontSize: 14,
          color: const Color(0xFF7C8DA8),
        ),
      ),
    );
  }
}
