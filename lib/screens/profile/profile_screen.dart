import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/items_provider.dart';
import '../../providers/likes_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/orders_provider.dart';
import '../../services/mock_api.dart';
import '../../theme/tokens.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/wallet_banner.dart';
import 'buy_coins_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final myItems = ref.watch(myItemsProvider);
    final walletState = ref.watch(walletProvider);
    final allOrders = ref.watch(ordersProvider);
    final likedItems = ref.watch(likesProvider);
    final salesCount = allOrders.where((o) => !o.isBuyer).length;
    final user = auth.user;

    if (user == null) return const SizedBox();

    return SafeArea(
      bottom: false,
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: AppLayout.tabBarHeight + AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // White AppBar-style header
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppSpacing.md,
                left: AppLayout.screenPaddingH,
                right: AppLayout.screenPaddingH,
                bottom: AppSpacing.md,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    user.displayName,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: AppTypography.fontLg,
                      fontWeight: FontWeight.bold,
                      letterSpacing: AppTypography.letterSpacingTitle,
                    ),
                  ),
                  const Spacer(),
                  // Settings icon button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Thin top border
            Container(height: 1, color: AppColors.border),

            const SizedBox(height: AppSpacing.xl),

            // Avatar — centered, thin gray ring
            Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: user.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: user.avatarUrl!,
                          width: 108,
                          height: 108,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.gray100,
                            child: const Icon(Icons.person, size: 52, color: AppColors.gray400),
                          ),
                        )
                      : Container(
                          width: 108,
                          height: 108,
                          color: AppColors.gray100,
                          child: const Icon(Icons.person, size: 52, color: AppColors.gray400),
                        ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // User info — centered
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenPaddingH),
              child: Column(
                children: [
                  if (user.city != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          user.city!,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: AppTypography.fontSm,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (user.bio != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user.bio!,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: AppTypography.fontSm,
                        height: AppTypography.lineHeightRelaxed,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),

                  // Wallet banner
                  WalletBanner(
                    balance: walletState.balance,
                    onBuyCoins: () => showBuyCoinsSheet(context, ref),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Stats row
                  GlassCard(
                    borderRadius: AppRadius.xxl,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(
                          label: 'Items',
                          value: '${myItems.length}',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.border,
                        ),
                        _StatColumn(
                          label: 'Sales',
                          value: '$salesCount',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.border,
                        ),
                        _StatColumn(
                          label: 'Balance',
                          value: '${walletState.balance}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Upload CTA button
                  GlassButton(
                    label: 'Upload Item',
                    icon: Icons.add_photo_alternate_outlined,
                    onPressed: () => context.push('/upload'),
                    width: double.infinity,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Switch User button
                  GlassButton(
                    label: 'Switch User',
                    variant: GlassButtonVariant.outline,
                    icon: Icons.swap_horiz_rounded,
                    onPressed: () =>
                        ref.read(authProvider.notifier).logout(),
                    width: double.infinity,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Liked Items header
                  Row(
                    children: [
                      Text(
                        'Liked Items',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontLg,
                          fontWeight: FontWeight.w700,
                          letterSpacing: AppTypography.letterSpacingTitle,
                        ),
                      ),
                      const Spacer(),
                      if (likedItems.isNotEmpty)
                        GestureDetector(
                          onTap: () => context.push('/saved'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'See all ${likedItems.length}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.primary,
                                    fontSize: AppTypography.fontXs,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.primary,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),

            // Liked items preview grid (max 4)
            if (likedItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenPaddingH,
                ),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Center(
                    child: Text(
                      'No liked items yet — swipe right or tap the heart!',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textTertiary,
                        fontSize: AppTypography.fontSm,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenPaddingH,
                ),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppLayout.matchGridGap,
                        crossAxisSpacing: AppLayout.matchGridGap,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: likedItems.length.clamp(0, 4),
                      itemBuilder: (context, index) {
                        final item = likedItems[index];
                        final owner = MockApi.getUserById(item.ownerId);
                        return _LikedItemCard(
                          item: item,
                          ownerName: owner?.displayName ?? 'Unknown',
                          onTap: () => context.push('/item/${item.id}'),
                          onRemove: () => ref
                              .read(likesProvider.notifier)
                              .removeItem(item.id),
                        );
                      },
                    ),
                    if (likedItems.length > 4) ...[
                      const SizedBox(height: AppSpacing.md),
                      GestureDetector(
                        onTap: () => context.push('/saved'),
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View all ${likedItems.length} liked items',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.primary,
                                    fontSize: AppTypography.fontSm,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.xxl),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenPaddingH,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Orders header
                  Row(
                    children: [
                      Text(
                        'Orders',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontLg,
                          fontWeight: FontWeight.w700,
                          letterSpacing: AppTypography.letterSpacingTitle,
                        ),
                      ),
                      const Spacer(),
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
                        child: Text(
                          '${allOrders.length} orders',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: AppTypography.fontXs,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Orders list
            if (allOrders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenPaddingH,
                ),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      'No orders yet',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textTertiary,
                        fontSize: AppTypography.fontSm,
                      ),
                    ),
                  ),
                ),
              )
            else
              ...allOrders.map((od) => _OrderTile(
                    orderDetail: od,
                    onTap: () => context.push('/chat/${od.order.id}'),
                  )),

            const SizedBox(height: AppSpacing.xxl),

            // My items header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenPaddingH,
              ),
              child: Row(
                children: [
                  Text(
                    'My Items',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: AppTypography.fontLg,
                      fontWeight: FontWeight.w700,
                      letterSpacing: AppTypography.letterSpacingTitle,
                    ),
                  ),
                  const Spacer(),
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
                    child: Text(
                      '${myItems.length} items',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: AppTypography.fontXs,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Items grid
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenPaddingH,
              ),
              child: myItems.isEmpty
                  ? _EmptyItems()
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppLayout.matchGridGap,
                        crossAxisSpacing: AppLayout.matchGridGap,
                        childAspectRatio: 0.74,
                      ),
                      itemCount: myItems.length,
                      itemBuilder: (context, index) {
                        final item = myItems[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadius.xxl),
                            boxShadow: AppShadows.md,
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.xxl),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
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
                                // Scrim gradient
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
                                    child: Text(
                                      item.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.white,
                                        fontSize: AppTypography.fontSm,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                // Type badge top-left
                                Positioned(
                                  top: AppSpacing.sm,
                                  left: AppSpacing.sm,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassBackground,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.full),
                                      border: Border.all(
                                        color: AppColors.glassBorderLight,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      item.clothingType.icon,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Transaction history
            if (walletState.transactions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenPaddingH,
                ),
                child: Row(
                  children: [
                    Text(
                      'Transaction History',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: AppTypography.fontLg,
                        fontWeight: FontWeight.w700,
                        letterSpacing: AppTypography.letterSpacingTitle,
                      ),
                    ),
                    const Spacer(),
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
                      child: Text(
                        '${walletState.transactions.length} transactions',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: AppTypography.fontXs,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...walletState.transactions.reversed.map((txn) => _TransactionTile(transaction: txn)),
            ],

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
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
              CachedNetworkImage(
                imageUrl: item.images.first,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceSecondary),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceSecondary,
                  child: const Icon(Icons.image_outlined,
                      color: AppColors.textTertiary),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: AppGradients.cardScrim),
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
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${item.priceInCoins} SC',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.white,
                      fontSize: AppTypography.fontXs,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.white, size: 16),
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

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount > 0;
    final (IconData icon, Color color) = switch (transaction.type) {
      TransactionType.welcomeBonus => (Icons.card_giftcard_rounded, AppColors.primary),
      TransactionType.purchase => (Icons.shopping_bag_outlined, AppColors.error),
      TransactionType.sale => (Icons.sell_outlined, AppColors.success),
      TransactionType.topup => (Icons.add_circle_outline, AppColors.primary),
    };

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppLayout.screenPaddingH,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: AppTypography.fontSm,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Balance: ${transaction.balanceAfter} SC',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textTertiary,
                    fontSize: AppTypography.fontXs,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${transaction.amount}',
            style: GoogleFonts.plusJakartaSans(
              color: isPositive ? AppColors.success : AppColors.error,
              fontSize: AppTypography.fontMd,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontXl,
            fontWeight: FontWeight.bold,
            letterSpacing: AppTypography.letterSpacingTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: AppTypography.fontSm,
          ),
        ),
      ],
    );
  }
}

class _EmptyItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 26,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No items yet',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Upload your first item to start selling',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary,
                  fontSize: AppTypography.fontXs,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderDetail orderDetail;
  final VoidCallback onTap;

  const _OrderTile({required this.orderDetail, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (orderDetail.order.status) {
      OrderStatus.pending => AppColors.warning,
      OrderStatus.confirmed => AppColors.primary,
      OrderStatus.completed => AppColors.success,
      OrderStatus.cancelled => AppColors.error,
    };
    final statusLabel = switch (orderDetail.order.status) {
      OrderStatus.pending => 'Pending',
      OrderStatus.confirmed => 'Confirmed',
      OrderStatus.completed => 'Completed',
      OrderStatus.cancelled => 'Cancelled',
    };

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.04),
        highlightColor: AppColors.primary.withValues(alpha: 0.02),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.screenPaddingH,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Item thumbnail
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.sm,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: CachedNetworkImage(
                    imageUrl: orderDetail.item.images.first,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceSecondary,
                      child: const Icon(Icons.image_outlined,
                          size: 16, color: AppColors.textTertiary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderDetail.item.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: AppTypography.fontSm,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          orderDetail.isBuyer ? 'Bought' : 'Sold',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: AppTypography.fontXs,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs),
                          child: Text(
                            '\u2022',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: AppTypography.fontXs,
                            ),
                          ),
                        ),
                        Text(
                          '${orderDetail.order.priceInCoins} SC',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontSize: AppTypography.fontXs,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            statusLabel,
                            style: GoogleFonts.plusJakartaSans(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
