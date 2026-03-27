import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          _SectionHeader(label: 'Apparence'),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Thème sombre',
            subtitle: 'Activer le mode sombre',
            trailing: Switch(
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (v) => notifier.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
              activeThumbColor: AppColors.primary,
            ),
          ),
          _SectionHeader(label: 'Scanner'),
          _SettingsTile(
            icon: Icons.open_in_browser_outlined,
            title: 'Ouverture automatique',
            subtitle: 'Ouvre les liens sans confirmation',
            trailing: Switch(
              value: settings.autoOpen,
              onChanged: notifier.setAutoOpen,
              activeThumbColor: AppColors.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.vibration_outlined,
            title: 'Retour haptique',
            subtitle: 'Vibration lors d\'un scan réussi',
            trailing: Switch(
              value: settings.hapticEnabled,
              onChanged: notifier.setHapticEnabled,
              activeThumbColor: AppColors.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.volume_up_outlined,
            title: 'Son',
            subtitle: 'Son lors d\'un scan réussi',
            trailing: Switch(
              value: settings.soundEnabled,
              onChanged: notifier.setSoundEnabled,
              activeThumbColor: AppColors.primary,
            ),
          ),
          _SectionHeader(label: 'Données'),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Vider l\'historique',
            subtitle: 'Supprimer tous les scans enregistrés',
            onTap: () => _confirmClearHistory(context, ref),
          ),
          _SectionHeader(label: 'À propos'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'QR Scanner',
            subtitle: 'Version 1.0.0',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Une app créée par',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                  ),
                ),
                ColorFiltered(
                  colorFilter: isDark
                      ? const ColorFilter.matrix([
                          -1,  0,  0, 0, 255,
                           0, -1,  0, 0, 255,
                           0,  0, -1, 0, 255,
                           0,  0,  0, 1,   0,
                        ])
                      : const ColorFilter.matrix([
                          1, 0, 0, 0, 0,
                          0, 1, 0, 0, 0,
                          0, 0, 1, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                  child: Image.asset(
                    'assets/images/dmdlab_logo.png',
                    width: 80,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vider l\'historique'),
        content: const Text('Tous les scans seront supprimés. Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s5, AppSpacing.s5, AppSpacing.s5, AppSpacing.s2),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s5,
        vertical: AppSpacing.s1,
      ),
      leading: Icon(icon, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      title: Text(title, style: AppTextStyles.label),
      subtitle: subtitle != null ? Text(subtitle!, style: AppTextStyles.caption) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
