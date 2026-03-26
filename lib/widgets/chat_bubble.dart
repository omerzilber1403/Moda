import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tokens.dart';

class ChatBubble extends StatelessWidget {
  final String content;
  final bool isMine;
  final String time;

  const ChatBubble({
    super.key,
    required this.content,
    required this.isMine,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.74,
        ),
        margin: EdgeInsets.only(
          top: AppSpacing.xs,
          bottom: AppSpacing.xs,
          left: isMine ? AppSpacing.xxxl : AppLayout.screenPaddingH,
          right: isMine ? AppLayout.screenPaddingH : AppSpacing.xxxl,
        ),
        child: isMine
            ? _MineBubble(content: content, time: time)
            : _TheirsBubble(content: content, time: time),
      ),
    );
  }
}

class _MineBubble extends StatelessWidget {
  final String content;
  final String time;

  const _MineBubble({required this.content, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
          bottomLeft: Radius.circular(AppRadius.xxl),
          bottomRight: Radius.circular(AppSpacing.sm),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.white,
              fontSize: AppTypography.fontMd,
              height: AppTypography.lineHeightNormal,
              letterSpacing: AppTypography.letterSpacingBody,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontSize: AppTypography.fontXs,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.done_all_rounded,
                size: 13,
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TheirsBubble extends StatelessWidget {
  final String content;
  final String time;

  const _TheirsBubble({required this.content, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
          bottomLeft: Radius.circular(AppSpacing.sm),
          bottomRight: Radius.circular(AppRadius.xxl),
        ),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textPrimary,
              fontSize: AppTypography.fontMd,
              height: AppTypography.lineHeightNormal,
              letterSpacing: AppTypography.letterSpacingBody,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            time,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textTertiary,
              fontSize: AppTypography.fontXs,
            ),
          ),
        ],
      ),
    );
  }
}
