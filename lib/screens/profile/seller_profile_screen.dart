import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/shop_item_card.dart';

class SellerProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const SellerProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<SellerProfileScreen> createState() =>
      _SellerProfileScreenState();
}

class _SellerProfileScreenState extends ConsumerState<SellerProfileScreen> {
  AppUser? _seller;
  List<ClothingItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        supabase.from('profiles').select().eq('id', widget.userId).single(),
        supabase
            .from('clothing_items')
            .select()
            .eq('owner_id', widget.userId)
            .eq('is_active', true)
            .order('created_at', ascending: false),
      ]);

      if (!mounted) return;

      setState(() {
        _seller = AppUser.fromJson(results[0] as Map<String, dynamic>);
        _items = (results[1] as List)
            .map((e) => ClothingItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
      setState(() {
        _isLoading = false;
        if (msg.contains('network') ||
            msg.contains('socket') ||
            msg.contains('connection')) {
          _errorMessage = 'Connection error. Check your internet and try again.';
        } else {
          _errorMessage = 'Could not load this profile.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          : _errorMessage != null
              ? _ErrorBody(
                  message: _errorMessage!,
                  onBack: () => context.pop(),
                  onRetry: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _load();
                  },
                )
              : _seller == null
                  ? _ErrorBody(
                      message: 'User not found.',
                      onBack: () => context.pop(),
                    )
                  : CustomScrollView(
                      slivers: [
                        // App bar
                        SliverAppBar(
                          backgroundColor: AppColors.surface,
                          surfaceTintColor: Colors.transparent,
                          elevation: 0,
                          pinned: true,
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: AppColors.textPrimary),
                            onPressed: () => context.pop(),
                          ),
                          title: Text(
                            _seller!.displayName,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textPrimary,
                              fontSize: AppTypography.fontLg,
                              fontWeight: FontWeight.bold,
                              letterSpacing: AppTypography.letterSpacingTitle,
                            ),
                          ),
                          centerTitle: true,
                        ),

                        // Profile header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppLayout.screenPaddingH,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: AppSpacing.xl),

                                // Avatar
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _seller!.avatarUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: _seller!.avatarUrl!,
                                            width: 96,
                                            height: 96,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) =>
                                                _AvatarPlaceholder(),
                                          )
                                        : _AvatarPlaceholder(),
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.md),

                                // Name
                                Text(
                                  _seller!.displayName,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textPrimary,
                                    fontSize: AppTypography.fontXl,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing:
                                        AppTypography.letterSpacingTitle,
                                  ),
                                ),

                                // City
                                if (_seller!.city != null) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 13,
                                        color: AppColors.textTertiary,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        _seller!.city!,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.textSecondary,
                                          fontSize: AppTypography.fontSm,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                // Bio
                                if (_seller!.bio != null) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    _seller!.bio!,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textSecondary,
                                      fontSize: AppTypography.fontSm,
                                      height: AppTypography.lineHeightRelaxed,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],

                                const SizedBox(height: AppSpacing.xl),

                                // Stats
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.lg,
                                    horizontal: AppSpacing.xl,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.xl),
                                    border: Border.all(
                                        color: AppColors.border, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _StatColumn(
                                        label: 'Listings',
                                        value: '${_items.length}',
                                      ),
                                      Container(
                                        width: 1,
                                        height: 36,
                                        color: AppColors.border,
                                      ),
                                      _StatColumn(
                                        label: 'Joined',
                                        value: _formatJoined(
                                            _seller!.createdAt),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.xxl),

                                // Section title
                                if (_items.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Listings',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.textPrimary,
                                        fontSize: AppTypography.fontMd,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                if (_items.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: AppSpacing.xxxl),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.checkroom_rounded,
                                          size: 48,
                                          color: AppColors.textTertiary,
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                        Text(
                                          'No listings yet',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppColors.textSecondary,
                                            fontSize: AppTypography.fontSm,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: AppSpacing.md),
                              ],
                            ),
                          ),
                        ),

                        // Items grid
                        if (_items.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppLayout.screenPaddingH,
                            ),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: AppSpacing.md,
                                crossAxisSpacing: AppSpacing.md,
                                childAspectRatio: 0.58,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = _items[index];
                                  final ownerRef = AppUserRef(
                                    id: _seller!.id,
                                    displayName: _seller!.displayName,
                                    avatarUrl: _seller!.avatarUrl,
                                    city: _seller!.city,
                                  );
                                  return ShopItemCard(
                                    item: item,
                                    owner: ownerRef,
                                    onTap: () =>
                                        context.push('/item/${item.id}'),
                                  );
                                },
                                childCount: _items.length,
                              ),
                            ),
                          ),

                        // Bottom padding
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.xxxl),
                        ),
                      ],
                    ),
    );
  }

  String _formatJoined(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      color: AppColors.gray100,
      child: const Icon(Icons.person, size: 48, color: AppColors.gray400),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textTertiary,
            fontSize: AppTypography.fontXs,
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  const _ErrorBody({
    required this.message,
    required this.onBack,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textPrimary),
                onPressed: onBack,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off_outlined,
                      size: 56, color: AppColors.textTertiary),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    message,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary,
                      fontSize: AppTypography.fontSm,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    GestureDetector(
                      onTap: onRetry,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.white,
                            fontSize: AppTypography.fontSm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
