import 'package:flutter/material.dart';
import '../services/app_config.dart';
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
  int _currentIndex = 1;

  final List<Widget> _screens = [
    const SettingsScreen(),
    const HomeScreen(),
    const InsightsScreen(),
  ];

  final List<String> _screenTitles = [
    AppConfig.settingsTitle,
    AppConfig.appTitle,
    'Insights',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
      ),
    );
  }
}
