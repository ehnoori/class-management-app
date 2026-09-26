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
  // ==================================================
  // Controllers
  // ==================================================

  final TextEditingController classNameController = TextEditingController();

  final TextEditingController teacherController = TextEditingController();

  final TextEditingController classTypeController = TextEditingController();

  final TextEditingController memberController = TextEditingController();

  // ==================================================
  // Members
  // ==================================================

  final List<String> members = [];

  bool isSaving = false;

  // ==================================================
  // Dispose
  // ==================================================

  @override
  void dispose() {
    classNameController.dispose();
    teacherController.dispose();
    classTypeController.dispose();
    memberController.dispose();

    super.dispose();
  }

  // ==================================================
  // Add Member
  // ==================================================

  void addMember() {
    final String name = memberController.text.trim();

    if (name.isEmpty) {
      _showMessage('لطفاً نام عضو را وارد کنید');
      return;
    }

    final bool alreadyExists = members.any(
      (member) => member.trim().toLowerCase() == name.toLowerCase(),
    );

    if (alreadyExists) {
      _showMessage('این عضو قبلاً اضافه شده است');
      return;
    }

    setState(() {
      members.add(name);
      memberController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  // ==================================================
  // Remove Member
  // ==================================================

  void removeMember(int index) {
    if (index < 0 || index >= members.length) {
      return;
    }

    setState(() {
      members.removeAt(index);
    });
  }

  // ==================================================
  // Save Class
  // ==================================================

  Future<void> saveClass() async {
    if (isSaving) {
      return;
    }

    final String className = classNameController.text.trim();

    final String teacherName = teacherController.text.trim();

    final String classType = classTypeController.text.trim();

    // --------------------------------------------------
    // Validation
    // --------------------------------------------------

    if (className.isEmpty) {
      _showMessage('لطفاً نام صنف را وارد کنید');
      return;
    }

    if (teacherName.isEmpty) {
      _showMessage('لطفاً نام استاد را وارد کنید');
      return;
    }

    if (classType.isEmpty) {
      _showMessage('لطفاً نوع صنف را وارد کنید');
      return;
    }

    if (members.isEmpty) {
      _showMessage('لطفاً حداقل یک عضو برای صنف اضافه کنید');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // --------------------------------------------------
      // Get Isar
      // --------------------------------------------------

      final isar = await IsarService.getInstance();

      // --------------------------------------------------
      // Create Class
      // --------------------------------------------------

      final ClassModel newClass = ClassModel()
        ..className = className
        ..teacherName = teacherName
        ..classType = classType
        ..members = List<String>.from(members);

      // --------------------------------------------------
      // Save Class To Isar
      // --------------------------------------------------

      await isar.writeTxn(() async {
        await isar.classModels.put(newClass);
      });

      // --------------------------------------------------
      // Check Widget
      // --------------------------------------------------

      if (!mounted) {
        return;
      }

      // --------------------------------------------------
      // Go To Student Selection Screen
      // --------------------------------------------------

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentSelectionScreen(classModel: newClass),
        ),
      );
    } catch (e) {
      // --------------------------------------------------
      // Error
      // --------------------------------------------------

      if (!mounted) {
        return;
      }

      _showMessage('خطا در ذخیره اطلاعات:\n$e');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ==================================================
  // Show Message
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
          'مشخصات صنف',
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.055,
            8,
            screenWidth * 0.055,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // Header
              // ==================================================

              _buildHeaderCard(),

              const SizedBox(height: 22),

              // ==================================================
              // Class Information
              // ==================================================
              _sectionTitle(icon: Icons.school_rounded, title: 'اطلاعات صنف'),

              const SizedBox(height: 14),

              _buildInfoCard(
                children: [
                  _label('نام صنف'),

                  const SizedBox(height: 8),

                  _textField(
                    controller: classNameController,
                    hintText: 'مثال: علوم کامپیوتر',
                    icon: Icons.class_rounded,
                  ),

                  const SizedBox(height: 17),

                  _label('نام استاد'),

                  const SizedBox(height: 8),

                  _textField(
                    controller: teacherController,
                    hintText: 'نام استاد را وارد کنید',
                    icon: Icons.person_rounded,
                  ),

                  const SizedBox(height: 17),

                  _label(' تام درسی'),

                  const SizedBox(height: 8),

                  _textField(
                    controller: classTypeController,
                    hintText:'ساعت را وادر کنید',
                    icon: Icons.class_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==================================================
              // Members
              // ==================================================
              _sectionTitle(icon: Icons.groups_rounded, title: 'اعضای صنف'),

              const SizedBox(height: 14),

              _buildMemberInputCard(),

              const SizedBox(height: 16),

              // ==================================================
              // Members Count
              // ==================================================
              if (members.isNotEmpty)
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'اعضای اضافه‌شده',
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF172B5B),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4EEFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${members.length} نفر',
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.notoSansArabic(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1565E8),
                        ),
                      ),
                    ),
                  ],
                ),

              if (members.isNotEmpty) const SizedBox(height: 10),

              // ==================================================
              // Members List
              // ==================================================
              if (members.isNotEmpty) _buildMembersList(),

              // ==================================================
              // Empty State
              // ==================================================
              if (members.isEmpty) _buildEmptyMembers(),

              const SizedBox(height: 28),

              // ==================================================
              // Save Button
              // ==================================================
              _buildSaveButton(),

              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================
  // Header Card
  // ==================================================

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3478F6), Color(0xFF1565E8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565E8).withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ایجاد صنف جدید',
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'معلومات صنف و اعضای آن را وارد کنید',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.88),
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
  // Information Card
  // ==================================================

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4EAF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  // ==================================================
  // Member Input Card
  // ==================================================

  Widget _buildMemberInputCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4EAF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('افزودن عضو'),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _textField(
                  controller: memberController,
                  hintText: 'نام عضو را وارد کنید',
                  icon: Icons.person_add_alt_1_rounded,
                  onSubmitted: (_) {
                    addMember();
                  },
                ),
              ),

              const SizedBox(width: 9),

              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1565E8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565E8).withOpacity(0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: addMember,
                  icon: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================================================
  // Members List
  // ==================================================

  Widget _buildMembersList() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4EAF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: List.generate(members.length, (index) {
          return _memberItem(name: members[index], index: index);
        }),
      ),
    );
  }

  // ==================================================
  // Empty Members
  // ==================================================

  Widget _buildEmptyMembers() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4EAF3)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.group_add_rounded,
              size: 31,
              color: Color(0xFF3478F6),
            ),
          ),

          const SizedBox(height: 13),

          Text(
            'هنوز عضوی اضافه نشده است',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansArabic(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF344054),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'نام عضو را در قسمت بالا وارد و اضافه کنید',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansArabic(
              fontSize: 12,
              color: const Color(0xFF8A98AD),
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // Save Button
  // ==================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : saveClass,

        icon: isSaving
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 23,
              ),

        label: Text(
          isSaving ? 'در حال ذخیره...' : 'ذخیره مشخصات صنف',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.notoSansArabic(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565E8),
          disabledBackgroundColor: const Color(0xFF8DB5F5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // ==================================================
  // Section Title
  // ==================================================

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE2EDFF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: const Color(0xFF1565E8), size: 23),
        ),

        const SizedBox(width: 11),

        Text(
          title,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.notoSansArabic(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF172B5B),
          ),
        ),
      ],
    );
  }

  // ==================================================
  // Label
  // ==================================================

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: RichText(
        textDirection: TextDirection.rtl,
        text: TextSpan(
          text: text,
          style: GoogleFonts.notoSansArabic(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF344054),
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // TextField
  // ==================================================

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      onSubmitted: onSubmitted,

      style: GoogleFonts.notoSansArabic(
        fontSize: 14,
        color: const Color(0xFF172B5B),
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(
        hintText: hintText,
        hintTextDirection: TextDirection.rtl,

        hintStyle: GoogleFonts.notoSansArabic(
          fontSize: 12.5,
          color: const Color(0xFF9AA8BC),
        ),

        prefixIcon: Icon(icon, color: const Color(0xFF7C8DA8), size: 21),

        filled: true,
        fillColor: const Color(0xFFF8FAFD),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E8F2)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF3478F6), width: 1.5),
        ),
      ),
    );
  }

  // ==================================================
  // Member Item
  // ==================================================

  Widget _memberItem({required String name, required int index}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEDF1F7)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFE1EDFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF3478F6),
              size: 22,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              name,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.notoSansArabic(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF27364D),
              ),
            ),
          ),

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(11),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'حذف عضو',
              onPressed: () {
                removeMember(index);
              },
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFE05252),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
