import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Surface card — tonal background with ambient shadow, no border line.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  // borderColor kept for API compat but ignored — no-line rule
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
        boxShadow: AppShadows.md,
      ),
      child: child,
    );
  }
}
