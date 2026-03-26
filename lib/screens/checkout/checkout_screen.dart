import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/mock_api.dart';
import '../../theme/tokens.dart';
import '../../widgets/glass_button.dart';
import '../profile/buy_coins_sheet.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cartItems = ref.read(cartProvider.notifier).getCartClothingItems();
    final walletState = ref.watch(walletProvider);
    final addressState = ref.watch(addressProvider);
    final selectedAddress = addressState.defaultAddress;
    final hasEnoughCoins = walletState.balance >= cartState.totalCoins;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontLg,
            fontWeight: FontWeight.bold,
            letterSpacing: AppTypography.letterSpacingTitle,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Delivery Address Section
                        _SectionHeader(
                          title: 'Delivery Address',
                          trailing: GestureDetector(
                            onTap: () => context.push('/addresses'),
                            child: Text(
                              'Change',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primary,
                                fontSize: AppTypography.fontSm,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _AddressCard(address: selectedAddress),

                        const SizedBox(height: AppSpacing.xl),

                        // Order Summary Section
                        _SectionHeader(title: 'Order Summary'),
                        const SizedBox(height: AppSpacing.md),
                        ...cartItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _OrderItemRow(item: item),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Payment Section
                        _SectionHeader(title: 'Payment'),
                        const SizedBox(height: AppSpacing.md),
                        _PaymentCard(
                          balance: walletState.balance,
                          totalCost: cartState.totalCoins,
                          hasEnough: hasEnoughCoins,
                          onTopUp: () => _showTopUpSheet(context),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Price Breakdown
                        _PriceBreakdown(
                          subtotal: cartState.totalCoins,
                          total: cartState.totalCoins,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Pay Button
                _CheckoutBottomBar(
                  totalCoins: cartState.totalCoins,
                  isEnabled: hasEnoughCoins && !_isProcessing,
                  isLoading: _isProcessing,
                  onPay: () => _handlePayment(cartItems),
                ),
              ],
            ),
    );
  }

  void _showTopUpSheet(BuildContext context) {
    showBuyCoinsSheet(context, ref);
  }

  Future<void> _handlePayment(List<ClothingItem> cartItems) async {
    setState(() => _isProcessing = true);

    Order? lastOrder;
    for (final item in cartItems) {
      final order = await ref.read(walletProvider.notifier).purchaseItem(item.id);
      if (order != null) lastOrder = order;
    }

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (lastOrder != null) {
      context.go('/checkout-success', extra: {
        'items': cartItems,
        'totalCoins': cartItems.fold<int>(0, (sum, i) => sum + i.priceInCoins),
        'orderId': lastOrder.id,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Purchase failed. Please check your balance.',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontMd,
            fontWeight: FontWeight.bold,
            letterSpacing: AppTypography.letterSpacingTitle,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address? address;

  const _AddressCard({this.address});

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            Icon(Icons.location_off_outlined,
                color: AppColors.textTertiary, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No address selected',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: AppTypography.fontSm,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassButton(
              label: 'Add Address',
              variant: GlassButtonVariant.outline,
              onPressed: () => context.push('/address/new'),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              address!.label == 'Home'
                  ? Icons.home_outlined
                  : address!.label == 'Work'
                      ? Icons.work_outline_rounded
                      : Icons.location_on_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address!.label,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: AppTypography.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${address!.street}, ${address!.city} ${address!.zipCode}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: AppTypography.fontXs,
                    height: AppTypography.lineHeightNormal,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  address!.phone,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: AppTypography.fontXs,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textTertiary, size: 22),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final ClothingItem item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: CachedNetworkImage(
              imageUrl: item.images.isNotEmpty ? item.images.first : '',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 52,
                height: 52,
                color: AppColors.surfaceSecondary,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 52,
                height: 52,
                color: AppColors.surfaceSecondary,
                child: const Icon(Icons.image_outlined,
                    color: AppColors.textTertiary, size: 18),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: AppTypography.fontSm,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.brand != null)
                  Text(
                    item.brand!,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary,
                      fontSize: AppTypography.fontXs,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${item.priceInCoins} SC',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textPrimary,
              fontSize: AppTypography.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final int balance;
  final int totalCost;
  final bool hasEnough;
  final VoidCallback onTopUp;

  const _PaymentCard({
    required this.balance,
    required this.totalCost,
    required this.hasEnough,
    required this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: hasEnough ? AppColors.success.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasEnough
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  hasEnough ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                  color: hasEnough ? AppColors.success : AppColors.warning,
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
                        color: AppColors.textPrimary,
                        fontSize: AppTypography.fontSm,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Balance: $balance SC',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: AppTypography.fontXs,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasEnough)
                Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 24)
              else
                GestureDetector(
                  onTap: onTopUp,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'Top Up',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.white,
                        fontSize: AppTypography.fontXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (!hasEnough) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'You need ${totalCost - balance} more Style Coins to complete this purchase.',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.warning,
                  fontSize: AppTypography.fontXs,
                  fontWeight: FontWeight.w500,
                  height: AppTypography.lineHeightNormal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final int subtotal;
  final int total;

  const _PriceBreakdown({
    required this.subtotal,
    required this.total,
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
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Subtotal', value: '$subtotal SC'),
          const SizedBox(height: AppSpacing.md),
          _PriceRow(
            label: 'Delivery',
            value: 'Free',
            valueColor: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          _PriceRow(
            label: 'Total',
            value: '$total SC',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isBold ? AppTypography.fontMd : AppTypography.fontSm,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: valueColor ?? (isBold ? AppColors.primary : AppColors.textPrimary),
            fontSize: isBold ? AppTypography.fontMd : AppTypography.fontSm,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final int totalCoins;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPay;

  const _CheckoutBottomBar({
    required this.totalCoins,
    required this.isEnabled,
    required this.isLoading,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: AppShadows.lg,
      ),
      child: SizedBox(
        width: double.infinity,
        child: GlassButton(
          label: 'Pay $totalCoins SC',
          icon: Icons.monetization_on_outlined,
          isLoading: isLoading,
          onPressed: isEnabled ? onPay : null,
        ),
      ),
    );
  }
}
