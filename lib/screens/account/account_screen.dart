import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/tokens.dart';
import '../profile/buy_coins_sheet.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final walletState = ref.watch(walletProvider);
    final user = auth.user;

    if (user == null) return const SizedBox();

    void showComingSoon(String feature) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          '$feature coming soon',
          style: GoogleFonts.plusJakartaSans(color: AppColors.white),
        ),
        backgroundColor: AppColors.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Avatar — no border ring per no-line rule
              ClipOval(
                child: user.avatarUrl != null
                    ? CachedNetworkImage(
                        imageUrl: user.avatarUrl!,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 96,
                          height: 96,
                          color: AppColors.surfaceContainerHigh,
                          child: Center(
                            child: Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 96,
                        height: 96,
                        color: AppColors.surfaceContainerHigh,
                        child: Center(
                          child: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Display name
              Text(
                user.displayName,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: AppTypography.fontXl,
                  fontWeight: FontWeight.bold,
                  letterSpacing: AppTypography.letterSpacingTitle,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // Email
              Text(
                user.email,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: AppTypography.fontSm,
                ),
              ),

              if (user.city != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      user.city!,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textTertiary,
                        fontSize: AppTypography.fontXs,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSpacing.xs),
              Text(
                'Member since ${DateFormat('MMMM yyyy').format(user.createdAt)}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary,
                  fontSize: AppTypography.fontXs,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Style Coins balance card
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppLayout.screenPaddingH),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Style Coins',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondary,
                                fontSize: AppTypography.fontXs,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${walletState.balance} SC',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textPrimary,
                                fontSize: AppTypography.fontXl,
                                fontWeight: FontWeight.bold,
                                letterSpacing:
                                    AppTypography.letterSpacingTitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => showBuyCoinsSheet(context, ref),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        child: Text(
                          'Top Up',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: AppTypography.fontSm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Menu section 1
              _MenuSection(
                items: [
                  _MenuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'My Orders',
                    onTap: () => context.push('/orders'),
                  ),
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'My Details',
                    onTap: () => context.push('/account/details'),
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Delivery Address',
                    onTap: () => context.push('/address'),
                  ),
                  _MenuItem(
                    icon: Icons.credit_card_outlined,
                    title: 'Payment Methods',
                    onTap: () => showComingSoon('Payment Methods'),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () => context.push('/account/notifications'),
                  ),
                  _MenuItem(
                    icon: Icons.sell_outlined,
                    title: 'My Items',
                    onTap: () => context.push('/profile'),
                  ),
                  _MenuItem(
                    icon: Icons.favorite_outline_rounded,
                    title: 'Liked Items',
                    onTap: () => context.push('/saved'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Menu section 2 — Support
              _MenuSection(
                items: [
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'FAQs',
                    onTap: () => showComingSoon('FAQs'),
                  ),
                  _MenuItem(
                    icon: Icons.headphones_outlined,
                    title: 'Help Center',
                    onTap: () => showComingSoon('Help Center'),
                  ),
                  _MenuItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Customer Service',
                    onTap: () => showComingSoon('Customer Service'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppLayout.screenPaddingH),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      onTap: () => _showLogoutDialog(context, ref),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.lg,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.logout_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              'Logout',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.error,
                                fontSize: AppTypography.fontMd,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textTertiary,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: AppTypography.fontSm,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: AppTypography.fontSm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: Text(
              'Logout',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.error,
                fontSize: AppTypography.fontSm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppLayout.screenPaddingH),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 68),
                  child: Container(
                    height: 1,
                    color: AppColors.borderLight,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md + 2,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: AppTypography.fontMd,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
