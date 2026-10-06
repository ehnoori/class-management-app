import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelFilesScreen extends StatefulWidget {
  const ExcelFilesScreen({super.key});

  @override
  State<ExcelFilesScreen> createState() => _ExcelFilesScreenState();
}

class _ExcelFilesScreenState extends State<ExcelFilesScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFFF4F7FC);
  static const Color primaryTextColor = Color(0xFF172B5B);
  static const Color secondaryTextColor = Color(0xFF68758A);
  static const Color primaryBlue = Color(0xFF1565E8);
  static const Color excelGreen = Color(0xFF2E9B57);

  // ============================================================
  // STATE
  // ============================================================

  List<File> excelFiles = [];
  bool isLoading = true;

  // ============================================================
  // FONT - VAZIRMATN
  // ============================================================

  TextStyle _font({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = primaryTextColor,
    double? height,
  }) {
    return GoogleFonts.vazirmatn(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

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
            (file) => file.path.toLowerCase().endsWith('.xlsx'),
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
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        excelFiles = [];
        isLoading = false;
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
            style: _font(
              color: Colors.white,
            ),
          ),
        ),
      );

      await _loadExcelFiles();
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
              style: _font(
                color: Colors.white,
              ),
            ),
          ),
        );

        await _loadExcelFiles();
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
          backgroundColor: Colors.red,
          content: Text(
            'اشتراک‌گذاری فایل انجام نشد.',
            textDirection: TextDirection.rtl,
            style: _font(
              color: Colors.white,
            ),
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
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'حذف فایل',
              textAlign: TextAlign.right,
              style: _font(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: Text(
              'آیا مطمئن هستید که فایل «$className» حذف شود؟',
              textAlign: TextAlign.right,
              style: _font(
                fontSize: 14,
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
                  style: _font(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: secondaryTextColor,
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
                  style: _font(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
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
          backgroundColor: Colors.green,
          content: Text(
            'فایل با موفقیت حذف شد.',
            textDirection: TextDirection.rtl,
            style: _font(
              color: Colors.white,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'حذف فایل انجام نشد.',
            textDirection: TextDirection.rtl,
            style: _font(
              color: Colors.white,
            ),
          ),
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
                  Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Text(
                    _getClassName(file),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _font(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // SHARE
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
                      style: _font(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'ارسال فایل Excel',
                      textAlign: TextAlign.right,
                      style: _font(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),

                  // DELETE
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
                      style: _font(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      'حذف دائمی فایل Excel',
                      textAlign: TextAlign.right,
                      style: _font(
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
  // GET CLASS NAME
  // ============================================================

  String _getClassName(File file) {
    String name = file.path.split('/').last;

    name = name.replaceFirst(
      RegExp(r'\.xlsx$'),
      '',
    );

    name = name.replaceFirst(
      'نتایج_',
      '',
    );

    name = name.replaceFirst(
      RegExp(r'\_(\d{10,})$'),
      '',
    );

    return name;
  }

  // ============================================================
  // FORMAT DATE
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
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: primaryTextColor,
            ),
          ),
          title: Text(
            'فایل‌های Excel',
            style: _font(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // ======================================================
        // BODY
        // ======================================================

        body: RefreshIndicator(
          onRefresh: _loadExcelFiles,
          child: _buildBody(),
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (excelFiles.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _buildEmptyExcelCard(),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        30,
      ),
      children: [
        // ======================================================
        // HEADER
        // ======================================================

        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'تمام فایل‌های Excel',
                    textAlign: TextAlign.right,
                    style: _font(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${excelFiles.length} فایل خروجی',
                    textAlign: TextAlign.right,
                    style: _font(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.table_chart_rounded,
              color: excelGreen,
              size: 25,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ======================================================
        // ALL FILES
        // ======================================================

        ...excelFiles.map(
          (file) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildExcelFileCard(file),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EXCEL FILE CARD
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
              color: excelGreen.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // ==================================================
              // THREE DOTS
              // ==================================================

              SizedBox(
                width: 42,
                height: 48,
                child: IconButton(
                  tooltip: 'گزینه‌ها',
                  onPressed: () {
                    _showFileMenu(file);
                  },
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: secondaryTextColor,
                    size: 25,
                  ),
                ),
              ),

              // ==================================================
              // OPEN FILE
              // ==================================================

              SizedBox(
                width: 42,
                height: 48,
                child: IconButton(
                  tooltip: 'باز کردن فایل',
                  onPressed: () {
                    _openExcelFile(file);
                  },
                  icon: const Icon(
                    Icons.open_in_new_rounded,
                    color: secondaryTextColor,
                    size: 23,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ==================================================
              // FILE NAME + DATE
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      file.path
                          .split('/')
                          .last
                          .replaceFirst(
                            RegExp(r'\.xlsx$'),
                            '',
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _font(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatFileDate(file),
                      textAlign: TextAlign.center,
                      style: _font(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ==================================================
              // EXCEL ICON
              // ==================================================

              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: excelGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: excelGreen,
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
        vertical: 35,
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
          // ======================================================
          // ICON
          // ======================================================

          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: excelGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              color: excelGreen,
              size: 30,
            ),
          ),

          const SizedBox(height: 15),

          // ======================================================
          // TITLE
          // ======================================================

          Text(
            'هنوز فایل Excel ایجاد نشده است',
            textAlign: TextAlign.center,
            style: _font(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 6),

          // ======================================================
          // DESCRIPTION
          // ======================================================

          Text(
            'بعد از ارزیابی شاگردان، فایل‌های خروجی اینجا نمایش داده می‌شوند.',
            textAlign: TextAlign.center,
            style: _font(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: secondaryTextColor,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}