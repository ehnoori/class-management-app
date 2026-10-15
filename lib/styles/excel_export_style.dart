
import 'package:excel/excel.dart';

class ExcelExportStyle {
  ExcelExportStyle._();

  // رنگ‌ها
  static final ExcelColor turquoise =
      ExcelColor.fromHexString('FF36B7C2');

  static final ExcelColor lightBlue =
      ExcelColor.fromHexString('FFDDF3F5');

  static final ExcelColor lightValue =
      ExcelColor.fromHexString('FFF0FAFB');

  static final ExcelColor white =
      ExcelColor.fromHexString('FFFFFFFF');

  static final ExcelColor textColor =
      ExcelColor.fromHexString('FF17343A');

  // حاشیه خانه‌ها
  static Border get border =>
      Border(borderStyle: BorderStyle.Thin);

  // عنوان اصلی فایل اکسل
  static CellStyle get title => CellStyle(
        backgroundColorHex: turquoise,
        fontColorHex: white,
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

  // عنوان ستون‌ها:
  // شماره، نام شاگرد، سوال اول، سوال دوم و غیره
  static CellStyle get sectionHeader => CellStyle(
        backgroundColorHex: turquoise,
        fontColorHex: white,
        bold: true,
        fontSize: 11,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: border,
        rightBorder: border,
        topBorder: border,
        bottomBorder: border,
      );

  // عنوان فیلدهای اطلاعات صنف
  static CellStyle get label => CellStyle(
        backgroundColorHex: lightBlue,
        fontColorHex: textColor,
        bold: true,
        fontSize: 11,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: border,
        rightBorder: border,
        topBorder: border,
        bottomBorder: border,
      );

  // مقدارهای اطلاعات صنف
  static CellStyle get value => CellStyle(
        backgroundColorHex: lightValue,
        fontColorHex: textColor,
        fontSize: 11,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: border,
        rightBorder: border,
        topBorder: border,
        bottomBorder: border,
      );

  // استایل سوال‌ها در صورت نیاز به استفاده جداگانه
  static CellStyle get question => CellStyle(
        backgroundColorHex: lightValue,
        fontColorHex: textColor,
        bold: true,
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: border,
        rightBorder: border,
        topBorder: border,
        bottomBorder: border,
      );

  // جواب‌های شاگردان:
  // بدون رنگ پس‌زمینه رنگی؛ متن وسط‌چین
  static CellStyle get data => CellStyle(
        fontColorHex: textColor,
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: border,
        rightBorder: border,
        topBorder: border,
        bottomBorder: border,
      );

  // عرض ستون‌ها
  static const double numberWidth = 12;
  static const double studentNameWidth = 25;
  static const double questionWidth = 16;
}
