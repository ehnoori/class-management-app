
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'class_list_screen.dart';
import 'class_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFFF4F7FC);
  static const Color primaryTextColor = Color(0xFF172B5B);
  static const Color secondaryTextColor = Color(0xFF68758A);
  static const Color primaryBlue = Color(0xFF1565E8);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color purple = Color(0xFF6A3CA3);

  // ============================================================
  // STATE
  // ============================================================

  List<File> excelFiles = [];
  bool isLoadingExcel = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadExcelFiles();
  }

  // ============================================================
  // LOAD EXCEL FILES
  // ============================================================

  Future<void> _loadExcelFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final files = directory
          .listSync()
          .whereType<File>()
          .where(
            (file) =>
                file.path.toLowerCase().endsWith('.xlsx') &&
                file.path.contains('نتایج_'),
          )
          .toList();

      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(
              a.lastModifiedSync(),
            ),
      );

      if (!mounted) return;

      setState(() {
        excelFiles = files;
        isLoadingExcel = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        excelFiles = [];
        isLoadingExcel = false;
      });
    }
  }

  // ============================================================
  // OPEN EXCEL FILE
  // ============================================================

  Future<void> _openExcelFile(File file) async {
    if (!await file.exists()) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فایل پیدا نشد.',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoSansArabic(),
          ),
        ),
      );

      _loadExcelFiles();
      return;
    }

    await OpenFilex.open(file.path);
  }

  // ============================================================
  // SHARE EXCEL FILE
  // ============================================================

  Future<void> _shareExcelFile(File file) async {
    try {
      if (!await file.exists()) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فایل پیدا نشد.',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.notoSansArabic(),
            ),
          ),
        );

        _loadExcelFiles();
        return;
      }

      final className = _getClassName(file);

      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        subject: 'نتایج $className',
        text: 'فایل نتایج صنف $className',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'اشتراک‌گذاری فایل انجام نشد.',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoSansArabic(),
          ),
        ),
      );
    }
  }

  // ============================================================
  // DELETE EXCEL FILE
  // ============================================================

  Future<void> _deleteExcelFile(File file) async {
    final className = _getClassName(file);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'حذف فایل',
              textAlign: TextAlign.right,
              style: GoogleFonts.notoSansArabic(
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            content: Text(
              'آیا مطمئن هستید که فایل «$className» حذف شود؟',
              textAlign: TextAlign.right,
              style: GoogleFonts.notoSansArabic(
                color: secondaryTextColor,
                height: 1.7,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: Text(
                  'انصراف',
                  style: GoogleFonts.notoSansArabic(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'حذف',
                  style: GoogleFonts.notoSansArabic(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      if (await file.exists()) {
        await file.delete();
      }

      if (!mounted) return;

      setState(() {
        excelFiles.removeWhere(
          (item) => item.path == file.path,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فایل با موفقیت حذف شد.',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoSansArabic(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حذف فایل انجام نشد.',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoSansArabic(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // FILE MENU
  // ============================================================

  Future<void> _showFileMenu(File file) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              25,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ==================================================
                  // HANDLE
                  // ==================================================

                  Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // ==================================================
                  // FILE NAME
                  // ==================================================

                  Text(
                    _getClassName(file),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // SHARE
                  // ==================================================

                  ListTile(
                    onTap: () async {
                      Navigator.pop(sheetContext);

                      await _shareExcelFile(file);
                    },
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.share_rounded,
                        color: primaryBlue,
                      ),
                    ),
                    title: Text(
                      'اشتراک‌گذاری',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoSansArabic(
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    subtitle: Text(
                      'ارسال فایل Excel',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),

                  // ==================================================
                  // DELETE
                  // ==================================================

                  ListTile(
                    onTap: () async {
                      Navigator.pop(sheetContext);

                      await _deleteExcelFile(file);
                    },
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      'حذف فایل',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoSansArabic(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      'حذف دائمی فایل Excel',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // GET CLASS NAME FROM FILE NAME
  // ============================================================

  String _getClassName(File file) {
    String name = file.path.split('/').last;

    name = name.replaceAll('.xlsx', '');
    name = name.replaceFirst('نتایج_', '');

    name = name.replaceFirst(
      RegExp(r'_(\d{10,})$'),
      '',
    );

    return name;
  }

  // ============================================================
  // FORMAT FILE DATE
  // ============================================================

  String _formatFileDate(File file) {
    final date = file.lastModifiedSync();

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$year/$month/$day - $hour:$minute';
  }

  // ============================================================
  // OPEN CLASS MANAGEMENT
  // ============================================================

  Future<void> openClassManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ClassManagementScreen(),
      ),
    );

    _loadExcelFiles();
  }

  // ============================================================
  // OPEN CLASS LIST
  // ============================================================

  Future<void> openClassList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ClassListScreen(),
      ),
    );

    _loadExcelFiles();
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

        // ======================================================
        // APP BAR
        // ======================================================

        appBar: AppBar(
          elevation: 0,
          backgroundColor: backgroundColor,
          centerTitle: true,
          title: Text(
            'مدیریت صنف‌ها',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoSansArabic(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
        ),

        // ======================================================
        // BODY
        // ======================================================

        body: RefreshIndicator(
          onRefresh: _loadExcelFiles,
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
                _buildHero(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  title: 'دسترسی سریع',
                  icon: Icons.apps_rounded,
                ),

                const SizedBox(height: 14),

                _buildCreateClassButton(),

                const SizedBox(height: 14),

                _buildClassListCard(),

                const SizedBox(height: 28),

                _buildExcelSection(),

                const SizedBox(height: 14),

                _buildExcelFiles(),
              ],
            ),
          ),
        ),

        // ======================================================
        // BOTTOM NAVIGATION
        // ======================================================

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryBlue,
          unselectedItemColor: secondaryTextColor,
          backgroundColor: Colors.white,
          elevation: 10,
          selectedLabelStyle: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.notoSansArabic(),
          onTap: (index) {
            if (index == 1) {
              openClassList();
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'خانه',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment_rounded),
              label: 'نتایج',
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            primaryBlue,
            lightBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // ==================================================
          // TEXT
          // ==================================================

          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'مدیریت صنف‌ها',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.notoSansArabic(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'صنف‌ها، شاگردان و ارزیابی‌های خود را به آسانی مدیریت کنید.',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.notoSansArabic(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ==================================================
          // ICON
          // ==================================================

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
  }) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoSansArabic(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Icon(
          icon,
          color: primaryBlue,
          size: 24,
        ),
      ],
    );
  }

  // ============================================================
  // CREATE CLASS BUTTON
  // ============================================================

  Widget _buildCreateClassButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openClassManagement,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: primaryBlue.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ایجاد صنف جدید',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.notoSansArabic(
                          color: primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'ثبت صنف و افزودن شاگردان',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.notoSansArabic(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: primaryBlue,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CLASS LIST CARD
  // ============================================================

  Widget _buildClassListCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openClassList,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: purple.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'لیست صنوف',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.notoSansArabic(
                          color: primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'مشاهده و مدیریت تمام صنف‌ها',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.notoSansArabic(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: purple.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: purple,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EXCEL SECTION
  // ============================================================

  Widget _buildExcelSection() {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'صنف‌های تبدیل‌شده به Excel',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${excelFiles.length} فایل خروجی ایجاد شده',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        const Icon(
          Icons.table_chart_rounded,
          color: Colors.green,
          size: 24,
        ),
      ],
    );
  }

  // ============================================================
  // EXCEL FILES
  // ============================================================

  Widget _buildExcelFiles() {
    if (isLoadingExcel) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (excelFiles.isEmpty) {
      return _buildEmptyExcelCard();
    }

    return Column(
      children: excelFiles.map(
        (file) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildExcelFileCard(file),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // EXCEL FILE CARD
  //
  // راست  = سه نقطه
  // وسط   = نام صنف + تاریخ
  // چپ    = آیکون Excel
  // ============================================================

  Widget _buildExcelFileCard(File file) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openExcelFile(file),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.green.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          // ======================================================
          // RTL ROW
          //
          // ترتیب در RTL:
          // [ سه نقطه ] [ متن وسط ] [ Excel ]
          // ======================================================

          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // ==================================================
              // RIGHT: THREE DOTS
              // ==================================================

              SizedBox(
                width: 42,
                height: 48,
                child: IconButton(
                  tooltip: 'گزینه‌ها',
                  onPressed: () => _showFileMenu(file),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: secondaryTextColor,
                    size: 25,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ==================================================
              // CENTER: CLASS NAME + DATE
              // ==================================================

              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _getClassName(file),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansArabic(
                          color: primaryTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: secondaryTextColor,
                            size: 13,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            _formatFileDate(file),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.ltr,
                            style: GoogleFonts.notoSansArabic(
                              color: secondaryTextColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ==================================================
              // LEFT: EXCEL ICON
              // ==================================================

              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Colors.green,
                  size: 27,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY EXCEL CARD
  // ============================================================

  Widget _buildEmptyExcelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              color: Colors.green,
              size: 28,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'هنوز فایل Excel ایجاد نشده است',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoSansArabic(
              color: primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'بعد از ارزیابی شاگردان، فایل‌های خروجی اینجا نمایش داده می‌شوند.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoSansArabic(
              color: secondaryTextColor,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}