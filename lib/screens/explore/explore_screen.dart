import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/browse_provider.dart';
import '../../providers/likes_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/shop_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/swipe_card.dart';
import '../profile/buy_coins_sheet.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final CardSwiperController _swiperController = CardSwiperController();
  int _currentTopCardIndex = 0;
  late final AnimationController _heartController;
  late final Animation<double> _heartOpacity;
  late final Animation<Offset> _heartSlide;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _heartOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_heartController);
    _heartSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: const Offset(0, 0.3),
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeOut,
    ));
  }

  void _triggerHeartAnimation() {
    _heartController.forward(from: 0);
  }

  @override
  void dispose() {
    _heartController.dispose();
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final browseState = ref.watch(browseProvider);
    final walletState = ref.watch(walletProvider);

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
                  'Explore',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.onSurface,
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

          // Category chips
          const SizedBox(height: AppSpacing.md),
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
                  isSelected: ref.watch(browseProvider).categoryFilter == null,
                  onTap: () =>
                      ref.read(browseProvider.notifier).filterByCategory(null),
                ),
                const SizedBox(width: AppSpacing.sm),
                ...ref.watch(shopProvider).categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: _CategoryChip(
                        label: '${cat.icon ?? ''} ${cat.name}',
                        isSelected:
                            ref.watch(browseProvider).categoryFilter == cat.id,
                        onTap: () => ref
                            .read(browseProvider.notifier)
                            .filterByCategory(cat.id),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Swipe deck with overlaid action buttons
          Expanded(
            child: browseState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : browseState.items.isEmpty
                    ? _EmptyState()
                    : Stack(
                        children: [
                          // Card swiper — reduced horizontal padding
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.sm,
                                0,
                                AppSpacing.sm,
                                AppLayout.tabBarHeight,
                              ),
                              child: CardSwiper(
                                controller: _swiperController,
                                cardsCount: browseState.items.length,
                                numberOfCardsDisplayed:
                                    browseState.items.length.clamp(1, 3),
                                backCardOffset: const Offset(0, -30),
                                scale: 0.92,
                                padding: EdgeInsets.zero,
                                isLoop: false,
                                allowedSwipeDirection:
                                    const AllowedSwipeDirection.symmetric(
                                  horizontal: true,
                                  vertical: false,
                                ),
                                onSwipe:
                                    (prevIndex, currentIndex, direction) {
                                  final item = browseState.items[prevIndex];
                                  if (direction ==
                                      CardSwiperDirection.right) {
                                    ref
                                        .read(likesProvider.notifier)
                                        .likeItem(item.id);
                                    _triggerHeartAnimation();
                                  }
                                  // Track the new top card index
                                  if (currentIndex != null) {
                                    setState(() {
                                      _currentTopCardIndex = currentIndex;
                                    });
                                  }
                                  return true;
                                },
                                onEnd: () {
                                  // All cards swiped
                                },
                                cardBuilder: (context, index,
                                    percentThresholdX,
                                    percentThresholdY) {
                                  final item = browseState.items[index];
                                  return SwipeCard(
                                    item: item,
                                    owner: item.owner ??
                                        const AppUserRef(
                                          id: '',
                                          displayName: 'Unknown',
                                        ),
                                    onCenterTap: () {
                                      context.push('/item/${item.id}');
                                    },
                                  );
                                },
                              ),
                            ),
                          ),

                          // Flying heart animation
                          Positioned(
                            top: AppSpacing.xl,
                            left: 0,
                            right: 0,
                            child: SlideTransition(
                              position: _heartSlide,
                              child: FadeTransition(
                                opacity: _heartOpacity,
                                child: Center(
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: AppColors.likeGreen
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite_rounded,
                                      color: AppColors.likeGreen,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Floating glassmorphic action buttons
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: AppLayout.tabBarHeight + AppSpacing.xl,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                // Skip button
                                _GlassActionButton(
                                  icon: Icons.close_rounded,
                                  iconColor: AppColors.onSurfaceVariant,
                                  size: 64,
                                  onTap: () => _swiperController
                                      .swipe(CardSwiperDirection.left),
                                ),
                                const SizedBox(width: AppSpacing.xl),

                                // Info button
                                _GlassActionButton(
                                  icon: Icons.info_outline_rounded,
                                  iconColor: AppColors.tertiary,
                                  size: 48,
                                  onTap: () {
                                    if (browseState.items.isNotEmpty &&
                                        _currentTopCardIndex <
                                            browseState.items.length) {
                                      final item = browseState
                                          .items[_currentTopCardIndex];
                                      context.push('/item/${item.id}');
                                    }
                                  },
                                ),
                                const SizedBox(width: AppSpacing.xl),

                                // Like button
                                _GlassActionButton(
                                  icon: Icons.favorite_rounded,
                                  iconColor: AppColors.primary,
                                  size: 64,
                                  onTap: () => _swiperController
                                      .swipe(CardSwiperDirection.right),
                                ),
                              ],
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

class _GlassActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final VoidCallback onTap;

  const _GlassActionButton({
    required this.icon,
    required this.iconColor,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppGlass.blur,
            sigmaY: AppGlass.blur,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.glassBackgroundLight,
              shape: BoxShape.circle,
              boxShadow: AppShadows.lg,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: size * 0.42,
            ),
          ),
        ),
      ),
    );
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
                Icons.checkroom_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No more items',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Check back later for new listings!',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: AppTypography.fontSm,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
