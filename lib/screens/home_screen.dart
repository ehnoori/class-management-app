import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      //backgroundColor: const Color(0xFFE8E8E8),
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F6FF),
        elevation: 0,
        title: const Text(''),

        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),

        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.person))],
      ),

      body: Column(
        children: [
          Image.asset(
            'assets/images/photo_1.jpg',
            width: screenWidth,
            height: screenHeight * 0.44,
            fit: BoxFit.cover,
          ),

          SizedBox(height: 10),
          Text(
            'مدیریت صنوف',
            style: GoogleFonts.notoSansArabic(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              'ایجاد صنف جدید یا مشاهده صنوف موجود را انتخاب کنید ',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansArabic(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Container(
            width: screenWidth * 0.7,
            height: screenWidth * 0.8 * (3 / 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.blue,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 28),

                const SizedBox(width: 10),

                Text(
                  'صنف جدید',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 15),
     Container(
  width: screenWidth * 0.9,
  height: screenWidth * 0.8 * (3 / 10),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: Colors.black,
      width: 0.5,
    ),
  ),
  child: Row(
    children: [
      // آیکون سمت چپ
      const Padding(
        padding: EdgeInsets.only(left: 20),
        child: Icon(
          Icons.article,
          color: Color.fromARGB(255, 106, 60, 163),
          size: 40,
        ),
      ),

      // متن‌ها
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'صنف جدید',
                textAlign: TextAlign.right,
                style: GoogleFonts.notoSansArabic(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'مشاهده و مدیریت صنوف ثبت شده',
                maxLines: 1,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.right,
                style: GoogleFonts.notoSansArabic(
                  fontSize: 10,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
  currentIndex: 0,
  selectedItemColor: const Color.fromARGB(255, 106, 60, 163),
  unselectedItemColor: Colors.grey,
  type: BottomNavigationBarType.fixed,

  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'خانه',
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.output_outlined),
      activeIcon: Icon(Icons.output),
      label: 'خروجی',
    ),
  ],
),
    );
  }
}
