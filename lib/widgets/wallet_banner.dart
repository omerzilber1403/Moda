import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tokens.dart';

class WalletBanner extends StatelessWidget {
  final int balance;
  final VoidCallback? onBuyCoins;

  const WalletBanner({
    super.key,
    required this.balance,
    this.onBuyCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Coin icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'SC',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontSize: AppTypography.fontSm,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Balance
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Style Coins',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontSize: AppTypography.fontXs,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$balance',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontSize: AppTypography.fontXl,
                    fontWeight: FontWeight.bold,
                    height: AppTypography.lineHeightTight,
                  ),
                ),
              ],
            ),
          ),

          // Buy Coins button
          if (onBuyCoins != null)
            GestureDetector(
              onTap: onBuyCoins,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Buy Coins',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontSize: AppTypography.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
