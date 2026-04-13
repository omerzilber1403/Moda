import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/browse_provider.dart';
import '../../providers/likes_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_button.dart';
import '../profile/buy_coins_sheet.dart';

enum _LikesSortOption { newest, priceLow, priceHigh }

class LikesScreen extends ConsumerStatefulWidget {
  const LikesScreen({super.key});

  @override
  ConsumerState<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends ConsumerState<LikesScreen> {
  _LikesSortOption _sort = _LikesSortOption.newest;

  List<ClothingItem> _sorted(List<ClothingItem> items) {
    final copy = [...items];
    switch (_sort) {
      case _LikesSortOption.newest:
        return copy; // already newest-first from provider
      case _LikesSortOption.priceLow:
        copy.sort((a, b) => a.priceInCoins.compareTo(b.priceInCoins));
      case _LikesSortOption.priceHigh:
        copy.sort((a, b) => b.priceInCoins.compareTo(a.priceInCoins));
    }
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final likedItems = ref.watch(likesProvider);
    final sorted = _sorted(likedItems);
    final hasBack = context.canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.screenPaddingH,
                AppSpacing.xl,
                AppLayout.screenPaddingH,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  if (hasBack) ...[
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Text(
                    'Saved',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.onSurface,
                      fontSize: AppTypography.font2xl,
                      fontWeight: FontWeight.w900,
                      letterSpacing: AppTypography.letterSpacingHeadline,
                    ),
                  ),
                  const Spacer(),
                  if (likedItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${likedItems.length} item${likedItems.length == 1 ? '' : 's'}',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontSize: AppTypography.fontSm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Sort chips
            if (likedItems.isNotEmpty) ...[
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppLayout.screenPaddingH),
                  children: [
                    _SortChip(
                      label: 'Newest',
                      selected: _sort == _LikesSortOption.newest,
                      onTap: () =>
                          setState(() => _sort = _LikesSortOption.newest),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _SortChip(
                      label: 'Price: Low to High',
                      selected: _sort == _LikesSortOption.priceLow,
                      onTap: () =>
                          setState(() => _sort = _LikesSortOption.priceLow),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _SortChip(
                      label: 'Price: High to Low',
                      selected: _sort == _LikesSortOption.priceHigh,
                      onTap: () =>
                          setState(() => _sort = _LikesSortOption.priceHigh),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Items grid
            Expanded(
              child: likedItems.isEmpty
                  ? const EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'No likes yet',
                      subtitle: 'Swipe right on items you love!',
                    )
                  : GridView.builder(
                      padding: EdgeInsets.only(
                        left: AppLayout.screenPaddingH,
                        right: AppLayout.screenPaddingH,
                        bottom: AppLayout.tabBarHeight + AppSpacing.lg,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppLayout.matchGridGap,
                        crossAxisSpacing: AppLayout.matchGridGap,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final item = sorted[index];
                        return _LikedItemCard(
                          item: item,
                          ownerName: item.owner?.displayName ?? 'Unknown',
                          onTap: () =>
                              _showItemDetail(context, ref, item, item.owner),
                          onRemove: () => ref
                              .read(likesProvider.notifier)
                              .removeItem(item.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetail(
    BuildContext context,
    WidgetRef ref,
    ClothingItem item,
    AppUserRef? owner,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemDetailSheet(item: item, owner: owner),
    );
  }
}

class _LikedItemCard extends StatelessWidget {
  final ClothingItem item;
  final String ownerName;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _LikedItemCard({
    required this.item,
    required this.ownerName,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: AppShadows.md,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
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

              // Scrim
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppGradients.cardScrim,
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xxl,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.white,
                          fontSize: AppTypography.fontSm,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ownerName,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontSize: AppTypography.fontXs,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Price badge top-right
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SC',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${item.priceInCoins}',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.white,
                          fontSize: AppTypography.fontXs,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Remove (unlike) button top-left
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.glassBackgroundDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemDetailSheet extends ConsumerWidget {
  final ClothingItem item;
  final AppUserRef? owner;

  const _ItemDetailSheet({required this.item, this.owner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),

            // Item image
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: CachedNetworkImage(
                  imageUrl: item.images.first,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    height: 300,
                    color: AppColors.surfaceSecondary,
                    child: const Icon(Icons.image_outlined,
                        color: AppColors.textTertiary, size: 48),
                  ),
                ),
              ),
            ),

            // Item info
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenPaddingH,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: AppSpacing.sm),

                  // Info chips
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (item.brand != null) _InfoChip(label: item.brand!),
                      _InfoChip(label: item.displaySize),
                      _InfoChip(label: item.condition),
                      if (item.color != null) _InfoChip(label: item.color!),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Description
                  if (item.description != null) ...[
                    Text(
                      item.description!,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: AppTypography.fontSm,
                        height: AppTypography.lineHeightRelaxed,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Seller row
                  if (owner != null)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          ClipOval(
                            child: owner!.avatarUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: owner!.avatarUrl!,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      width: 36,
                                      height: 36,
                                      color: AppColors.surfaceContainerHigh,
                                      child: const Icon(Icons.person,
                                          size: 16,
                                          color: AppColors.onSurfaceVariant),
                                    ),
                                  )
                                : Container(
                                    width: 36,
                                    height: 36,
                                    color: AppColors.surfaceContainerHigh,
                                    child: const Icon(Icons.person,
                                        size: 16, color: AppColors.onSurfaceVariant),
                                  ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  owner!.displayName,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textPrimary,
                                    fontSize: AppTypography.fontSm,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (owner!.city != null)
                                  Text(
                                    owner!.city!,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textTertiary,
                                      fontSize: AppTypography.fontXs,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),

                  // Price display
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'SC',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '${item.priceInCoins} Style Coins',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontSize: AppTypography.fontXl,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Buy button
                  GlassButton(
                    label: 'Buy for ${item.priceInCoins} SC',
                    icon: Icons.shopping_bag_outlined,
                    onPressed: () => _handlePurchase(context, ref),
                    width: double.infinity,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom +
                        AppSpacing.xl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(BuildContext context, WidgetRef ref) async {
    final walletState = ref.read(walletProvider);

    if (walletState.balance < item.priceInCoins) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not enough Style Coins!',
            style: GoogleFonts.plusJakartaSans(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          action: SnackBarAction(
            label: 'Buy More',
            textColor: AppColors.white,
            onPressed: () => showBuyCoinsSheet(context, ref),
          ),
        ),
      );
      return;
    }

    final order =
        await ref.read(walletProvider.notifier).lockCoinsForOrder(item.id);
    if (order != null && context.mounted) {
      // Remove from likes, refresh data
      ref.read(likesProvider.notifier).removeItem(item.id);
      ref.read(browseProvider.notifier).loadItems();
      ref.read(ordersProvider.notifier).refresh();
      Navigator.of(context).pop();
      context.push('/chat/${order.id}');
    }
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryFixed : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontSize: AppTypography.fontXs,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
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
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.sm),
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
