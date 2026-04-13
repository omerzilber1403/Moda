import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/browse_provider.dart';
import '../../providers/likes_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/tokens.dart';
import '../profile/buy_coins_sheet.dart';

class ConfirmOrderScreen extends ConsumerStatefulWidget {
  final ClothingItem item;

  const ConfirmOrderScreen({super.key, required this.item});

  @override
  ConsumerState<ConfirmOrderScreen> createState() =>
      _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends ConsumerState<ConfirmOrderScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isPurchasing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showPaymentConfirmation() {
    final balance = ref.read(walletProvider).balance;
    final cost = widget.item.priceInCoins;
    final newBalance = balance - cost;
    final hasEnough = balance >= cost;

    showDialog(
      context: context,
      barrierColor: AppColors.onSurface.withValues(alpha: 0.4),
      builder: (ctx) => _PaymentDialog(
        cost: cost,
        currentBalance: balance,
        newBalance: newBalance,
        hasEnough: hasEnough,
        isLoading: _isPurchasing,
        onConfirm: hasEnough ? () => _executeLock(ctx) : null,
        onTopUp: () {
          Navigator.of(ctx).pop();
          showBuyCoinsSheet(context, ref);
        },
      ),
    );
  }

  Future<void> _executeLock(BuildContext dialogContext) async {
    setState(() => _isPurchasing = true);
    Navigator.of(dialogContext).pop();

    final order = await ref
        .read(walletProvider.notifier)
        .lockCoinsForOrder(widget.item.id);

    if (!mounted) return;
    setState(() => _isPurchasing = false);

    if (order != null) {
      ref.read(likesProvider.notifier).removeItem(widget.item.id);
      ref.read(browseProvider.notifier).loadItems();
      ref.read(ordersProvider.notifier).refresh();
      // Go directly to chat with seller — coins are locked, not transferred
      context.go('/chat/${order.id}');
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final walletState = ref.watch(walletProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image carousel
                _ImageCarousel(
                  images: item.images,
                  pageController: _pageController,
                  currentPage: _currentPage,
                  onPageChanged: (p) => setState(() => _currentPage = p),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppLayout.screenPaddingH,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      // Brand
                      if (item.brand != null)
                        Text(
                          item.brand!.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontSize: AppTypography.fontXs,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),

                      const SizedBox(height: AppSpacing.xs),

                      // Title
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontXl,
                          fontWeight: FontWeight.bold,
                          letterSpacing: AppTypography.letterSpacingTitle,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Details row
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _Chip(label: item.displaySize, icon: Icons.straighten_rounded),
                          _Chip(label: item.condition, icon: Icons.verified_outlined),
                          if (item.color != null)
                            _Chip(label: item.color!, icon: Icons.palette_outlined),
                          _Chip(label: item.clothingType.label, icon: Icons.checkroom_rounded),
                          if (item.gender != null)
                            _Chip(label: _genderLabel(item.gender!), icon: Icons.wc_outlined),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Description
                      if (item.description != null) ...[
                        Text(
                          'Description',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textPrimary,
                            fontSize: AppTypography.fontMd,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          item.description!,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: AppTypography.fontSm,
                            height: AppTypography.lineHeightRelaxed,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],

                      // Pickup location
                      Text(
                        'Pickup Location',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontMd,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _LocationCard(
                        address: item.pickupAddress,
                        sellerCity: item.owner?.city,
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Seller
                      if (item.owner != null) ...[
                        Text(
                          'Seller',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textPrimary,
                            fontSize: AppTypography.fontMd,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _SellerCard(owner: item.owner!),
                      ],

                      const SizedBox(height: AppSpacing.xxl),

                      // Price summary
                      _PriceSummary(
                        price: item.priceInCoins,
                        balance: walletState.balance,
                      ),

                      // Bottom spacing for CTA bar
                      SizedBox(height: bottomPadding + 100 + AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.lg,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.glassBackgroundDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(
                    left: AppLayout.screenPaddingH,
                    right: AppLayout.screenPaddingH,
                    top: AppSpacing.md,
                    bottom: bottomPadding + AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.92),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.borderLight,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Price
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textTertiary,
                              fontSize: AppTypography.fontXs,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.priceInCoins} SC',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textPrimary,
                              fontSize: AppTypography.fontXl,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Confirm button
                      GestureDetector(
                        onTap: _isPurchasing ? null : _showPaymentConfirmation,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadows.md,
                          ),
                          child: Center(
                            child: _isPurchasing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Text(
                                    'Confirm Purchase',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.white,
                                      fontSize: AppTypography.fontMd,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _genderLabel(String g) {
    switch (g) {
      case 'men': return 'Men';
      case 'women': return 'Women';
      case 'unisex': return 'Unisex';
      default: return g;
    }
  }
}

// ---------------------------------------------------------------------------
// Image carousel (compact, shorter than item detail)
// ---------------------------------------------------------------------------

class _ImageCarousel extends StatelessWidget {
  final List<String> images;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _ImageCarousel({
    required this.images,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.38;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.length > 1)
            PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemCount: images.length,
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceContainerHigh),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(Icons.image_outlined,
                      color: AppColors.textTertiary, size: 48),
                ),
              ),
            )
          else
            CachedNetworkImage(
              imageUrl: images.isNotEmpty ? images.first : '',
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.surfaceContainerHigh),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHigh,
                child: const Icon(Icons.image_outlined,
                    color: AppColors.textTertiary, size: 48),
              ),
            ),

          // Page dots
          if (images.length > 1)
            Positioned(
              bottom: AppSpacing.md,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  return Container(
                    width: i == currentPage ? 20 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == currentPage
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info chip
// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: AppTypography.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Location card
// ---------------------------------------------------------------------------

class _LocationCard extends StatelessWidget {
  final String? address;
  final String? sellerCity;

  const _LocationCard({this.address, this.sellerCity});

  @override
  Widget build(BuildContext context) {
    final displayAddress = address ?? sellerCity ?? 'To be arranged with seller';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.location_on_outlined,
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
                  address != null ? 'Pickup Address' : 'Location',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: AppTypography.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  displayAddress,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: AppTypography.fontXs,
                    height: AppTypography.lineHeightNormal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seller card
// ---------------------------------------------------------------------------

class _SellerCard extends StatelessWidget {
  final AppUserRef owner;

  const _SellerCard({required this.owner});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          ClipOval(
            child: owner.avatarUrl != null
                ? CachedNetworkImage(
                    imageUrl: owner.avatarUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _AvatarPlaceholder(),
                  )
                : _AvatarPlaceholder(),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner.displayName,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: AppTypography.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (owner.city != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    owner.city!,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textTertiary,
                      fontSize: AppTypography.fontXs,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      color: AppColors.surfaceContainerHigh,
      child: const Icon(Icons.person, size: 20, color: AppColors.textTertiary),
    );
  }
}

// ---------------------------------------------------------------------------
// Price summary
// ---------------------------------------------------------------------------

class _PriceSummary extends StatelessWidget {
  final int price;
  final int balance;

  const _PriceSummary({required this.price, required this.balance});

  @override
  Widget build(BuildContext context) {
    final hasEnough = balance >= price;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Item Price', value: '$price SC'),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: 'Delivery',
            value: 'Free',
            valueColor: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(height: 1, color: AppColors.surfaceContainerHigh),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: 'Your Balance',
            value: '$balance SC',
            valueColor: hasEnough ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: 'After Purchase',
            value: '${balance - price} SC',
            isBold: true,
            valueColor: hasEnough ? AppColors.textPrimary : AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow({
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
            color: valueColor ?? AppColors.textPrimary,
            fontSize: isBold ? AppTypography.fontMd : AppTypography.fontSm,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Payment confirmation dialog
// ---------------------------------------------------------------------------

class _PaymentDialog extends StatelessWidget {
  final int cost;
  final int currentBalance;
  final int newBalance;
  final bool hasEnough;
  final bool isLoading;
  final VoidCallback? onConfirm;
  final VoidCallback onTopUp;

  const _PaymentDialog({
    required this.cost,
    required this.currentBalance,
    required this.newBalance,
    required this.hasEnough,
    required this.isLoading,
    this.onConfirm,
    required this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coin icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monetization_on_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              'Confirm Purchase',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              hasEnough
                  ? 'Your $cost Style Coins will be locked until the pickup is completed. Both you and the seller must confirm the pickup for the transaction to finalize.'
                  : 'You need ${cost - currentBalance} more Style Coins.',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: AppTypography.fontSm,
                height: AppTypography.lineHeightNormal,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Balance breakdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  _DialogRow(
                    label: 'Current Balance',
                    value: '$currentBalance SC',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DialogRow(
                    label: 'Locked',
                    value: '- $cost SC',
                    valueColor: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    height: 1,
                    color: AppColors.surfaceContainerHigh,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DialogRow(
                    label: 'New Balance',
                    value: hasEnough ? '$newBalance SC' : 'Insufficient',
                    valueColor:
                        hasEnough ? AppColors.success : AppColors.error,
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Buttons
            if (hasEnough) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    'Lock $cost SC',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppTypography.fontMd,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppTypography.fontMd,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onTopUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    'Top Up Coins',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppTypography.fontMd,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppTypography.fontMd,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _DialogRow({
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
            color: AppColors.textSecondary,
            fontSize: AppTypography.fontSm,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: AppTypography.fontSm,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
