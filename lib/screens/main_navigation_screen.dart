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
      body: Column(
        children: [
          // Custom App Bar with page indicator
          Container(
            height: 60 + MediaQuery.of(context).padding.top,
            padding: EdgeInsets.only(
              left: AppConfig.standardPadding,
              right: AppConfig.standardPadding,
              top: MediaQuery.of(context).padding.top,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Page indicators
                Row(
                  children: List.generate(_screens.length, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: AppConfig.smallPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _screenTitles[index],
                            style: TextStyle(
                              color: _currentIndex == index ? Colors.white : Colors.grey,
                              fontSize: _currentIndex == index ? 16 : 14,
                              fontWeight: _currentIndex == index ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          SizedBox(height: AppConfig.smallPadding),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == index ? Colors.white : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // Page view
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _screens.map((screen) => Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                child: screen,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
