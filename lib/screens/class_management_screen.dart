import 'package:flutter/material.dart';
import '../styles/class_form_style.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() =>
      _ClassManagementScreenState();
}

class _ClassManagementScreenState
    extends State<ClassManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'مشخصات صنف',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          // نام صنف
          ClassFormStyle.label('نام صنف'),

          ClassFormStyle.textField(
            screenHeight: screenHeight,
            hintText: 'مثال : کمپیوتر سانس',
          ),

          // تعداد اعضا
          ClassFormStyle.label('تعداد اعضا'),

          ClassFormStyle.textField(
            screenHeight: screenHeight,
          ),

          // اعضای صنف
          ClassFormStyle.label('اعضای صنف'),

          ClassFormStyle.textField(
            screenHeight: screenHeight,
            hintText: 'جستجو و افزودن عضو',
          ),
        ],
      ),
    );
  }
}