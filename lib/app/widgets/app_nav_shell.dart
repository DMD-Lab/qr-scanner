import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AppNavShell extends StatelessWidget {
  const AppNavShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBgSecondary : AppColors.lightBgPrimary;
    final unselectedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        backgroundColor: bgColor,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : unselectedColor,
          ),
        ),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined, color: unselectedColor),
            selectedIcon:
                const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined, color: unselectedColor),
            selectedIcon:
                const Icon(Icons.history_rounded, color: AppColors.primary),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: unselectedColor),
            selectedIcon:
                const Icon(Icons.settings_rounded, color: AppColors.primary),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
