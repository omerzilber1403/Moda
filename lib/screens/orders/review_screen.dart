import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/review_provider.dart';
import '../../theme/tokens.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final OrderDetail orderDetail;

  const ReviewScreen({super.key, required this.orderDetail});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _rating = 0;
  bool _submitting = false;
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0 || _submitting) return;

    setState(() => _submitting = true);

    bool success = false;
    try {
      success = await ref.read(reviewsProvider.notifier).addReview(
            orderId: widget.orderDetail.order.id,
            revieweeId: widget.orderDetail.otherUser.id,
            itemId: widget.orderDetail.item.id,
            rating: _rating,
            comment: _commentCtrl.text.trim(),
          );
    } catch (_) {
      success = false;
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.orderDetail.item;
    final seller = widget.orderDetail.otherUser;
    final isDisabled = _rating == 0 || _submitting;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Leave a Review',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontLg,
            fontWeight: FontWeight.w700,
            letterSpacing: AppTypography.letterSpacingTitle,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppLayout.screenPaddingH,
          AppSpacing.xl,
          AppLayout.screenPaddingH,
          AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Section 1: Item + Seller card ─────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  // Item image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: CachedNetworkImage(
                      imageUrl: item.images.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.surfaceContainerHigh,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.outline,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
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
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        if (item.brand != null)
                          Text(
                            item.brand!,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondary,
                              fontSize: AppTypography.fontXs,
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              backgroundImage: seller.avatarUrl != null
                                  ? CachedNetworkImageProvider(
                                      seller.avatarUrl!)
                                  : null,
                              child: seller.avatarUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: AppColors.outline,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'Sold by ${seller.displayName}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textSecondary,
                                  fontSize: AppTypography.fontXs,
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

            // ── Section 2: Star rating ─────────────────────────
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Rate your experience',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontMd,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Icon(
                      Icons.star_rounded,
                      size: 44,
                      color: starIndex <= _rating
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                    ),
                  ),
                );
              }),
            ),

            // ── Section 3: Comment field ───────────────────────
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Your review',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: AppTypography.fontSm,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _commentCtrl,
              minLines: 3,
              maxLines: 6,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontSm,
              ),
              decoration: InputDecoration(
                hintText: 'Quality, packaging, communication\u2026',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: AppColors.outline,
                  fontSize: AppTypography.fontSm,
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),

            // ── Section 4: Submit button ───────────────────────
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: isDisabled ? null : _submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                decoration: BoxDecoration(
                  gradient: isDisabled
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: isDisabled ? AppColors.surfaceContainerHigh : null,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: isDisabled ? null : AppShadows.md,
                ),
                child: Center(
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'Submit Review',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDisabled
                                ? AppColors.outline
                                : AppColors.onPrimary,
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
    );
  }
}
