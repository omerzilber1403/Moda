import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tokens.dart';

enum GlassButtonVariant { primary, outline, glass }

class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final GlassButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = GlassButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 54,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          if (!widget.isLoading) widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: switch (widget.variant) {
            GlassButtonVariant.primary => _buildPrimary(),
            GlassButtonVariant.outline => _buildOutline(),
            GlassButtonVariant.glass => _buildOutline(),
          },
        ),
      ),
    );
  }

  Widget _buildPrimary() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: widget.isLoading ? null : widget.onPressed,
          splashColor: AppColors.white.withValues(alpha: 0.12),
          highlightColor: AppColors.white.withValues(alpha: 0.06),
          child: _buildContent(AppColors.white),
        ),
      ),
    );
  }

  Widget _buildOutline() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: widget.isLoading ? null : widget.onPressed,
          splashColor: AppColors.primary.withValues(alpha: 0.06),
          highlightColor: AppColors.primary.withValues(alpha: 0.03),
          child: _buildContent(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildContent(Color color) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: color,
          ),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            widget.label,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: AppTypography.fontMd,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
