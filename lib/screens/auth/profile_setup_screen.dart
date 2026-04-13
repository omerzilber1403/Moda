import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/clothing_item.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../theme/tokens.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  String? _selectedGender;
  final Set<String> _selectedSizes = {};
  bool _isSaving = false;

  Future<void> _save() async {
    if (_selectedGender == null) return;
    setState(() => _isSaving = true);
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;
      await supabase.from('profiles').update({
        'gender': _selectedGender,
        'preferred_gender': _selectedGender == 'men' || _selectedGender == 'women'
            ? _selectedGender
            : null,
        'preferred_sizes': _selectedSizes.toList(),
      }).eq('id', uid);
      await ref.read(authProvider.notifier).refreshProfile();
      if (mounted) context.go('/shop');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Something went wrong. Please try again.',
              style: GoogleFonts.plusJakartaSans(color: AppColors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.screenPaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),

              // Header
              Text(
                'Welcome to Moda',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.font2xl,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: AppTypography.letterSpacingTitle,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tell us a bit about yourself so we can show you the most relevant items.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.fontMd,
                  color: AppColors.textSecondary,
                  height: AppTypography.lineHeightNormal,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Gender section
              Text(
                'I shop for',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.fontLg,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _GenderCard(
                    label: 'Men',
                    icon: Icons.male_rounded,
                    value: 'men',
                    isSelected: _selectedGender == 'men',
                    onTap: () => setState(() => _selectedGender = 'men'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _GenderCard(
                    label: 'Women',
                    icon: Icons.female_rounded,
                    value: 'women',
                    isSelected: _selectedGender == 'women',
                    onTap: () => setState(() => _selectedGender = 'women'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _GenderCard(
                    label: 'Both',
                    icon: Icons.all_inclusive_rounded,
                    value: 'unisex',
                    isSelected: _selectedGender == 'unisex',
                    onTap: () => setState(() => _selectedGender = 'unisex'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Sizes section
              Text(
                'My usual sizes',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.fontLg,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Select all that apply',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.fontSm,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: clothingSizes.map((size) {
                  final selected = _selectedSizes.contains(size);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedSizes.remove(size);
                        } else {
                          _selectedSizes.add(size);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : AppShadows.sm,
                      ),
                      child: Text(
                        size,
                        style: GoogleFonts.plusJakartaSans(
                          color: selected
                              ? AppColors.white
                              : AppColors.textSecondary,
                          fontSize: AppTypography.fontMd,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      _selectedGender != null && !_isSaving ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          'Continue',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: AppTypography.fontMd,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: bottomPadding + AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.outlineVariant.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppShadows.sm,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.fontMd,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
