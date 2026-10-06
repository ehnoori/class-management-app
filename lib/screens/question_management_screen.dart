
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionManagementScreen extends StatefulWidget {
  const QuestionManagementScreen({super.key});

  @override
  State<QuestionManagementScreen> createState() =>
      _QuestionManagementScreenState();
}

class _QuestionManagementScreenState
    extends State<QuestionManagementScreen> {
  static const Color backgroundColor = Color(0xFFF4F7FC);
  static const Color primaryTextColor = Color(0xFF172B5B);
  static const Color secondaryTextColor = Color(0xFF68758A);

  static const Color primaryBlue = Color(0xFF1565E8);
  static const Color lightBlue = Color(0xFFEAF2FF);

  String? selectedPdfName;

  Future<void> _pickPdf() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isEmpty) {
        return;
      }

      final file = files.first;

      setState(() {
        selectedPdfName = file.name;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            'فایل PDF با موفقیت انتخاب شد.',
            style: GoogleFonts.vazirmatn(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'در انتخاب فایل مشکلی به وجود آمد.',
            style: GoogleFonts.vazirmatn(
              fontSize: 13,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _deletePdf() async {
    if (selectedPdfName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'هیچ فایل PDF انتخاب نشده است.',
            style: GoogleFonts.vazirmatn(
              fontSize: 13,
            ),
          ),
        ),
      );
      return;
    }

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
              'حذف فایل PDF',
              style: GoogleFonts.vazirmatn(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
              ),
            ),
            content: Text(
              'آیا مطمئن هستید که می‌خواهید فایل «$selectedPdfName» را حذف کنید؟',
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
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
                  'لغو',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: Text(
                  'حذف',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      selectedPdfName = null;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          'فایل PDF حذف شد.',
          style: GoogleFonts.vazirmatn(
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // وارد کردن PDF
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _pickPdf();
                    },
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: primaryBlue,
                      ),
                    ),
                    title: Text(
                      'وارد کردن سوالات از PDF',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    subtitle: Text(
                      'انتخاب فایل PDF',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),

                  const Divider(height: 10),

                  // حذف PDF
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _deletePdf();
                    },
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      'حذف فایل PDF',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      selectedPdfName == null
                          ? 'فایلی انتخاب نشده است'
                          : 'حذف فایل انتخاب‌شده',
                      style: GoogleFonts.vazirmatn(
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: backgroundColor,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'برگشت',
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: primaryTextColor,
              size: 22,
            ),
          ),
          title: Text(
            'وارد کردن سوالات',
            style: GoogleFonts.vazirmatn(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _showOptions,
              tooltip: 'گزینه‌ها',
              icon: const Icon(
                Icons.more_vert_rounded,
                color: secondaryTextColor,
                size: 26,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
            child: Column(
              children: [
                const Spacer(),

                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 55,
                    color: primaryBlue,
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  'وارد کردن سوالات از PDF',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'فایل PDF سوالات خود را انتخاب کنید تا سوالات وارد برنامه شوند.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    color: secondaryTextColor,
                    height: 1.8,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _pickPdf,
                    icon: const Icon(
                      Icons.upload_file_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      'انتخاب فایل PDF',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                if (selectedPdfName != null) ...[
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: primaryBlue,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            selectedPdfName!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
