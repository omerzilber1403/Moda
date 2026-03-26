import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/mock_api.dart';
import '../../theme/tokens.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxl),

            // Logo section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenPaddingH,
              ),
              child: Column(
                children: [
                  // App icon — primary circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 32,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.checkroom_rounded,
                      color: AppColors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Moda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -1.5,
                      height: AppTypography.lineHeightTight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Buy & sell with Style Coins',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary,
                      fontSize: AppTypography.fontMd,
                      fontWeight: FontWeight.w400,
                      height: AppTypography.lineHeightNormal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Free coins badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '50 free Style Coins for new users!',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontSize: AppTypography.fontSm,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Choose your account to continue',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textTertiary,
                      fontSize: AppTypography.fontSm,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // User list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenPaddingH,
                  vertical: AppSpacing.sm,
                ),
                itemCount: MockApi.users.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final user = MockApi.users[index];
                  return _UserPickerCard(
                    user: user,
                    isLoading: authState.isLoading,
                    onTap: () =>
                        ref.read(authProvider.notifier).loginAs(user),
                  );
                },
              ),
            ),

            // Dev mode badge
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.code_rounded,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Dev Mode — Pick a test user',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textTertiary,
                            fontSize: AppTypography.fontXs,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserPickerCard extends StatefulWidget {
  final User user;
  final bool isLoading;
  final VoidCallback onTap;

  const _UserPickerCard({
    required this.user,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_UserPickerCard> createState() => _UserPickerCardState();
}

class _UserPickerCardState extends State<_UserPickerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: _pressed ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: _pressed ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: widget.user.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.user.avatarUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.gray100,
                            child: const Icon(Icons.person, size: 28, color: AppColors.gray400),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: AppColors.gray100,
                          child: const Icon(Icons.person, size: 28, color: AppColors.gray400),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: AppTypography.fontMd,
                        fontWeight: FontWeight.bold,
                        height: AppTypography.lineHeightTight,
                      ),
                    ),
                    if (widget.user.city != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              widget.user.city!,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondary,
                                fontSize: AppTypography.fontSm,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'SC',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.primary.withValues(alpha: 0.7),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${widget.user.styleCoinBalance}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.primary,
                                    fontSize: AppTypography.fontXs,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.user.bio != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.user.bio!,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textTertiary,
                          fontSize: AppTypography.fontSm,
                          height: AppTypography.lineHeightNormal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Chevron
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _pressed ? AppColors.primary : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _pressed ? Colors.transparent : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: _pressed ? AppColors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
