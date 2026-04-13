import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/supabase_service.dart';
import '../../theme/tokens.dart';
import '../../utils/helpers.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String orderId;

  const ChatScreen({super.key, required this.orderId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _confirmPickup(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          'Confirm Pickup',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Confirm that the item has been picked up. Once both parties confirm, the Style Coins will be transferred to the seller.',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: AppTypography.fontSm,
            height: AppTypography.lineHeightRelaxed,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Not Yet',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Text(
              'Confirm Pickup',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final completed = await ref
        .read(walletProvider.notifier)
        .confirmPickup(order.id);

    if (!mounted) return;

    ref.read(ordersProvider.notifier).refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          completed
              ? 'Pickup confirmed! Transaction completed.'
              : 'Pickup confirmed! Waiting for the other party.',
          style: GoogleFonts.plusJakartaSans(color: AppColors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  Future<void> _cancelOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          'Cancel Order',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure? The locked Style Coins will be refunded to the buyer.',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: AppTypography.fontSm,
            height: AppTypography.lineHeightRelaxed,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep Order',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Text(
              'Cancel Order',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(walletProvider.notifier)
        .cancelOrder(order.id);

    if (!mounted) return;

    ref.read(ordersProvider.notifier).refresh();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order cancelled. Coins have been refunded.',
            style: GoogleFonts.plusJakartaSans(color: AppColors.white),
          ),
          backgroundColor: AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _devForceComplete(Order order) async {
    assert(kDebugMode);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          '⚡ Dev: Force Complete',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: Text(
          'Skip pickup confirmation and mark this order as completed. Coins will be transferred to the seller.',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: AppTypography.fontSm,
            height: AppTypography.lineHeightRelaxed,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: Text('Force Complete',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final result = await supabase.rpc(
        'dev_force_complete_order',
        params: {'p_order_id': order.id},
      );
      if (!mounted) return;

      final success = result is Map && result['success'] == true;
      ref.read(ordersProvider.notifier).refresh();
      ref.read(walletProvider.notifier).loadWallet();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '⚡ Order force-completed! Coins transferred.' : 'Failed: ${result['error']}',
            style: GoogleFonts.plusJakartaSans(color: AppColors.white),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e',
              style: GoogleFonts.plusJakartaSans(color: AppColors.white)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUserId =
        ref.read(authProvider).user?.id ?? 'user-me';
    ref.read(chatProvider(widget.orderId).notifier).sendMessage(
          text,
          currentUserId,
        );
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider(widget.orderId));
    final currentUserId =
        ref.watch(authProvider).user?.id ?? 'user-me';

    final allOrders = ref.watch(ordersProvider);
    final orderDetail = allOrders
        .where((od) => od.order.id == widget.orderId)
        .firstOrNull;
    final otherUser = orderDetail?.otherUser;
    final item = orderDetail?.item;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.black,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  // Item thumbnail
                  if (item != null) ...[
                    _ItemThumb(imageUrl: item.images.first),
                    const SizedBox(width: AppSpacing.md),
                  ],

                  // Other user info
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherUser?.displayName ?? 'Chat',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textPrimary,
                            fontSize: AppTypography.fontMd,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item != null)
                          Text(
                            '${item.title} \u2022 ${orderDetail!.order.priceInCoins} SC',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textTertiary,
                              fontSize: AppTypography.fontXs,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                      ],
                    ),
                  ),

                  // Avatar
                  if (otherUser?.avatarUrl != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: otherUser!.avatarUrl ?? '',
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
                    const SizedBox(width: AppSpacing.sm),
                  ],

                  // Dev-only: force-complete button
                  if (kDebugMode &&
                      orderDetail != null &&
                      orderDetail.order.status != OrderStatus.completed &&
                      orderDetail.order.status != OrderStatus.cancelled)
                    IconButton(
                      tooltip: 'Dev: Force Complete',
                      icon: const Text('⚡', style: TextStyle(fontSize: 18)),
                      onPressed: () => _devForceComplete(orderDetail.order),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Pickup confirmation banner
          if (orderDetail != null &&
              orderDetail.order.status == OrderStatus.pending)
            _PickupBanner(
              order: orderDetail.order,
              currentUserId: currentUserId,
              onConfirm: () => _confirmPickup(orderDetail.order),
              onCancel: () => _cancelOrder(orderDetail.order),
            ),

          // Completed banner
          if (orderDetail != null &&
              orderDetail.order.status == OrderStatus.completed)
            _CompletedBanner(),

          // Messages list
          Expanded(
            child: chat.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : chat.messages.isEmpty
                    ? _EmptyChat(
                        otherUserName:
                            otherUser?.displayName ?? 'them',
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          top: AppSpacing.xl,
                          bottom: AppSpacing.md,
                        ),
                        itemCount: chat.messages.length,
                        itemBuilder: (context, index) {
                          final msg = chat.messages[index];
                          return ChatBubble(
                            content: msg.content,
                            isMine: msg.senderId == currentUserId,
                            time: formatTime(msg.createdAt),
                          );
                        },
                      ),
          ),

          // Chat input bar
          _ChatInputBar(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final String otherUserName;

  const _EmptyChat({required this.otherUserName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Say hello to $otherUserName!',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontLg,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start the conversation to arrange the handoff.',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: AppTypography.fontSm,
                height: AppTypography.lineHeightRelaxed,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemThumb extends StatelessWidget {
  final String imageUrl;

  const _ItemThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm - 1),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(
            color: AppColors.surfaceSecondary,
          ),
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInputBar({required this.controller, required this.onSend});

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Pill-shaped text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: AppTypography.fontMd,
                  height: AppTypography.lineHeightNormal,
                ),
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                onSubmitted: (_) => widget.onSend(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Send button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _hasText ? AppColors.primary : AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: _hasText ? Colors.transparent : AppColors.border,
                width: 1,
              ),
              boxShadow: _hasText
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.full),
                onTap: widget.onSend,
                child: Center(
                  child: Icon(
                    Icons.send_rounded,
                    color:
                        _hasText ? AppColors.white : AppColors.textTertiary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pickup confirmation banner — shown for pending orders
// ---------------------------------------------------------------------------

class _PickupBanner extends StatelessWidget {
  final Order order;
  final String currentUserId;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _PickupBanner({
    required this.order,
    required this.currentUserId,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final iConfirmed = order.hasConfirmed(currentUserId);
    final otherConfirmed = order.otherPartyConfirmed(currentUserId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: iConfirmed
            ? AppColors.success.withValues(alpha: 0.06)
            : AppColors.primaryLight,
        border: Border(
          bottom: BorderSide(
            color: iConfirmed
                ? AppColors.success.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            children: [
              Icon(
                iConfirmed
                    ? Icons.check_circle_rounded
                    : Icons.lock_clock_rounded,
                color: iConfirmed ? AppColors.success : AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  iConfirmed
                      ? otherConfirmed
                          ? 'Both confirmed — completing transaction...'
                          : 'You confirmed pickup. Waiting for the other party.'
                      : 'Style Coins are locked. Confirm when pickup is done.',
                  style: GoogleFonts.plusJakartaSans(
                    color: iConfirmed
                        ? AppColors.success
                        : AppColors.textPrimary,
                    fontSize: AppTypography.fontXs,
                    fontWeight: FontWeight.w600,
                    height: AppTypography.lineHeightNormal,
                  ),
                ),
              ),
            ],
          ),

          // Confirmation badges
          if (order.buyerConfirmedPickup || order.sellerConfirmedPickup) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _ConfirmBadge(
                  label: 'Buyer',
                  confirmed: order.buyerConfirmedPickup,
                ),
                const SizedBox(width: AppSpacing.sm),
                _ConfirmBadge(
                  label: 'Seller',
                  confirmed: order.sellerConfirmedPickup,
                ),
              ],
            ),
          ],

          // Action buttons
          if (!iConfirmed) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(Icons.handshake_outlined, size: 16),
                      label: Text(
                        'Confirm Pickup',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppTypography.fontXs,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  height: 38,
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: AppTypography.fontXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfirmBadge extends StatelessWidget {
  final String label;
  final bool confirmed;

  const _ConfirmBadge({required this.label, required this.confirmed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: confirmed
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confirmed ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 12,
            color: confirmed ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: confirmed ? AppColors.success : AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(
            color: AppColors.success.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Transaction completed. Style Coins have been transferred.',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.success,
              fontSize: AppTypography.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
