import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'app_tappable.dart';

enum _ButtonVariant { primary, secondary, outline, destructive }

class AppButton extends StatelessWidget {
  const AppButton._({
    super.key,
    required this.label,
    required this.variant,
    this.onTap,
    this.leading,
    this.loading = false,
    this.disabled = false,
    this.expand = false,
  });

  factory AppButton.primary({
    Key? key,
    required String label,
    VoidCallback? onTap,
    Widget? leading,
    bool loading = false,
    bool disabled = false,
    bool expand = false,
  }) =>
      AppButton._(
        key: key,
        label: label,
        variant: _ButtonVariant.primary,
        onTap: onTap,
        leading: leading,
        loading: loading,
        disabled: disabled,
        expand: expand,
      );

  factory AppButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onTap,
    Widget? leading,
    bool loading = false,
    bool disabled = false,
    bool expand = false,
  }) =>
      AppButton._(
        key: key,
        label: label,
        variant: _ButtonVariant.secondary,
        onTap: onTap,
        leading: leading,
        loading: loading,
        disabled: disabled,
        expand: expand,
      );

  factory AppButton.outline({
    Key? key,
    required String label,
    VoidCallback? onTap,
    Widget? leading,
    bool loading = false,
    bool disabled = false,
    bool expand = false,
  }) =>
      AppButton._(
        key: key,
        label: label,
        variant: _ButtonVariant.outline,
        onTap: onTap,
        leading: leading,
        loading: loading,
        disabled: disabled,
        expand: expand,
      );

  factory AppButton.destructive({
    Key? key,
    required String label,
    VoidCallback? onTap,
    Widget? leading,
    bool loading = false,
    bool disabled = false,
    bool expand = false,
  }) =>
      AppButton._(
        key: key,
        label: label,
        variant: _ButtonVariant.destructive,
        onTap: onTap,
        leading: leading,
        loading: loading,
        disabled: disabled,
        expand: expand,
      );

  final String label;
  final _ButtonVariant variant;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool loading;
  final bool disabled;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor;
    final Color textColor;
    final Color? borderColor;

    switch (variant) {
      case _ButtonVariant.primary:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        borderColor = null;
      case _ButtonVariant.secondary:
        bgColor = isDark ? AppColors.darkBgTertiary : AppColors.lightBgTertiary;
        textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        borderColor = null;
      case _ButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
      case _ButtonVariant.destructive:
        bgColor = isDark ? AppColors.errorDark : AppColors.errorLight;
        textColor = Colors.white;
        borderColor = null;
    }

    Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: textColor,
            ),
          )
        else ...[
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.s2),
          ],
          Text(label, style: AppTextStyles.buttonLabel.copyWith(color: textColor)),
        ],
      ],
    );

    Widget button = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
      ),
      child: content,
    );

    if (expand) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return AppTappable(
      onTap: (loading || disabled) ? null : onTap,
      disabled: disabled || loading,
      child: button,
    );
  }
}
