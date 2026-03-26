import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/orders_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(ordersProvider);
    final withMessages =
        allOrders.where((o) => o.lastMessage != null).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.screenPaddingH,
              AppSpacing.xl,
              AppLayout.screenPaddingH,
              AppSpacing.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Chat',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: AppTypography.font2xl,
                    fontWeight: FontWeight.bold,
                    letterSpacing: AppTypography.letterSpacingTitle,
                  ),
                ),
                const Spacer(),
                if (withMessages.isNotEmpty)
                  Text(
                    '${withMessages.length} conversation${withMessages.length == 1 ? '' : 's'}',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textTertiary,
                      fontSize: AppTypography.fontSm,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: withMessages.isEmpty
                ? const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No conversations yet',
                    subtitle:
                        'Purchase an item to start chatting with the seller!',
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(
                      bottom: AppLayout.tabBarHeight + AppSpacing.lg,
                    ),
                    itemCount: withMessages.length,
                    separatorBuilder: (_, __) => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppLayout.screenPaddingH,
                      ),
                      height: 1,
                      color: AppColors.borderLight,
                    ),
                    itemBuilder: (context, index) {
                      final orderDetail = withMessages[index];
                      return _MessageTile(
                        orderDetail: orderDetail,
                        onTap: () => context
                            .push('/chat/${orderDetail.order.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final OrderDetail orderDetail;
  final VoidCallback onTap;

  const _MessageTile({required this.orderDetail, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasUnread = orderDetail.unreadCount > 0;

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
              // Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasUnread
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.border,
                        width: hasUnread ? 2 : 1,
                      ),
                    ),
                    child: ClipOval(
                      child: orderDetail.otherUser.avatarUrl != null
                          ? CachedNetworkImage(
                              imageUrl: orderDetail.otherUser.avatarUrl!,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.gray100,
                                child: const Icon(Icons.person,
                                    size: 24, color: AppColors.gray400),
                              ),
                            )
                          : Container(
                              width: 52,
                              height: 52,
                              color: AppColors.gray100,
                              child: const Icon(Icons.person,
                                  size: 24, color: AppColors.gray400),
                            ),
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + timestamp
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            orderDetail.otherUser.displayName,
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
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          formatRelativeTime(
                              orderDetail.lastMessage!.createdAt),
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
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Order context chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              orderDetail.item.title,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primary,
                                fontSize: AppTypography.fontXs,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs),
                            child: Text(
                              '\u2022',
                              style: TextStyle(
                                color:
                                    AppColors.primary.withValues(alpha: 0.6),
                                fontSize: AppTypography.fontXs,
                              ),
                            ),
                          ),
                          Text(
                            '${orderDetail.order.priceInCoins} SC',
                            style: GoogleFonts.plusJakartaSans(
                              color:
                                  AppColors.primary.withValues(alpha: 0.7),
                              fontSize: AppTypography.fontXs,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Last message + unread badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            orderDetail.lastMessage?.content ?? '',
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
            ],
          ),
        ),
      ),
    );
  }
}
