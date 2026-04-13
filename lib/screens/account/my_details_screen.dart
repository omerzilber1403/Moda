import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../theme/tokens.dart';

class MyDetailsScreen extends ConsumerStatefulWidget {
  const MyDetailsScreen({super.key});

  @override
  ConsumerState<MyDetailsScreen> createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends ConsumerState<MyDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _bioController;

  late List<String> _selectedSizes;
  late List<String> _selectedCategories;
  String? _selectedGender;

  bool _isSaving = false;

  static const _allSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const _allCategories = [
    'Tops',
    'Bottoms',
    'Dresses',
    'Outerwear',
    'Shoes',
    'Accessories',
  ];
  static const _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _selectedSizes = List<String>.from(user?.preferredSizes ?? []);
    _selectedCategories = List<String>.from(user?.preferredCategories ?? []);
    _selectedGender = user?.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;
      await supabase.from('profiles').update({
        'display_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'bio': _bioController.text.trim(),
        'gender': _selectedGender,
        'preferred_sizes': _selectedSizes,
        'preferred_categories': _selectedCategories,
      }).eq('id', uid);
      await ref.read(authProvider.notifier).refreshProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated',
              style: GoogleFonts.plusJakartaSans(color: AppColors.white),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save: $e',
              style: GoogleFonts.plusJakartaSans(color: AppColors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
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
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Details',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontLg,
            fontWeight: FontWeight.bold,
            letterSpacing: AppTypography.letterSpacingTitle,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.screenPaddingH,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with change photo overlay
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.border, width: 1),
                    ),
                    child: ClipOval(
                      child: user.avatarUrl != null
                          ? CachedNetworkImage(
                              imageUrl: user.avatarUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _initialsAvatar(
                                  user.displayName, 100),
                            )
                          : _initialsAvatar(user.displayName, 100),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Photo picker coming soon',
                              style: GoogleFonts.plusJakartaSans(),
                            ),
                            backgroundColor: AppColors.textPrimary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.surface, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Personal Information ──────────────────────────────
            _sectionLabel('Personal Information'),
            const SizedBox(height: AppSpacing.md),

            _buildField(
              label: 'Full Name',
              controller: _nameController,
              icon: Icons.person_outline_rounded,
            ),

            const SizedBox(height: AppSpacing.lg),

            _buildField(
              label: 'Email',
              controller: _emailController,
              icon: Icons.mail_outline_rounded,
              readOnly: true,
            ),

            const SizedBox(height: AppSpacing.lg),

            _buildField(
              label: 'Phone',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              hint: 'Add phone number',
            ),

            const SizedBox(height: AppSpacing.lg),

            _buildField(
              label: 'City',
              controller: _cityController,
              icon: Icons.location_on_outlined,
              hint: 'Add your city',
            ),

            const SizedBox(height: AppSpacing.lg),

            _buildField(
              label: 'Bio',
              controller: _bioController,
              icon: Icons.edit_outlined,
              hint: 'Tell others about yourself',
              maxLines: 3,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Shopping Preferences ──────────────────────────────
            _sectionLabel('Shopping Preferences'),
            const SizedBox(height: AppSpacing.md),

            // Gender
            _prefLabel('Gender'),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              hint: Text(
                'Select gender',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary,
                  fontSize: AppTypography.fontMd,
                ),
              ),
              items: _genderOptions
                  .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(
                          g,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textPrimary,
                            fontSize: AppTypography.fontMd,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedGender = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Preferred Sizes
            _prefLabel('Preferred Sizes'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _allSizes.map((size) {
                final selected = _selectedSizes.contains(size);
                return FilterChip(
                  label: Text(
                    size,
                    style: GoogleFonts.plusJakartaSans(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: AppTypography.fontSm,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSizes.add(size);
                      } else {
                        _selectedSizes.remove(size);
                      }
                    });
                  },
                  selectedColor: AppColors.primaryLight,
                  backgroundColor: AppColors.surface,
                  checkmarkColor: AppColors.primary,
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Preferred Categories
            _prefLabel('Preferred Categories'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _allCategories.map((cat) {
                final selected = _selectedCategories.contains(cat);
                return FilterChip(
                  label: Text(
                    cat,
                    style: GoogleFonts.plusJakartaSans(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: AppTypography.fontSm,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedCategories.add(cat);
                      } else {
                        _selectedCategories.remove(cat);
                      }
                    });
                  },
                  selectedColor: AppColors.primaryLight,
                  backgroundColor: AppColors.surface,
                  checkmarkColor: AppColors.primary,
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppTypography.fontMd,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _initialsAvatar(String name, double size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.primary,
            fontSize: size * 0.36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontSize: AppTypography.fontMd,
        fontWeight: FontWeight.bold,
        letterSpacing: AppTypography.letterSpacingTitle,
      ),
    );
  }

  Widget _prefLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: AppColors.textSecondary,
        fontSize: AppTypography.fontXs,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: AppTypography.fontXs,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.plusJakartaSans(
            color: readOnly
                ? AppColors.textTertiary
                : AppColors.textPrimary,
            fontSize: AppTypography.fontMd,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: AppColors.textTertiary,
              fontSize: AppTypography.fontMd,
            ),
            prefixIcon: Icon(
              icon,
              color: readOnly
                  ? AppColors.textTertiary
                  : AppColors.textSecondary,
              size: 20,
            ),
            filled: true,
            fillColor:
                readOnly ? AppColors.gray100 : AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppRadius.lg),
              borderSide:
                  const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppRadius.lg),
              borderSide:
                  const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
