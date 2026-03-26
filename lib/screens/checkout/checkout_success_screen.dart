import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/cart_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/glass_button.dart';

class CheckoutSuccessScreen extends ConsumerStatefulWidget {
  final List<ClothingItem> items;
  final int totalCoins;
  final String orderId;

  const CheckoutSuccessScreen({
    super.key,
    required this.items,
    required this.totalCoins,
    required this.orderId,
  });

  @override
  ConsumerState<CheckoutSuccessScreen> createState() =>
      _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends ConsumerState<CheckoutSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Clear the cart on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartProvider.notifier).clear();
    });

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated checkmark
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Title and subtitle
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Order Placed!',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: AppTypography.font2xl,
                        fontWeight: FontWeight.bold,
                        letterSpacing: AppTypography.letterSpacingTitle,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text(
                        'Your Style Coins have been transferred. Chat with the seller to arrange pickup or delivery.',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: AppTypography.fontSm,
                          height: AppTypography.lineHeightRelaxed,
                          letterSpacing: AppTypography.letterSpacingBody,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Order summary card
              FadeTransition(
                opacity: _fadeAnimation,
                child: _OrderSummaryCard(
                  items: widget.items,
                  totalCoins: widget.totalCoins,
                ),
              ),

              const Spacer(flex: 3),

              // Action buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: GlassButton(
                        label: 'Chat with Seller',
                        icon: Icons.chat_bubble_outline_rounded,
                        onPressed: () => context.go('/chat/${widget.orderId}'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: GlassButton(
                        label: 'Continue Shopping',
                        variant: GlassButtonVariant.outline,
                        icon: Icons.shopping_bag_outlined,
                        onPressed: () => context.go('/shop'),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final List<ClothingItem> items;
  final int totalCoins;

  const _OrderSummaryCard({
    required this.items,
    required this.totalCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textPrimary,
              fontSize: AppTypography.fontSm,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: AppTypography.fontXs,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      '${item.priceInCoins} SC',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: AppTypography.fontXs,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Paid',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: AppTypography.fontSm,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$totalCoins SC',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontSize: AppTypography.fontSm,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
