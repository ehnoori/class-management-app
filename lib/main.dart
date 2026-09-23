import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final bool hasSeenOnboarding =
      prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(
    MyApp(
      hasSeenOnboarding: hasSeenOnboarding,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Class Evaluation App',
      home: hasSeenOnboarding
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}