import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/cart_provider.dart';
import '../../services/mock_api.dart';
import '../../theme/tokens.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_button.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartItems = ref.read(cartProvider.notifier).getCartClothingItems();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My Cart',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontLg,
                fontWeight: FontWeight.bold,
                letterSpacing: AppTypography.letterSpacingTitle,
              ),
            ),
            if (cartState.itemCount > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${cartState.itemCount}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.white,
                    fontSize: AppTypography.fontXs,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        bottom: null,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState(context)
          : _buildCartList(context, ref, cartState, cartItems),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyState(
      icon: Icons.shopping_bag_outlined,
      title: 'Your cart is empty',
      subtitle: 'Start browsing to add items',
      action: GlassButton(
        label: 'Browse Shop',
        onPressed: () => context.go('/shop'),
      ),
    );
  }

  Widget _buildCartList(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
    List<ClothingItem> cartItems,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: cartItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _CartItemCard(
                item: item,
                onRemove: () {
                  ref.read(cartProvider.notifier).removeItem(item.id);
                },
                onTap: () => context.push('/item/${item.id}'),
              );
            },
          ),
        ),
        _BottomBar(
          totalCoins: cartState.totalCoins,
          onCheckout: () => context.push('/checkout'),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: CachedNetworkImage(
                imageUrl: item.images.isNotEmpty ? item.images.first : '',
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 88,
                  height: 88,
                  color: AppColors.surfaceSecondary,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.textTertiary,
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 88,
                  height: 88,
                  color: AppColors.surfaceSecondary,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: AppTypography.fontSm,
                      fontWeight: FontWeight.w600,
                      letterSpacing: AppTypography.letterSpacingBody,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.brand != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.brand!,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: AppTypography.fontXs,
                        letterSpacing: AppTypography.letterSpacingBody,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _InfoChip(label: item.displaySize),
                      const SizedBox(width: AppSpacing.sm),
                      _InfoChip(label: item.condition),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${item.priceInCoins} SC',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontSize: AppTypography.fontMd,
                      fontWeight: FontWeight.bold,
                      letterSpacing: AppTypography.letterSpacingTight,
                    ),
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.textTertiary,
              iconSize: 22,
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondary,
          fontSize: AppTypography.fontXs,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int totalCoins;
  final VoidCallback onCheckout;

  const _BottomBar({
    required this.totalCoins,
    required this.onCheckout,
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
        color: AppColors.surfaceContainerLowest,
        boxShadow: AppShadows.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: AppTypography.fontXs,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$totalCoins SC',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: AppTypography.fontXl,
                    fontWeight: FontWeight.bold,
                    letterSpacing: AppTypography.letterSpacingTight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 160,
            child: GlassButton(
              label: 'Checkout',
              icon: Icons.arrow_forward_rounded,
              onPressed: onCheckout,
            ),
          ),
        ],
      ),
    );
  }
}
