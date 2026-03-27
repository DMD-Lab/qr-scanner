import 'package:flutter/material.dart';
import '../../domain/models/qr_type.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class ScanResultSheet extends StatelessWidget {
  const ScanResultSheet({
    super.key,
    required this.raw,
    required this.type,
    required this.onCopy,
    required this.onShare,
    this.onOpen,
  });

  final String raw;
  final QrType type;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBgSecondary : AppColors.lightBgPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.s5),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.s5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.s4),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),

          // Type badge + titre
          Row(
            children: [
              _TypeBadge(type: type),
              if (type == QrType.url) ...[
                const SizedBox(width: AppSpacing.s2),
                if (_isHttp) _WarningBadge(label: 'Non sécurisé', color: AppColors.warningDark),
                if (_isShortUrl) _WarningBadge(label: 'URL raccourcie', color: AppColors.infoDark),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.s4),

          // Contenu
          if (type == QrType.unsupported)
            _UnsupportedContent()
          else
            _ContentBox(raw: raw, type: type),

          const SizedBox(height: AppSpacing.s5),

          // Actions
          if (type != QrType.unsupported) ...[
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.copy,
                    label: 'Copier',
                    onTap: () {
                      Navigator.pop(context);
                      onCopy();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.share,
                    label: 'Partager',
                    onTap: () {
                      Navigator.pop(context);
                      onShare();
                    },
                  ),
                ),
                if (onOpen != null) ...[
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.open_in_browser,
                      label: 'Ouvrir',
                      primary: true,
                      onTap: () {
                        Navigator.pop(context);
                        onOpen!();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.s2),
        ],
      ),
    );
  }

  bool get _isHttp => raw.trim().toLowerCase().startsWith('http://');

  bool get _isShortUrl {
    const shorteners = ['bit.ly', 't.co', 'tinyurl.com', 'goo.gl', 'ow.ly', 'short.link'];
    final host = Uri.tryParse(raw)?.host.toLowerCase() ?? '';
    return shorteners.any((s) => host == s || host.endsWith('.$s'));
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final QrType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        type.label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WarningBadge extends StatelessWidget {
  const _WarningBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ContentBox extends StatelessWidget {
  const _ContentBox({required this.raw, required this.type});
  final String raw;
  final QrType type;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBgTertiary : AppColors.lightBgTertiary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        raw,
        style: type == QrType.url
            ? AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              )
            : AppTextStyles.mono,
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _UnsupportedContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.help_outline, size: 40, color: AppColors.darkTextSecondary),
        const SizedBox(height: AppSpacing.s3),
        Text(
          'Type de QR code non supporté',
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          'Cette app gère uniquement les URLs et le texte pour le moment.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBgTertiary : AppColors.lightBgTertiary;

    if (primary) {
      return FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 48,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.s2),
            Text(label, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}
