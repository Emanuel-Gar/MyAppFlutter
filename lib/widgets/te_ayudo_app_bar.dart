import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TeAyudoAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double _toolbarHeight = kToolbarHeight;

  const TeAyudoAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return AppBar(
      backgroundColor: isDarkMode ? const Color(0xFF12202E) : Colors.white,
      foregroundColor: textColor,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.handshake, color: Colors.blue, size: 28),
          const SizedBox(width: 8),
          Text(
            "Te Ayudo",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
      actions: const [ThemeToggleButton()],
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      tooltip: isDarkMode ? 'Activar modo claro' : 'Activar modo oscuro',
      icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: toggleAppTheme,
    );
  }
}
