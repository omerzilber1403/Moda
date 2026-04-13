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

/// Groups orders by the other user so the chat list shows one row per person.
class _UserChatGroup {
  final AppUser otherUser;
  final List<OrderDetail> orders;

  _UserChatGroup({required this.otherUser, required this.orders});

  /// Total unread count across all orders with this user.
  int get totalUnread => orders.fold(0, (sum, o) => sum + o.unreadCount);

  /// The most recent message across all orders with this user.
  Message get latestMessage => orders
      .map((o) => o.lastMessage!)
      .reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);

  /// Number of active items/orders.
  int get itemCount => orders.length;
}

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  List<_UserChatGroup> _groupByUser(List<OrderDetail> orders) {
    final withMessages = orders.where((o) => o.lastMessage != null).toList();
    final grouped = <String, List<OrderDetail>>{};
    for (final o in withMessages) {
      grouped.putIfAbsent(o.otherUser.id, () => []).add(o);
    }
    final groups = grouped.entries.map((e) {
      return _UserChatGroup(
        otherUser: e.value.first.otherUser,
        orders: e.value,
      );
    }).toList();
    // Sort by most recent message
    groups.sort((a, b) =>
        b.latestMessage.createdAt.compareTo(a.latestMessage.createdAt));
    return groups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(ordersProvider);
    final groups = _groupByUser(allOrders);

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
                  'Messages',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.onSurface,
                    fontSize: AppTypography.font2xl,
                    fontWeight: FontWeight.w900,
                    letterSpacing: AppTypography.letterSpacingHeadline,
                  ),
                ),
                const Spacer(),
                if (groups.isNotEmpty)
                  Text(
                    '${groups.length} conversation${groups.length == 1 ? '' : 's'}',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textTertiary,
                      fontSize: AppTypography.fontSm,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: groups.isEmpty
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
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _UserChatTile(
                        group: group,
                        onTap: () {
                          // Navigate to the most recent order's chat
                          final mostRecent = group.orders.reduce((a, b) =>
                              a.order.createdAt.isAfter(b.order.createdAt) ? a : b);
                          context.push('/chat/${mostRecent.order.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserChatTile extends StatelessWidget {
  final _UserChatGroup group;
  final VoidCallback onTap;

  const _UserChatTile({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasUnread = group.totalUnread > 0;
    final latestMsg = group.latestMessage;

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
                  ClipOval(
                    child: group.otherUser.avatarUrl != null
                        ? CachedNetworkImage(
                            imageUrl: group.otherUser.avatarUrl!,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 52,
                              height: 52,
                              color: AppColors.surfaceContainerHigh,
                              child: const Icon(Icons.person,
                                  size: 24, color: AppColors.onSurfaceVariant),
                            ),
                          )
                        : Container(
                            width: 52,
                            height: 52,
                            color: AppColors.surfaceContainerHigh,
                            child: const Icon(Icons.person,
                                size: 24, color: AppColors.onSurfaceVariant),
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
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  group.otherUser.displayName,
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
                              if (group.itemCount > 1) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.full),
                                  ),
                                  child: Text(
                                    '${group.itemCount} items',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textTertiary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          formatRelativeTime(latestMsg.createdAt),
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

                    // Item thumbnails strip (show up to 3 items)
                    _ItemThumbnailStrip(orders: group.orders),
                    const SizedBox(height: AppSpacing.xs),

                    // Last message + unread badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            latestMsg.content,
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
                              '${group.totalUnread}',
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

/// Shows small overlapping item thumbnails for the orders in this group.
class _ItemThumbnailStrip extends StatelessWidget {
  final List<OrderDetail> orders;

  const _ItemThumbnailStrip({required this.orders});

  @override
  Widget build(BuildContext context) {
    // Show at most 3 item thumbnails
    final visible = orders.take(3).toList();
    final remaining = orders.length - visible.length;

    return Row(
      children: [
        SizedBox(
          height: 28,
          width: 28.0 + (visible.length - 1) * 20.0 + (remaining > 0 ? 24 : 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < visible.length; i++)
                Positioned(
                  left: i * 20.0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.surface, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D1B1C17),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: visible[i].item.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: visible[i].item.images.first,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.surfaceSecondary,
                              ),
                            )
                          : Container(color: AppColors.surfaceSecondary),
                    ),
                  ),
                ),
              if (remaining > 0)
                Positioned(
                  left: visible.length * 20.0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+$remaining',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            orders.map((o) => o.item.title).join(', '),
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textTertiary,
              fontSize: AppTypography.fontXs,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
