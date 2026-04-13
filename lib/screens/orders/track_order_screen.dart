import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/orders_provider.dart';
import '../../theme/tokens.dart';

class TrackOrderScreen extends ConsumerWidget {
  final String orderId;

  const TrackOrderScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(ordersProvider);
    final orderDetail = allOrders.where((o) => o.order.id == orderId).firstOrNull;

    if (orderDetail == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text('Order not found'),
        ),
      );
    }

    final order = orderDetail.order;
    final item = orderDetail.item;
    final steps = _buildSteps(order);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.screenPaddingH,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order info card
            _OrderInfoCard(order: order, item: item),
            const SizedBox(height: AppSpacing.xl),

            // Timeline header
            Text(
              'Order Status',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontLg,
                fontWeight: FontWeight.bold,
                letterSpacing: AppTypography.letterSpacingTitle,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Vertical stepper timeline
            _OrderTimeline(steps: steps),
            const SizedBox(height: AppSpacing.xxl),

            // Chat with Seller button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/chat/${order.id}');
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                label: Text(
                  orderDetail.isBuyer
                      ? 'Chat with Seller'
                      : 'Chat with Buyer',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: AppTypography.fontMd,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Track Order',
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary,
          fontSize: AppTypography.fontLg,
          fontWeight: FontWeight.bold,
          letterSpacing: AppTypography.letterSpacingTitle,
        ),
      ),
      centerTitle: true,
    );
  }

  List<_TimelineStep> _buildSteps(Order order) {
    final createdDate = DateFormat('MMM d, yyyy').format(order.createdAt);
    final confirmedDate = DateFormat('MMM d, yyyy').format(
      order.createdAt.add(const Duration(hours: 1)),
    );
    final notifiedDate = DateFormat('MMM d, yyyy').format(
      order.createdAt.add(const Duration(hours: 2)),
    );

    // Determine current step index based on order status
    final int currentStepIndex = switch (order.status) {
      OrderStatus.pending => 0,
      OrderStatus.confirmed => 3,
      OrderStatus.readyForPickup => 4,
      OrderStatus.completed => 5,
      OrderStatus.cancelled => -1,
    };

    return [
      _TimelineStep(
        icon: Icons.receipt_long_outlined,
        title: 'Order Placed',
        subtitle: createdDate,
        isCompleted: currentStepIndex >= 0,
        isCurrent: currentStepIndex == 0,
      ),
      _TimelineStep(
        icon: Icons.payment_outlined,
        title: 'Payment Confirmed',
        subtitle: currentStepIndex >= 1
            ? 'Style Coins transferred'
            : 'SC will be transferred',
        isCompleted: currentStepIndex >= 1,
        isCurrent: currentStepIndex == 1,
      ),
      _TimelineStep(
        icon: Icons.notifications_active_outlined,
        title: 'Seller Notified',
        subtitle: currentStepIndex >= 2
            ? notifiedDate
            : 'Waiting for notification',
        isCompleted: currentStepIndex >= 2,
        isCurrent: currentStepIndex == 2,
      ),
      _TimelineStep(
        icon: Icons.handshake_outlined,
        title: 'Arrange Meetup',
        subtitle: currentStepIndex >= 3
            ? 'Use chat to coordinate'
            : 'Coordinate via chat',
        isCompleted: currentStepIndex >= 4,
        isCurrent: currentStepIndex == 3,
      ),
      _TimelineStep(
        icon: Icons.check_circle_outline_rounded,
        title: 'Item Received',
        subtitle: currentStepIndex >= 5
            ? 'Order complete'
            : 'Confirm once you have the item',
        isCompleted: currentStepIndex >= 5,
        isCurrent: currentStepIndex == 4,
      ),
    ];
  }
}

// ─── Order Info Card ───

class _OrderInfoCard extends StatelessWidget {
  final Order order;
  final ClothingItem item;

  const _OrderInfoCard({required this.order, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          // Item image
          Container(
            width: 80,
            height: 80,
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
                      size: 28, color: AppColors.textTertiary),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Details
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${order.priceInCoins} Style Coins',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontSize: AppTypography.fontSm,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Order #${order.id.replaceAll('order-', '')}',
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
    );
  }
}

// ─── Timeline ───

class _TimelineStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;

  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
  });
}

class _OrderTimeline extends StatelessWidget {
  final List<_TimelineStep> steps;

  const _OrderTimeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return _TimelineRow(
          step: step,
          isLast: isLast,
        );
      }),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;

  const _TimelineRow({
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconBg;
    final Color iconFg;
    final Color lineColor;

    if (step.isCompleted) {
      iconBg = AppColors.success;
      iconFg = AppColors.white;
      lineColor = AppColors.success;
    } else if (step.isCurrent) {
      iconBg = AppColors.primary;
      iconFg = AppColors.white;
      lineColor = AppColors.border;
    } else {
      iconBg = AppColors.surfaceSecondary;
      iconFg = AppColors.textTertiary;
      lineColor = AppColors.border;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon column with connecting line
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Circle icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    boxShadow: step.isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: step.isCompleted
                      ? const Icon(Icons.check_rounded,
                          size: 18, color: AppColors.white)
                      : Icon(step.icon, size: 18, color: iconFg),
                ),
                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Text content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    step.title,
                    style: GoogleFonts.plusJakartaSans(
                      color: step.isCompleted || step.isCurrent
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontSize: AppTypography.fontMd,
                      fontWeight: step.isCurrent
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: step.isCurrent
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                      fontSize: AppTypography.fontSm,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
