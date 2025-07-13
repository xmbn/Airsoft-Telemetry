import 'package:flutter/material.dart';
import 'package:airsoft_telemetry_flutter/screens/home_screen.dart';
import 'package:airsoft_telemetry_flutter/screens/settings_screen.dart';
import 'package:airsoft_telemetry_flutter/screens/insights_screen.dart';
import 'package:airsoft_telemetry_flutter/services/app_config.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final PageController _pageController =
      PageController(initialPage: 1); // Start on home screen

  final List<Widget> _screens = [
    const SettingsScreen(),
    const HomeScreen(),
    const InsightsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: _screens,
        ),
      ),
    );
  }
}
