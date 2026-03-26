import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/tokens.dart';

class SwipeCard extends StatefulWidget {
  final ClothingItem item;
  final User owner;
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

            // Price badge — top right
            Positioned(
              top: _imageCount > 1
                  ? AppSpacing.lg + AppSpacing.md
                  : AppSpacing.lg,
              right: AppSpacing.lg,
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
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
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.priceInCoins}',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.white,
                            fontSize: AppTypography.fontLg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: AppColors.glassBorderLight,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      item.clothingType.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.white,
                        fontSize: AppTypography.fontXl,
                        fontWeight: FontWeight.bold,
                        letterSpacing: AppTypography.letterSpacingTitle,
                        height: AppTypography.lineHeightTight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Info chips row
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (item.brand != null)
                          _GlassChip(label: item.brand!),
                        _GlassChip(label: item.displaySize),
                        _GlassChip(label: item.condition),
                        if (item.color != null)
                          _GlassChip(label: item.color!),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Owner row
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.glassBorderLight,
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: owner.avatarUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: owner.avatarUrl!,
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        _AvatarFallback(),
                                  )
                                : _AvatarFallback(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          owner.displayName,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.white.withValues(alpha: 0.85),
                            fontSize: AppTypography.fontSm,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (owner.city != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs),
                            child: Text(
                              '\u2022',
                              style: TextStyle(
                                color:
                                    AppColors.white.withValues(alpha: 0.5),
                                fontSize: AppTypography.fontXs,
                              ),
                            ),
                          ),
                          Text(
                            owner.city!,
                            style: GoogleFonts.plusJakartaSans(
                              color:
                                  AppColors.white.withValues(alpha: 0.6),
                              fontSize: AppTypography.fontXs,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
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

class _GlassChip extends StatelessWidget {
  final String label;

  const _GlassChip({required this.label});

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
            horizontal: AppSpacing.sm,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: AppColors.glassBorderLight,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.white,
              fontSize: AppTypography.fontXs,
              fontWeight: FontWeight.w500,
            ),
          ),
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
