import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/orders_provider.dart';
import '../../theme/tokens.dart';
import '../../utils/helpers.dart';

class ChatUserOrdersScreen extends ConsumerWidget {
  final String userId;

  const ChatUserOrdersScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(ordersProvider);
    final userOrders = allOrders
        .where((o) => o.otherUser.id == userId && o.lastMessage != null)
        .toList()
      ..sort((a, b) =>
          b.lastMessage!.createdAt.compareTo(a.lastMessage!.createdAt));

    final otherUser = userOrders.isNotEmpty ? userOrders.first.otherUser : null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.black,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  if (otherUser?.avatarUrl != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: otherUser!.avatarUrl!,
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.gray100,
                            child: const Icon(Icons.person,
                                size: 18, color: AppColors.gray400),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherUser?.displayName ?? 'User',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textPrimary,
                            fontSize: AppTypography.fontLg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${userOrders.length} item${userOrders.length == 1 ? '' : 's'}',
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
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        itemCount: userOrders.length,
        separatorBuilder: (_, __) => Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppLayout.screenPaddingH,
          ),
          height: 1,
          color: AppColors.borderLight,
        ),
        itemBuilder: (context, index) {
          final od = userOrders[index];
          return _OrderItemTile(
            orderDetail: od,
            onTap: () => context.push('/chat/${od.order.id}'),
          );
        },
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderDetail orderDetail;
  final VoidCallback onTap;

  const _OrderItemTile({required this.orderDetail, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final item = orderDetail.item;
    final hasUnread = orderDetail.unreadCount > 0;
    final lastMsg = orderDetail.lastMessage;

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.04),
        highlightColor: AppColors.primary.withValues(alpha: 0.02),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.screenPaddingH,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item image
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: hasUnread
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.border,
                    width: hasUnread ? 2 : 1,
                  ),
                  boxShadow: AppShadows.sm,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm - 1),
                  child: item.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.images.first,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceSecondary,
                            child: const Icon(Icons.image,
                                size: 20, color: AppColors.gray400),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceSecondary,
                          child: const Icon(Icons.image,
                              size: 20, color: AppColors.gray400),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item title + timestamp
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textPrimary,
                              fontWeight: hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: AppTypography.fontMd,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMsg != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            formatRelativeTime(lastMsg.createdAt),
                            style: GoogleFonts.plusJakartaSans(
                              color: hasUnread
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                              fontSize: AppTypography.fontXs,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Price + status
                    Row(
                      children: [
                        Text(
                          '${orderDetail.order.priceInCoins} SC',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontSize: AppTypography.fontXs,
                            fontWeight: FontWeight.w600,
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
                        _StatusChip(status: orderDetail.order.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Last message + unread badge
                    if (lastMsg != null)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMsg.content,
                              style: GoogleFonts.plusJakartaSans(
                                color: hasUnread
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontSize: AppTypography.fontSm,
                                fontWeight: hasUnread
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                height: AppTypography.lineHeightNormal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                '${orderDetail.unreadCount}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.white,
                                  fontSize: AppTypography.fontXs,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),

              // Chevron
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm, top: AppSpacing.md),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderStatus.pending => ('Pending', AppColors.textTertiary),
      OrderStatus.readyForPickup => ('Ready', AppColors.primary),
      OrderStatus.completed => ('Completed', AppColors.success),
      OrderStatus.cancelled => ('Cancelled', AppColors.error),
      _ => (status.name, AppColors.textTertiary),
    };

    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        color: color,
        fontSize: AppTypography.fontXs,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
