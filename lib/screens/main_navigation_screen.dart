import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'insights_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final PageController _pageController = PageController(initialPage: 1); // Start on home screen

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
      backgroundColor: Colors.black,
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
