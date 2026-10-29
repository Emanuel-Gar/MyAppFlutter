import 'package:flutter/material.dart';

import 'screens/login.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mi Proyecto',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1976D2),
              surface: const Color(0xFFF8FAFC),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1976D2),
              brightness: Brightness.dark,
              surface: const Color(0xFF0C1620),
            ),
            scaffoldBackgroundColor: const Color(0xFF0C1620),
            cardColor: const Color(0xFF12202E),
            useMaterial3: true,
          ),
          themeMode: themeMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}
