import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tokens.dart';

class GlassInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const GlassInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<GlassInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: AppTypography.fontSm,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _isFocused ? AppColors.primary : AppColors.border,
              width: _isFocused ? 1.5 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : AppShadows.sm,
          ),
          child: Focus(
            onFocusChange: (focused) =>
                setState(() => _isFocused = focused),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              validator: widget.validator,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontMd,
                letterSpacing: AppTypography.letterSpacingBody,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary,
                  fontSize: AppTypography.fontMd,
                  letterSpacing: AppTypography.letterSpacingBody,
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
