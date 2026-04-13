import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/likes_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/shop_provider.dart';
import '../../services/supabase_service.dart';
import '../../theme/tokens.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  ClothingItem? _item;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    try {
      final data = await supabase
          .from('clothing_items')
          .select('*, owner:profiles!clothing_items_owner_id_fkey(*)')
          .eq('id', widget.itemId)
          .single();
      if (mounted) {
        setState(() {
          _item = ClothingItem.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase();
        String? error;
        if (msg.contains('network') || msg.contains('socket') || msg.contains('connection') || msg.contains('failed host lookup')) {
          error = 'Connection error. Check your internet and try again.';
        }
        // If no specific network error, _item stays null -> shows "not found"
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final item = _item;
    if (item == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _CircleButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _errorMessage != null
                      ? _ErrorMessage(
                          message: _errorMessage!,
                          onRetry: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _loadItem();
                          },
                        )
                      : const _NotFoundMessage(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _ItemDetailBody(item: item, owner: item.owner),
    );
  }
}

class _NotFoundMessage extends StatelessWidget {
  const _NotFoundMessage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 56,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Item not found',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontLg,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'This item may have been removed.',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: AppTypography.fontSm,
          ),
        ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.wifi_off_rounded,
          size: 56,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Oops!',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontLg,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: AppTypography.fontSm,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.white,
                fontSize: AppTypography.fontSm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemDetailBody extends ConsumerStatefulWidget {
  final ClothingItem item;
  final AppUserRef? owner;

  const _ItemDetailBody({required this.item, this.owner});

  @override
  ConsumerState<_ItemDetailBody> createState() => _ItemDetailBodyState();
}

class _ItemDetailBodyState extends ConsumerState<_ItemDetailBody> {
  final PageController _pageController = PageController();
  int _currentImagePage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page >= widget.item.images.length) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final likedItems = ref.watch(likesProvider);
    final isLiked = likedItems.any((i) => i.id == widget.item.id);
    final walletState = ref.watch(walletProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              _ImageSection(
                images: widget.item.images,
                pageController: _pageController,
                currentPage: _currentImagePage,
                onPageChanged: (page) {
                  setState(() => _currentImagePage = page);
                },
                onTapLeft: () => _goToPage(_currentImagePage - 1),
                onTapRight: () => _goToPage(_currentImagePage + 1),
              ),

              // Content section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenPaddingH,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // Brand name (prominent subtitle)
                    if (widget.item.brand != null) ...[
                      Text(
                        widget.item.brand!.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontSize: AppTypography.fontXs,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],

                    // Title
                    Text(
                      widget.item.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: AppTypography.font2xl,
                        fontWeight: FontWeight.bold,
                        letterSpacing: AppTypography.letterSpacingTitle,
                        height: AppTypography.lineHeightTight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Info chips
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _InfoChip(
                          label: widget.item.displaySize,
                          icon: Icons.straighten_rounded,
                        ),
                        _InfoChip(
                          label: widget.item.condition,
                          icon: Icons.verified_outlined,
                        ),
                        if (widget.item.color != null)
                          _InfoChip(
                            label: widget.item.color!,
                            icon: Icons.palette_outlined,
                          ),
                        _InfoChip(
                          label: widget.item.clothingType.label,
                          icon: Icons.checkroom_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Description
                    if (widget.item.description != null) ...[
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
                        widget.item.description!,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: AppTypography.fontSm,
                          height: AppTypography.lineHeightRelaxed,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // Details grid
                    _DetailsSection(item: widget.item),
                    const SizedBox(height: AppSpacing.xl),

                    // Seller row
                    if (widget.owner != null) ...[
                      Text(
                        'Seller',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontMd,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GestureDetector(
                        onTap: () => context.push('/seller/${widget.owner!.id}'),
                        child: _SellerRow(owner: widget.owner!),
                      ),
                    ],

                    // Bottom padding to clear the sticky CTA bar
                    SizedBox(height: bottomPadding + 100 + AppSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Sticky bottom CTA bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _StickyBottomBar(
            priceInCoins: widget.item.priceInCoins,
            isLiked: isLiked,
            isLoading: walletState.isLoading,
            onToggleLike: () => _toggleLike(isLiked),
            onBuy: () => _handleBuyNow(context),
            bottomPadding: bottomPadding,
          ),
        ),
      ],
    );
  }

  void _toggleLike(bool isLiked) {
    if (isLiked) {
      ref.read(likesProvider.notifier).removeItem(widget.item.id);
    } else {
      ref.read(likesProvider.notifier).likeItem(widget.item.id);
    }
  }

  void _handleBuyNow(BuildContext context) {
    context.push('/confirm-order', extra: {'item': widget.item});
  }
}

// ---------------------------------------------------------------------------
// Image section with tap zones and progress bars
// ---------------------------------------------------------------------------

class _ImageSection extends StatelessWidget {
  final List<String> images;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;

  const _ImageSection({
    required this.images,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTapLeft,
    required this.onTapRight,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final imageHeight = mediaQuery.size.height * 0.55;

    return SizedBox(
      height: imageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image(s)
          if (images.length > 1)
            PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemCount: images.length,
              itemBuilder: (context, index) => _ItemImage(url: images[index]),
            )
          else
            _ItemImage(url: images.isNotEmpty ? images.first : ''),

          // Tap zones for left/right navigation (only for multiple images)
          if (images.length > 1) ...[
            // Left tap zone
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: mediaQuery.size.width * 0.3,
              child: GestureDetector(
                onTap: onTapLeft,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            // Right tap zone
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: mediaQuery.size.width * 0.3,
              child: GestureDetector(
                onTap: onTapRight,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
          ],

          // Progress bars at top (Tinder-style)
          if (images.length > 1)
            Positioned(
              top: mediaQuery.padding.top + AppSpacing.sm,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: _ProgressBars(
                total: images.length,
                current: currentPage,
              ),
            ),

          // Bottom gradient scrim for buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mediaQuery.padding.top + 70,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: mediaQuery.padding.top + AppSpacing.sm +
                (images.length > 1 ? AppSpacing.xl : 0),
            left: AppSpacing.lg,
            child: _CircleButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Share button
          Positioned(
            top: mediaQuery.padding.top + AppSpacing.sm +
                (images.length > 1 ? AppSpacing.xl : 0),
            right: AppSpacing.lg,
            child: _CircleButton(
              icon: Icons.ios_share_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Share link copied!',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.white),
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tinder-style progress bars
// ---------------------------------------------------------------------------

class _ProgressBars extends StatelessWidget {
  final int total;
  final int current;

  const _ProgressBars({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < total - 1 ? AppSpacing.xs : 0,
            ),
            height: 3,
            decoration: BoxDecoration(
              color: index <= current
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
        );
      }),
    );
  }
}

class _ItemImage extends StatelessWidget {
  final String url;

  const _ItemImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        color: AppColors.surfaceSecondary,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            color: AppColors.textTertiary,
            size: 48,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: AppColors.surfaceSecondary,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surfaceSecondary,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            color: AppColors.textTertiary,
            size: 48,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Circle button (back / share)
// ---------------------------------------------------------------------------

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppGlass.blur,
            sigmaY: AppGlass.blur,
          ),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.glassBackgroundDark,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.glassBorderSubtle,
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info chip — modern pill style with icon
// ---------------------------------------------------------------------------

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _InfoChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
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
// Details section — two-column grid of label:value pairs
// ---------------------------------------------------------------------------

class _DetailsSection extends ConsumerWidget {
  final ClothingItem item;

  const _DetailsSection({required this.item});

  String _formatListedDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
    // Fallback to formatted date
    final month = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  String _formatAttributeKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : w)
        .join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(shopProvider).categories;
    final category = categories.where((c) => c.id == item.categoryId).firstOrNull;

    // Build the list of detail entries
    final List<MapEntry<String, String>> details = [];

    if (category != null) {
      details.add(MapEntry('Category', category.name));
    }

    details.add(MapEntry('Listed', _formatListedDate(item.createdAt)));

    details.add(MapEntry('Size', item.displaySize));

    details.add(MapEntry('Condition', item.condition));

    if (item.color != null) {
      details.add(MapEntry('Color', item.color!));
    }

    // Add any extra attributes from the map
    for (final entry in item.attributes.entries) {
      // Skip shoe_size if already shown via displaySize
      if (entry.key == 'shoe_size') continue;
      details.add(MapEntry(
        _formatAttributeKey(entry.key),
        entry.value.toString(),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < details.length; i += 2)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i + 2 < details.length ? AppSpacing.md : 0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DetailPair(
                          label: details[i].key,
                          value: details[i].value,
                        ),
                      ),
                      if (i + 1 < details.length)
                        Expanded(
                          child: _DetailPair(
                            label: details[i + 1].key,
                            value: details[i + 1].value,
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailPair extends StatelessWidget {
  final String label;
  final String value;

  const _DetailPair({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textTertiary,
            fontSize: AppTypography.fontXs,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontSm,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Seller row
// ---------------------------------------------------------------------------

class _SellerRow extends StatelessWidget {
  final AppUserRef owner;

  const _SellerRow({required this.owner});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderLight,
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: owner.avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: owner.avatarUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 40,
                        height: 40,
                        color: AppColors.gray100,
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: AppColors.gray400,
                        ),
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      color: AppColors.gray100,
                      child: const Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.gray400,
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
                  owner.displayName,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: AppTypography.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (owner.city != null)
                  Text(
                    owner.city!,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textTertiary,
                      fontSize: AppTypography.fontXs,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky bottom CTA bar — glassmorphic
// ---------------------------------------------------------------------------

class _StickyBottomBar extends StatelessWidget {
  final int priceInCoins;
  final bool isLiked;
  final bool isLoading;
  final VoidCallback onToggleLike;
  final VoidCallback onBuy;
  final double bottomPadding;

  const _StickyBottomBar({
    required this.priceInCoins,
    required this.isLiked,
    required this.isLoading,
    required this.onToggleLike,
    required this.onBuy,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppGlass.blurIntense,
          sigmaY: AppGlass.blurIntense,
        ),
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
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withValues(alpha: 0.06),
                offset: const Offset(0, -4),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            children: [
              // Price on the left
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textTertiary,
                      fontSize: AppTypography.fontXs,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'SC',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primary,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$priceInCoins',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontXl,
                          fontWeight: FontWeight.bold,
                          letterSpacing: AppTypography.letterSpacingTight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Wishlist heart icon
              GestureDetector(
                onTap: onToggleLike,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLiked
                        ? AppColors.primaryLight
                        : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isLiked ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isLiked ? AppColors.primary : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Buy button
              GestureDetector(
                onTap: isLoading ? null : onBuy,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.md,
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.white,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Buy Now',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.white,
                                  fontSize: AppTypography.fontMd,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: AppTypography.letterSpacingBody,
                                ),
                              ),
                            ],
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
