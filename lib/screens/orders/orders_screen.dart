import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/orders_provider.dart';
import '../../providers/review_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/empty_state.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(ordersProvider);
    final ongoing = allOrders
        .where((o) =>
            o.order.status == OrderStatus.pending ||
            o.order.status == OrderStatus.confirmed)
        .toList();
    final completed = allOrders
        .where((o) => o.order.status == OrderStatus.completed)
        .toList();

    return SafeArea(
      bottom: false,
      child: DefaultTabController(
        length: 2,
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
              child: Text(
                'My Orders',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: AppTypography.font2xl,
                  fontWeight: FontWeight.bold,
                  letterSpacing: AppTypography.letterSpacingTitle,
                ),
              ),
            ),

            // Tab bar — Ongoing / Completed toggle
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenPaddingH,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.sm,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.fontSm,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.fontSm,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.all(4),
                tabs: [
                  Tab(text: 'Ongoing (${ongoing.length})'),
                  Tab(text: 'Completed (${completed.length})'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tab views
            Expanded(
              child: TabBarView(
                children: [
                  _OngoingList(orders: ongoing),
                  _CompletedList(orders: completed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ongoing Orders Tab ───

class _OngoingList extends StatelessWidget {
  final List<OrderDetail> orders;

  const _OngoingList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'No ongoing orders',
        subtitle: 'When you buy or sell items, active orders will appear here.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        left: AppLayout.screenPaddingH,
        right: AppLayout.screenPaddingH,
        bottom: AppLayout.tabBarHeight + AppSpacing.lg,
      ),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final detail = orders[index];
        return _OngoingOrderCard(orderDetail: detail);
      },
    );
  }
}

class _OngoingOrderCard extends StatelessWidget {
  final OrderDetail orderDetail;

  const _OngoingOrderCard({required this.orderDetail});

  @override
  Widget build(BuildContext context) {
    final order = orderDetail.order;
    final item = orderDetail.item;
    final dateStr = DateFormat('MMM d, yyyy').format(order.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item thumbnail
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: AppShadows.sm,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: CachedNetworkImage(
                      imageUrl: item.images.first,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceSecondary,
                        child: const Icon(Icons.image_outlined,
                            size: 24, color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontMd,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (item.brand != null)
                        Text(
                          item.brand!,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: AppTypography.fontSm,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        dateStr,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textTertiary,
                          fontSize: AppTypography.fontXs,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge + price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusBadge(status: order.status),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${order.priceInCoins} SC',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontSize: AppTypography.fontMd,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Track Order button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/orders/${order.id}/track');
                },
                icon: const Icon(Icons.route_outlined, size: 18),
                label: const Text('Track Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: AppTypography.fontSm,
                    fontWeight: FontWeight.w600,
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

// ─── Completed Orders Tab ───

class _CompletedList extends ConsumerWidget {
  final List<OrderDetail> orders;

  const _CompletedList({required this.orders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No completed orders yet',
        subtitle:
            'Once your orders are fulfilled, they will show up here.',
      );
    }

    final reviewsState = ref.watch(reviewsProvider);

    return ListView.separated(
      padding: EdgeInsets.only(
        left: AppLayout.screenPaddingH,
        right: AppLayout.screenPaddingH,
        bottom: AppLayout.tabBarHeight + AppSpacing.lg,
      ),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final detail = orders[index];
        final hasReview = reviewsState.reviews
            .any((r) => r.orderId == detail.order.id);
        return _CompletedOrderCard(
          orderDetail: detail,
          hasReview: hasReview,
        );
      },
    );
  }
}

class _CompletedOrderCard extends StatelessWidget {
  final OrderDetail orderDetail;
  final bool hasReview;

  const _CompletedOrderCard({
    required this.orderDetail,
    required this.hasReview,
  });

  @override
  Widget build(BuildContext context) {
    final order = orderDetail.order;
    final item = orderDetail.item;
    final dateStr = DateFormat('MMM d, yyyy').format(order.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item thumbnail
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: AppShadows.sm,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: CachedNetworkImage(
                      imageUrl: item.images.first,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceSecondary,
                        child: const Icon(Icons.image_outlined,
                            size: 24, color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontMd,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (item.brand != null)
                        Text(
                          item.brand!,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: AppTypography.fontSm,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        dateStr,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textTertiary,
                          fontSize: AppTypography.fontXs,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusBadge(status: order.status),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${order.priceInCoins} SC',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontSize: AppTypography.fontMd,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Leave Review or Reviewed indicator
            if (!hasReview && orderDetail.isBuyer)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      '/orders/${order.id}/review',
                      extra: orderDetail,
                    );
                  },
                  icon: const Icon(Icons.star_outline_rounded, size: 18),
                  label: const Text('Leave Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: AppTypography.fontSm,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else if (hasReview)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Review submitted',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.success,
                      fontSize: AppTypography.fontSm,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Status Badge ───

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      OrderStatus.pending => (
          AppColors.warning.withValues(alpha: 0.15),
          AppColors.warning,
          'Pending',
        ),
      OrderStatus.confirmed => (
          const Color(0xFFE0F0FF),
          const Color(0xFF2B7FE0),
          'Confirmed',
        ),
      OrderStatus.completed => (
          AppColors.success.withValues(alpha: 0.15),
          AppColors.success,
          'Completed',
        ),
      OrderStatus.cancelled => (
          AppColors.error.withValues(alpha: 0.15),
          AppColors.error,
          'Cancelled',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
