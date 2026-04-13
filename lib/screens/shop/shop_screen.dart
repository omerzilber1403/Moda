import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/likes_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/tokens.dart';
import '../profile/buy_coins_sheet.dart';
import 'filter_sheet.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopState = ref.watch(shopProvider);
    final walletState = ref.watch(walletProvider);
    final likedItems = ref.watch(likesProvider);
    final likedIds = likedItems.map((i) => i.id).toSet();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.screenPaddingH,
              AppSpacing.lg,
              AppLayout.screenPaddingH,
              0,
            ),
            child: Row(
              children: [
                Text(
                  'Moda',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontSize: AppTypography.font2xl,
                    fontWeight: FontWeight.w900,
                    letterSpacing: AppTypography.letterSpacingHeadline,
                  ),
                ),
                const Spacer(),
                // Coin balance badge — tonal bg only, no border
                GestureDetector(
                  onTap: () => showBuyCoinsSheet(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SC',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${walletState.balance}',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontSize: AppTypography.fontMd,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Search bar + filter button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.screenPaddingH,
            ),
            child: Row(
              children: [
                // Glassmorphic search bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.glassBackgroundLight,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          boxShadow: AppShadows.sm,
                        ),
                        child: TextField(
                          onChanged: (v) =>
                              ref.read(shopProvider.notifier).setSearchQuery(v),
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textPrimary,
                            fontSize: AppTypography.fontSm,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by brand, title...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: AppColors.textTertiary,
                              fontSize: AppTypography.fontSm,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Filter button
                GestureDetector(
                  onTap: () => showFilterSheet(context, ref),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: shopState.filters.activeFilterCount > 0
                          ? AppColors.primary
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: shopState.filters.activeFilterCount > 0
                              ? AppColors.white
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        if (shopState.filters.activeFilterCount > 0)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${shopState.filters.activeFilterCount}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Category chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenPaddingH,
              ),
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: shopState.filters.categoryFilter == null,
                  onTap: () =>
                      ref.read(shopProvider.notifier).setCategory(null),
                ),
                const SizedBox(width: AppSpacing.sm),
                ...shopState.categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: _CategoryChip(
                        label: '${cat.icon ?? ''} ${cat.name}',
                        isSelected:
                            shopState.filters.categoryFilter == cat.id,
                        onTap: () => ref
                            .read(shopProvider.notifier)
                            .setCategory(cat.id),
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.screenPaddingH,
            ),
            child: Row(
              children: [
                Text(
                  '${shopState.items.length} items',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: AppTypography.fontSm,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (shopState.filters.activeFilterCount > 0) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        ref.read(shopProvider.notifier).clearFilters(),
                    child: Text(
                      'Clear filters',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontSize: AppTypography.fontSm,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Grid
          Expanded(
            child: shopState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : shopState.items.isEmpty
                    ? _EmptyState(
                        hasFilters: shopState.filters.activeFilterCount > 0,
                        onClearFilters: () =>
                            ref.read(shopProvider.notifier).clearFilters(),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.only(
                          left: AppLayout.screenPaddingH,
                          right: AppLayout.screenPaddingH,
                          bottom: AppLayout.tabBarHeight + AppSpacing.xl,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppLayout.matchGridGap,
                          crossAxisSpacing: AppLayout.matchGridGap,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: shopState.items.length,
                        itemBuilder: (context, index) {
                          final item = shopState.items[index];
                          final isLiked = likedIds.contains(item.id);
                          return _ShopGridCard(
                            item: item,
                            isLiked: isLiked,
                            onTap: () => context.push('/item/${item.id}'),
                            onLikeToggle: () {
                              if (isLiked) {
                                ref
                                    .read(likesProvider.notifier)
                                    .removeItem(item.id);
                              } else {
                                ref
                                    .read(likesProvider.notifier)
                                    .likeItem(item.id);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ShopGridCard extends StatelessWidget {
  final ClothingItem item;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback onLikeToggle;

  const _ShopGridCard({
    required this.item,
    required this.isLiked,
    required this.onTap,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.lg),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: item.images.first,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.surfaceSecondary,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceSecondary,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),

                  // Heart icon top-right
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: GestureDetector(
                      onTap: onLikeToggle,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.sm,
                        ),
                        child: Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isLiked
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info section below image
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand — uppercase, tracking
                  if (item.brand != null)
                    Text(
                      item.brand!.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Title
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.onSurface,
                      fontSize: AppTypography.fontSm,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Price + condition row
                  Row(
                    children: [
                      // Price pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${item.priceInCoins} SC',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Condition pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          _conditionLabel(item.condition),
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _conditionLabel(String condition) {
    return switch (condition) {
      'new_with_tags' => 'New',
      'like_new' => 'Like New',
      'good' => 'Good',
      'fair' => 'Fair',
      _ => condition,
    };
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryFixed : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontSize: AppTypography.fontSm,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              hasFilters ? 'No items match' : 'No items available',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasFilters
                  ? 'Try adjusting your filters'
                  : 'Check back later for new listings!',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: AppTypography.fontSm,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: onClearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: AppShadows.md,
                  ),
                  child: Text(
                    'Clear Filters',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.white,
                      fontSize: AppTypography.fontSm,
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
