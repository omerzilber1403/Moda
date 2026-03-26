import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../providers/address_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_button.dart';

class AddressListScreen extends ConsumerWidget {
  /// When true, tapping an address selects it (sets as default) and pops back.
  final bool selectMode;

  const AddressListScreen({super.key, this.selectMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressProvider);
    final addresses = addressState.addresses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Addresses',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontLg,
            fontWeight: FontWeight.bold,
            letterSpacing: AppTypography.letterSpacingTitle,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => context.push('/address/new'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: addresses.isEmpty
          ? EmptyState(
              icon: Icons.location_off_outlined,
              title: 'No addresses yet',
              subtitle: 'Add a delivery address to get started',
              action: GlassButton(
                label: 'Add Address',
                icon: Icons.add_rounded,
                onPressed: () => context.push('/address/new'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return _AddressTile(
                        address: address,
                        onTap: () {
                          if (selectMode) {
                            ref
                                .read(addressProvider.notifier)
                                .setDefault(address.id);
                            context.pop();
                          }
                        },
                        onDelete: () =>
                            _confirmDelete(context, ref, address),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: GlassButton(
                      label: 'Add New Address',
                      variant: GlassButtonVariant.outline,
                      icon: Icons.add_rounded,
                      onPressed: () => context.push('/address/new'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Address address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Delete Address',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: AppTypography.fontLg,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${address.label}"?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppTypography.fontSm,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(addressProvider.notifier).removeAddress(address.id);
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final Address address;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AddressTile({
    required this.address,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: address.isDefault
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border,
            width: address.isDefault ? 1.5 : 1,
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: address.isDefault
                    ? AppColors.primaryLight
                    : AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                address.label == 'Home'
                    ? Icons.home_outlined
                    : address.label == 'Work'
                        ? Icons.work_outline_rounded
                        : Icons.location_on_outlined,
                color: address.isDefault
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontSm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'Default',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${address.fullName} \u2022 ${address.phone}',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary,
                      fontSize: AppTypography.fontXs,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${address.street}, ${address.city} ${address.zipCode}',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary,
                      fontSize: AppTypography.fontXs,
                      height: AppTypography.lineHeightNormal,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.textTertiary,
              iconSize: 20,
              splashRadius: 20,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
