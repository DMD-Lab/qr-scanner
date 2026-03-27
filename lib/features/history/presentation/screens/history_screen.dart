import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/history_provider.dart';
import '../../../scanner/domain/models/scan_result.dart';
import '../../../scanner/domain/models/qr_type.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          historyAsync.maybeWhen(
            data: (items) => items.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Tout effacer',
                    onPressed: () => _confirmClearAll(context, ref),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (items) => items.isEmpty ? _EmptyState() : _HistoryList(items: items),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vider l\'historique'),
        content: const Text('Tous les scans seront supprimés. Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items});
  final List<ScanResult> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 2),
      itemBuilder: (_, i) => _HistoryTile(item: items[i]),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.item});
  final ScanResult item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
    final dateStr = DateFormat('dd/MM/yyyy • HH:mm').format(item.scannedAt);

    return Dismissible(
      key: Key('history_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.s5),
        color: AppColors.errorDark,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => ref.read(historyProvider.notifier).delete(item.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s2,
          ),
          leading: _TypeIcon(type: item.type),
          title: Text(
            item.raw,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: item.isUrl
                ? AppTextStyles.label.copyWith(color: AppColors.primary)
                : AppTextStyles.label,
          ),
          subtitle: Text(dateStr, style: AppTextStyles.caption),
          trailing: _TileMenu(item: item),
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});
  final QrType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      QrType.url => (Icons.link, AppColors.primary),
      QrType.text => (Icons.text_fields, AppColors.darkTextSecondary),
      QrType.unsupported => (Icons.help_outline, AppColors.warningDark),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _TileMenu extends StatelessWidget {
  const _TileMenu({required this.item});
  final ScanResult item;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'copy', child: Text('Copier')),
        if (item.isUrl) const PopupMenuItem(value: 'open', child: Text('Ouvrir')),
      ],
      onSelected: (action) async {
        if (action == 'copy') {
          await Clipboard.setData(ClipboardData(text: item.raw));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copié dans le presse-papier')),
            );
          }
        } else if (action == 'open') {
          final uri = Uri.tryParse(item.raw);
          if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.darkTextDisabled),
          const SizedBox(height: AppSpacing.s4),
          Text('Aucun scan pour le moment', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.s2),
          Text(
            'Vos scans apparaîtront ici',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
          ),
        ],
      ),
    );
  }
}
