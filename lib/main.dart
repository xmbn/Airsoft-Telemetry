import 'package:flutter/material.dart';
import 'package:airsoft_telemetry_flutter/screens/main_navigation_screen.dart';
import 'package:airsoft_telemetry_flutter/services/app_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConfig.primaryColor),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}
