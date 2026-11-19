import 'package:flutter/material.dart';

import 'te_ayudo_app_bar.dart';

class ContratanteAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ContratanteAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryBlue = Color(0xFF1976D2);
    final appBarColor = isDarkMode ? const Color(0xFF1E1E1E) : primaryBlue;

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: appBarColor,
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        const ThemeToggleButton(iconColor: Colors.white),
        IconButton(
          tooltip: 'Cerrar sesión',
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Text(
              'CC',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
