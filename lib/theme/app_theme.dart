import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

void toggleAppTheme() {
  appThemeMode.value = appThemeMode.value == ThemeMode.dark
      ? ThemeMode.light
      : ThemeMode.dark;
}
