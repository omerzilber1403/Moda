import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/glass_button.dart';

void showBuyCoinsSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _BuyCoinsContent(),
  );
}

class _BuyCoinsContent extends ConsumerStatefulWidget {
  const _BuyCoinsContent();

  @override
  ConsumerState<_BuyCoinsContent> createState() => _BuyCoinsContentState();
}

class _BuyCoinsContentState extends ConsumerState<_BuyCoinsContent> {
  int _selectedAmount = 50;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppLayout.screenPaddingH,
        right: AppLayout.screenPaddingH,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            'Buy Style Coins',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textPrimary,
              fontSize: AppTypography.fontXl,
              fontWeight: FontWeight.bold,
              letterSpacing: AppTypography.letterSpacingTitle,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Subtitle
          Text(
            '1 \u20AA = 1 Style Coin',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: AppTypography.fontSm,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Amount cards
          Row(
            children: [
              _AmountCard(
                amount: 50,
                isSelected: _selectedAmount == 50,
                onTap: () => setState(() => _selectedAmount = 50),
              ),
              const SizedBox(width: AppSpacing.md),
              _AmountCard(
                amount: 100,
                isSelected: _selectedAmount == 100,
                onTap: () => setState(() => _selectedAmount = 100),
              ),
              const SizedBox(width: AppSpacing.md),
              _AmountCard(
                amount: 200,
                isSelected: _selectedAmount == 200,
                onTap: () => setState(() => _selectedAmount = 200),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Purchase button
          GlassButton(
            label: 'Purchase for \u20AA$_selectedAmount',
            icon: Icons.shopping_cart_outlined,
            onPressed: () async {
              try {
                final balanceBefore = ref.read(walletProvider).balance;
                await ref
                    .read(walletProvider.notifier)
                    .topUp(_selectedAmount);
                if (!context.mounted) return;
                final balanceAfter = ref.read(walletProvider).balance;
                if (balanceAfter > balanceBefore) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added $_selectedAmount Style Coins!',
                        style: GoogleFonts.plusJakartaSans(color: AppColors.white),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Top-up failed. Please try again.',
                        style: GoogleFonts.plusJakartaSans(color: AppColors.white),
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  );
                }
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Something went wrong. Please try again.',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.white),
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                );
              }
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmountCard({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppShadows.sm,
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'SC',
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$amount',
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontSize: AppTypography.fontXl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\u20AA$amount',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: AppTypography.fontXs,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
