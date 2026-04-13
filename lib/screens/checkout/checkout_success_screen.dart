import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/cart_provider.dart';
import '../../services/supabase_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/glass_button.dart';

class CheckoutSuccessScreen extends ConsumerStatefulWidget {
  final List<ClothingItem> items;
  final int totalCoins;
  final String orderId;
  final String? sellerId;

  const CheckoutSuccessScreen({
    super.key,
    required this.items,
    required this.totalCoins,
    required this.orderId,
    this.sellerId,
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
  List<ClothingItem> _sellerItems = [];
  bool _loadingSeller = false;

  @override
  void initState() {
    super.initState();

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
    _loadSellerItems();
  }

  Future<void> _loadSellerItems() async {
    // Collect all unique seller IDs
    final sellerIds = <String>{};
    if (widget.sellerId != null) {
      sellerIds.add(widget.sellerId!);
    }
    for (final item in widget.items) {
      sellerIds.add(item.ownerId);
    }
    if (sellerIds.isEmpty) return;

    setState(() => _loadingSeller = true);
    try {
      final purchasedIds = widget.items.map((i) => i.id).toSet();
      final data = await supabase
          .from('clothing_items')
          .select('*, owner:profiles!clothing_items_owner_id_fkey(*)')
          .inFilter('owner_id', sellerIds.toList())
          .eq('is_active', true)
          .limit(10);
      final items = (data as List)
          .map((e) => ClothingItem.fromJson(e))
          .where((i) => !purchasedIds.contains(i.id))
          .toList();
      if (mounted) setState(() => _sellerItems = items);
    } catch (_) {
      // Non-critical
    } finally {
      if (mounted) setState(() => _loadingSeller = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxxl),

                    // Animated checkmark
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: AppColors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Order Confirmed!',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textPrimary,
                              fontSize: AppTypography.font2xl,
                              fontWeight: FontWeight.bold,
                              letterSpacing: AppTypography.letterSpacingTitle,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Your Style Coins have been transferred.\nChat with the seller to arrange pickup.',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondary,
                              fontSize: AppTypography.fontSm,
                              height: AppTypography.lineHeightRelaxed,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Order details card
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _OrderDetailsCard(
                        items: widget.items,
                        totalCoins: widget.totalCoins,
                        orderId: widget.orderId,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // More from seller
                    if (_sellerItems.isNotEmpty)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _MoreFromSeller(
                          items: _sellerItems,
                          onItemTap: (itemId) => context.push('/item/$itemId'),
                        ),
                      ),

                    if (_loadingSeller)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.lg,
                bottom: bottomPadding + AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.borderLight, width: 0.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order details card with item images, names, prices, and order ID
// ---------------------------------------------------------------------------

class _OrderDetailsCard extends StatelessWidget {
  final List<ClothingItem> items;
  final int totalCoins;
  final String orderId;

  const _OrderDetailsCard({
    required this.items,
    required this.totalCoins,
    required this.orderId,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Details',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: AppTypography.fontMd,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Confirmed',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.success,
                    fontSize: AppTypography.fontXs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Order ID
          Text(
            'Order #${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textTertiary,
              fontSize: AppTypography.fontXs,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Item rows with images
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    // Item thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: item.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.images.first,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 56,
                                height: 56,
                                color: AppColors.surfaceContainerHigh,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 56,
                                height: 56,
                                color: AppColors.surfaceContainerHigh,
                                child: const Icon(Icons.image_outlined,
                                    color: AppColors.textTertiary, size: 18),
                              ),
                            )
                          : Container(
                              width: 56,
                              height: 56,
                              color: AppColors.surfaceContainerHigh,
                              child: const Icon(Icons.image_outlined,
                                  color: AppColors.textTertiary, size: 18),
                            ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Item info
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
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (item.brand != null) item.brand!,
                              item.displaySize,
                              item.condition,
                            ].join(' \u2022 '),
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textTertiary,
                              fontSize: AppTypography.fontXs,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Price
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
              )),

          // Divider
          Container(
            height: 1,
            color: AppColors.surfaceContainerHigh,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Paid',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: AppTypography.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'SC',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '$totalCoins',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontSize: AppTypography.fontLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// More from this seller — horizontal scroll
// ---------------------------------------------------------------------------

class _MoreFromSeller extends StatelessWidget {
  final List<ClothingItem> items;
  final void Function(String itemId) onItemTap;

  const _MoreFromSeller({
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final sellerName = items.first.owner?.displayName ?? 'this seller';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More from $sellerName',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontMd,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => onItemTap(item.id),
                child: SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: item.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.images.first,
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 140,
                                  height: 140,
                                  color: AppColors.surfaceContainerHigh,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 140,
                                  height: 140,
                                  color: AppColors.surfaceContainerHigh,
                                  child: const Icon(Icons.image_outlined,
                                      color: AppColors.textTertiary),
                                ),
                              )
                            : Container(
                                width: 140,
                                height: 140,
                                color: AppColors.surfaceContainerHigh,
                                child: const Icon(Icons.image_outlined,
                                    color: AppColors.textTertiary),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Title
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontXs,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Price
                      Text(
                        '${item.priceInCoins} SC',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontSize: AppTypography.fontXs,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
