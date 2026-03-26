import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/mock_api.dart';
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

    final order = MockApi.orders
        .where((o) => o.id == widget.orderId)
        .firstOrNull;
    final otherUserId = order != null
        ? (order.buyerId == currentUserId ? order.sellerId : order.buyerId)
        : null;
    final otherUser =
        otherUserId != null ? MockApi.getUserById(otherUserId) : null;
    final item = order != null ? MockApi.getItemById(order.itemId) : null;

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
                            '${item.title} \u2022 ${order!.priceInCoins} SC',
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
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
