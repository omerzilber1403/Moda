import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/tokens.dart';

class SwipeCard extends StatefulWidget {
  final ClothingItem item;
  final AppUserRef owner;
  final VoidCallback? onCenterTap;

  const SwipeCard({
    super.key,
    required this.item,
    required this.owner,
    this.onCenterTap,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  int _currentImageIndex = 0;

  int get _imageCount => widget.item.images.length;

  void _goToPrevious() {
    if (_currentImageIndex > 0) {
      setState(() => _currentImageIndex--);
    }
  }

  void _goToNext() {
    if (_currentImageIndex < _imageCount - 1) {
      setState(() => _currentImageIndex++);
    }
  }

  @override
  void didUpdateWidget(covariant SwipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _currentImageIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final owner = widget.owner;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
        boxShadow: AppShadows.lg,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full-bleed image with crossfade
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: CachedNetworkImage(
                key: ValueKey('${item.id}_$_currentImageIndex'),
                imageUrl: item.images[_currentImageIndex],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
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
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.textTertiary,
                    size: 48,
                  ),
                ),
              ),
            ),

            // Bottom scrim gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: AppGradients.cardScrim,
                ),
              ),
            ),

            // Image progress bars (Tinder-style)
            if (_imageCount > 1)
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: _ImageProgressBars(
                  count: _imageCount,
                  activeIndex: _currentImageIndex,
                ),
              ),

            // Tap zones for image navigation
            if (_imageCount > 1)
              Positioned.fill(
                child: Row(
                  children: [
                    // Left third — previous image
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _goToPrevious,
                        child: const SizedBox.expand(),
                      ),
                    ),
                    // Center third — open detail
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: widget.onCenterTap,
                        child: const SizedBox.expand(),
                      ),
                    ),
                    // Right third — next image
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _goToNext,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),

            // Single-image: full card tap fires center tap
            if (_imageCount <= 1)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.onCenterTap,
                  child: const SizedBox.expand(),
                ),
              ),

            // Clothing type badge — top left
            Positioned(
              top: _imageCount > 1
                  ? AppSpacing.lg + AppSpacing.md
                  : AppSpacing.lg,
              left: AppSpacing.lg,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: AppGlass.blur,
                    sigmaY: AppGlass.blur,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackgroundLight,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      item.clothingType.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom glassmorphic info panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.xxxl),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground.withValues(alpha: 0.75),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: title + brand + chips
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.brand != null)
                                    Text(
                                      item.brand!.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: AppTypography.fontXs,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.onSurface,
                                      fontSize: AppTypography.fontLg,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: AppTypography.letterSpacingTitle,
                                      height: AppTypography.lineHeightTight,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      _InfoPill(label: item.displaySize),
                                      const SizedBox(width: AppSpacing.xs),
                                      _InfoPill(label: item.condition),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // Right: WANT button + price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // WANT gradient pill button
                                GestureDetector(
                                  onTap: widget.onCenterTap,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                      vertical: AppSpacing.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.primary,
                                      borderRadius: BorderRadius.circular(AppRadius.full),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.35),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'WANT',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.white,
                                        fontSize: AppTypography.fontSm,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                // Price
                                Text(
                                  '${item.priceInCoins} SC',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.primary,
                                    fontSize: AppTypography.fontMd,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image progress bars — thin horizontal indicators (Tinder / Hinge style)
// ---------------------------------------------------------------------------

class _ImageProgressBars extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _ImageProgressBars({
    required this.count,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppGlass.blurLight,
          sigmaY: AppGlass.blurLight,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.glassBackgroundDark.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            children: List.generate(count, (index) {
              final isActive = index == activeIndex;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  height: 3,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 2,
                    right: index == count - 1 ? 0 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _InfoPill extends StatelessWidget {
  final String label;

  const _InfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurfaceVariant,
          fontSize: AppTypography.fontXs,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      color: AppColors.gray100,
      child: const Icon(Icons.person, size: 14, color: AppColors.gray400),
    );
  }
}
