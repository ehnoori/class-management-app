import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassFormStyle {
  // رنگ‌های عمومی
  static const Color primaryColor = Color(0xFF1565E8);
  static const Color successColor = Color(0xFF16A34A);
  static const Color backgroundColor = Color(0xFFF3F7FC);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  // عنوان فیلد
  static Widget label(String title, {required double screenWidth}) {
    final double fontSize = (screenWidth * 0.055).clamp(18.0, 26.0);

    return Padding(
      padding: EdgeInsets.only(right: screenWidth * 0.05),
      child: Align(
        alignment: Alignment.centerRight,
        child: RichText(
          textDirection: TextDirection.rtl,
          text: TextSpan(
            children: [
              TextSpan(
                text: '* ',
                style: GoogleFonts.vazirmatn(
                  color: Colors.red,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: title,
                style: GoogleFonts.vazirmatn(
                  color: Colors.black,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // فیلد ورودی
  static Widget textField({
    required double screenWidth,
    required double screenHeight,
    String? hintText,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final double fieldHeight = (screenHeight * 0.07).clamp(48.0, 62.0);

    final double horizontalPadding = (screenWidth * 0.04).clamp(12.0, 20.0);

    final double fontSize = (screenWidth * 0.038).clamp(13.0, 17.0);

    return Padding(
      padding: EdgeInsets.all((screenWidth * 0.02).clamp(6.0, 10.0)),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: fieldHeight),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            textAlign: TextAlign.right,
            style: GoogleFonts.vazirmatn(fontSize: fontSize),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.vazirmatn(
                fontSize: fontSize,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ),
    );
  }

  // متن SnackBar
  static TextStyle snackBarTextStyle({double fontSize = 14}) {
    return GoogleFonts.vazirmatn(
      fontSize: fontSize,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    );
  }

  // کارت شاگرد
  static BoxDecoration studentCardDecoration({
    bool selected = false,
    bool evaluated = false,
  }) {
    return BoxDecoration(
      color: evaluated
          ? const Color(0xFFF0FDF4)
          : selected
          ? const Color(0xFFEFF6FF)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: evaluated
            ? const Color(0xFF86EFAC)
            : selected
            ? primaryColor
            : borderColor,
        width: selected || evaluated ? 1.4 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // پس‌زمینه شماره شاگرد
  static BoxDecoration studentNumberDecoration({
    bool selected = false,
    bool evaluated = false,
  }) {
    return BoxDecoration(
      color: evaluated
          ? const Color(0xFFDCFCE7)
          : selected
          ? const Color(0xFFDBEAFE)
          : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(12),
    );
  }

  // متن شماره شاگرد
  static TextStyle studentNumberStyle({
    bool selected = false,
    bool evaluated = false,
    double fontSize = 14,
  }) {
    return GoogleFonts.vazirmatn(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: evaluated
          ? successColor
          : selected
          ? primaryColor
          : textColor,
    );
  }

  // نام شاگرد
  static TextStyle studentNameStyle() {
    return GoogleFonts.vazirmatn(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textColor,
    );
  }

  // وضعیت ارزیابی شاگرد
  static TextStyle studentStatusStyle({bool evaluated = false}) {
    return GoogleFonts.vazirmatn(
      fontSize: 11,
      color: evaluated ? successColor : secondaryColor,
      fontWeight: evaluated ? FontWeight.w600 : FontWeight.normal,
    );
  }

  // استایل دکمه
  static ButtonStyle actionButtonStyle({required Color color}) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      disabledBackgroundColor: const Color(0xFFCBD5E1),
      disabledForegroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  // متن دکمه
  static TextStyle buttonTextStyle() {
    return GoogleFonts.vazirmatn(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  // عنوان AppBar
  static TextStyle appBarTitleStyle() {
    return GoogleFonts.vazirmatn(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: textColor,
    );
  }

  // کارت معلومات صنف
  static BoxDecoration classInfoCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // آیکون صنف
  static BoxDecoration classIconDecoration() {
    return BoxDecoration(
      color: const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(14),
    );
  }

  // نام صنف
  static TextStyle classNameStyle() {
    return GoogleFonts.vazirmatn(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: textColor,
    );
  }

  // متن فرعی
  static TextStyle secondaryTextStyle() {
    return GoogleFonts.vazirmatn(fontSize: 12, color: secondaryColor);
  }

  // پس‌زمینه شمارنده ارزیابی
  static BoxDecoration evaluationCountDecoration({bool allCompleted = false}) {
    return BoxDecoration(
      color: allCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(10),
    );
  }

  // متن شمارنده ارزیابی
  static TextStyle evaluationCountStyle({bool allCompleted = false}) {
    return GoogleFonts.vazirmatn(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: allCompleted ? successColor : primaryColor,
    );
  }

  // عنوان بخش
  static TextStyle sectionTitleStyle() {
    return GoogleFonts.vazirmatn(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: textColor,
    );
  }

  // متن عمومی
  static TextStyle textStyle({double fontSize = 14}) {
    return GoogleFonts.vazirmatn(fontSize: fontSize, color: textColor);
  }

  // پنل دکمه‌های پایین صفحه
  static BoxDecoration bottomPanelDecoration() {
    return const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: borderColor)),
    );
  }
}
