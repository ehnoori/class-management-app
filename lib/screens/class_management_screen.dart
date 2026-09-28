import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../database/isar_service.dart';
import '../models/class_model.dart';
import 'student_selection_screen.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  // ============================================================
  // Controllers
  // ============================================================

  final TextEditingController classNameController = TextEditingController();

  final TextEditingController teacherController = TextEditingController();

  final TextEditingController classTimeController = TextEditingController();

  final TextEditingController memberController = TextEditingController();

  // ============================================================
  // Members
  // ============================================================

  final List<String> members = [];

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    classNameController.dispose();
    teacherController.dispose();
    classTimeController.dispose();
    memberController.dispose();

    super.dispose();
  }

  // ============================================================
  // Add Member
  // ============================================================

  void addMember() {
    final String memberName = memberController.text.trim();

    if (memberName.isEmpty) {
      _showMessage('لطفاً نام عضو را وارد کنید');
      return;
    }

    setState(() {
      members.add(memberName);
      memberController.clear();
    });
  }

  // ============================================================
  // Remove Member
  // ============================================================

  void removeMember(int index) {
    setState(() {
      members.removeAt(index);
    });
  }

  // ============================================================
  // Save Class
  // ============================================================

  Future<void> saveClass() async {
    final String className = classNameController.text.trim();
    final String teacherName = teacherController.text.trim();
    final String classTime = classTimeController.text.trim();

    // ------------------------------------------------------------
    // Validation
    // ------------------------------------------------------------

    if (className.isEmpty) {
      _showMessage('لطفاً نام صنف را وارد کنید');
      return;
    }

    if (teacherName.isEmpty) {
      _showMessage('لطفاً نام استاد را وارد کنید');
      return;
    }

    if (classTime.isEmpty) {
      _showMessage('لطفاً تایم درسی را وارد کنید');
      return;
    }

    if (members.isEmpty) {
      _showMessage('لطفاً حداقل یک عضو برای صنف اضافه کنید');
      return;
    }

    // ------------------------------------------------------------
    // Create Class Model
    // ------------------------------------------------------------

    final ClassModel newClass = ClassModel()
      ..className = className
      ..teacherName = teacherName
      ..classTime = classTime
      ..members = List<String>.from(members);

    // ------------------------------------------------------------
    // Save to Isar
    // ------------------------------------------------------------

    try {
      final isar = await IsarService.getInstance();

      await isar.writeTxn(() async {
        await isar.classModels.put(newClass);
      });

      if (!mounted) return;

      // ==========================================================
      // مهم:
      // بعد از ذخیره موفق، صفحه انتخاب شاگرد باز می‌شود
      // ==========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentSelectionScreen(classModel: newClass),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('خطا در ذخیره صنف: $e');
    }
  }

  // ============================================================
  // Message
  // ============================================================

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.notoSansArabic(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: success
            ? const Color(0xFF27AE60)
            : const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ============================================================
  // Label
  // ============================================================

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.notoSansArabic(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF263238),
        ),
      ),
    );
  }

  // ============================================================
  // Text Field
  // ============================================================

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: GoogleFonts.notoSansArabic(
        fontSize: 14,
        color: const Color(0xFF263238),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintTextDirection: TextDirection.rtl,
        hintStyle: GoogleFonts.notoSansArabic(
          fontSize: 13,
          color: const Color(0xFF9AA7B2),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE1E8EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE1E8EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
      ),
    );
  }

  // ============================================================
  // Member Input
  // ============================================================

  Widget _memberInput() {
    return Row(
      children: [
        Expanded(
          child: _textField(
            controller: memberController,
            hintText: 'نام عضو را وارد کنید',
            icon: Icons.person_add_alt_1_rounded,
          ),
        ),

        const SizedBox(width: 10),

        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            onPressed: addMember,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Member List
  // ============================================================

  Widget _buildMembersList() {
    if (members.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EAF0)),
        ),
        child: Text(
          'هنوز عضوی اضافه نشده است',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansArabic(
            fontSize: 13,
            color: const Color(0xFF9AA7B2),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(members.length, (index) {
        final String member = members[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5EAF0)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  removeMember(index);
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE74C3C),
                ),
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Text(
                  member,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF263238),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF6C63FF),
                  size: 21,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F7FC),

        // ========================================================
        // AppBar
        // ========================================================
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF3F7FC),
          centerTitle: true,
          title: Text(
            'مشخصات صنف',
            style: GoogleFonts.notoSansArabic(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF263238),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF263238),
              size: 20,
            ),
          ),
        ),

        // ========================================================
        // Body
        // ========================================================
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // Class Name
                // ==================================================

                _label('نام صنف'),

                const SizedBox(height: 8),

                _textField(
                  controller: classNameController,
                  hintText: 'مثال: علوم کامپیوتر',
                  icon: Icons.class_rounded,
                ),

                const SizedBox(height: 17),

                // ==================================================
                // Teacher Name
                // ==================================================
                _label('نام استاد'),

                const SizedBox(height: 8),

                _textField(
                  controller: teacherController,
                  hintText: 'نام استاد را وارد کنید',
                  icon: Icons.person_rounded,
                ),

                const SizedBox(height: 17),

                // ==================================================
                // Class Time
                // ==================================================
                _label('تایم درسی'),

                const SizedBox(height: 8),

                _textField(
                  controller: classTimeController,
                  hintText: 'مثلاً 1 - 2 یا 1 تا 3',
                  icon: Icons.access_time_rounded,
                ),

                const SizedBox(height: 22),

                // ==================================================
                // Members
                // ==================================================
                _label('اعضای صنف'),

                const SizedBox(height: 8),

                _memberInput(),

                const SizedBox(height: 12),

                _buildMembersList(),

                const SizedBox(height: 28),

                // ==================================================
                // Save Button
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: saveClass,
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    label: Text(
                      'ذخیره صنف',
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
