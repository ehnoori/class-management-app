
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../database/isar_service.dart';
import '../models/class_model.dart';
import 'student_selection_screen.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() =>
      _ClassManagementScreenState();
}

class _ClassManagementScreenState
    extends State<ClassManagementScreen> {
  // Controllers
  final TextEditingController classNameController =
      TextEditingController();

  final TextEditingController teacherController =
      TextEditingController();

  final TextEditingController classTimeController =
      TextEditingController();

  final TextEditingController memberController =
      TextEditingController();

  // Members
  final List<String> members = [];

  bool isSaving = false;

  @override
  void dispose() {
    classNameController.dispose();
    teacherController.dispose();
    classTimeController.dispose();
    memberController.dispose();
    super.dispose();
  }

  // یکسان‌سازی نام برای تشخیص نام‌های تکراری
  String _normalizeName(String name) {
    return name
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
  }

  // افزودن عضو
  void addMember() {
    final String memberName = memberController.text
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');

    if (memberName.isEmpty) {
      _showMessage('لطفاً نام عضو را وارد کنید');
      return;
    }

    final normalizedName = _normalizeName(memberName);

    final alreadyExists = members.any(
      (member) => _normalizeName(member) == normalizedName,
    );

    if (alreadyExists) {
      _showMessage('این شاگرد قبلاً به صنف اضافه شده است');
      return;
    }

    setState(() {
      members.add(memberName);
      memberController.clear();
    });
  }

  // حذف عضو
  void removeMember(int index) {
    setState(() {
      members.removeAt(index);
    });
  }

  // ذخیره صنف
  Future<void> saveClass() async {
    if (isSaving) return;

    final String className = classNameController.text.trim();
    final String teacherName = teacherController.text.trim();
    final String classTime = classTimeController.text.trim();

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

    // بررسی دوباره نام‌های تکراری
    final normalizedMembers =
        members.map(_normalizeName).toList();

    if (normalizedMembers.toSet().length !=
        normalizedMembers.length) {
      _showMessage('نام تکراری در فهرست شاگردان وجود دارد');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final ClassModel newClass = ClassModel()
        ..className = className
        ..teacherName = teacherName
        ..classTime = classTime
        ..members = List<String>.from(members);

      final isar = await IsarService.getInstance();

      await isar.writeTxn(() async {
        await isar.classModels.put(newClass);
      });

      // اطمینان از ذخیره شدن صنف
      final savedClass =
          await isar.classModels.get(newClass.id);

      if (savedClass == null) {
        throw Exception('صنف در دیتابیس ذخیره نشد');
      }

      if (!mounted) return;

      // انتقال همان صنف ذخیره‌شده به صفحه انتخاب شاگرد
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentSelectionScreen(
            classModel: savedClass,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Save Class Error: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      _showMessage('خطا در ذخیره صنف');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // نمایش پیام
  void _showMessage(
    String message, {
    bool success = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: success
              ? const Color(0xFF27AE60)
              : const Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // عنوان فیلد
  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.vazirmatn(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF263238),
        ),
      ),
    );
  }

  // فیلد متنی
  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: GoogleFonts.vazirmatn(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF263238),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintTextDirection: TextDirection.rtl,
        hintStyle: GoogleFonts.vazirmatn(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9AA7B2),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF6C63FF),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE1E8EF),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE1E8EF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF6C63FF),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ورودی افزودن عضو
  Widget _memberInput() {
    return Row(
      children: [
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            onPressed: addMember,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _textField(
            controller: memberController,
            hintText: 'نام عضو را وارد کنید',
            icon: Icons.person_add_alt_1_rounded,
          ),
        ),
      ],
    );
  }

  // فهرست اعضا
  Widget _buildMembersList() {
    if (members.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE5EAF0),
          ),
        ),
        child: Text(
          'هنوز عضوی اضافه نشده است',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: GoogleFonts.vazirmatn(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9AA7B2),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        members.length,
        (index) {
          final String member = members[index];

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5EAF0),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
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
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    member,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF263238),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'حذف عضو',
                  onPressed: () => removeMember(index),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE74C3C),
                    size: 23,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth =
        MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F7FC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF3F7FC),
          centerTitle: true,
          title: Text(
            'مشخصات صنف',
            style: GoogleFonts.vazirmatn(
              fontSize: 19,
              fontWeight: FontWeight.w600,
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('نام صنف :'),
                const SizedBox(height: 8),
                _textField(
                  controller: classNameController,
                  hintText: 'مثال: علوم کامپیوتر',
                  icon: Icons.class_rounded,
                ),
                const SizedBox(height: 17),

                _label('نام استاد :'),
                const SizedBox(height: 8),
                _textField(
                  controller: teacherController,
                  hintText: 'نام استاد را وارد کنید',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 17),

                _label('تایم درسی :'),
                const SizedBox(height: 8),
                _textField(
                  controller: classTimeController,
                  hintText: 'مثلاً 1 - 2 یا 1 تا 3',
                  icon: Icons.access_time_rounded,
                ),
                const SizedBox(height: 22),

                _label('   اعضای صنف : '),
                const SizedBox(height: 8),
                _memberInput(),
                const SizedBox(height: 12),
                _buildMembersList(),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveClass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      disabledBackgroundColor:
                          const Color(0xFF9E98F5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          isSaving
                              ? 'در حال ذخیره...'
                              : 'ذخیره صنف',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.save_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
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
