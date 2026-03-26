import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
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
                              errorWidget: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                color: AppColors.gray100,
                                child: const Icon(Icons.person,
                                    size: 48, color: AppColors.gray400),
                              ),
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: AppColors.gray100,
                              child: const Icon(Icons.person,
                                  size: 48, color: AppColors.gray400),
                            ),
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

            // Full Name
            _buildField(
              label: 'Full Name',
              controller: _nameController,
              icon: Icons.person_outline_rounded,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Email (read-only)
            _buildField(
              label: 'Email',
              controller: _emailController,
              icon: Icons.mail_outline_rounded,
              readOnly: true,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Phone
            _buildField(
              label: 'Phone',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              hint: 'Add phone number',
            ),

            const SizedBox(height: AppSpacing.lg),

            // City
            _buildField(
              label: 'City',
              controller: _cityController,
              icon: Icons.location_on_outlined,
              hint: 'Add your city',
            ),

            const SizedBox(height: AppSpacing.lg),

            // Bio
            _buildField(
              label: 'Bio',
              controller: _bioController,
              icon: Icons.edit_outlined,
              hint: 'Tell others about yourself',
              maxLines: 3,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Profile updated',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.white,
                        ),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(
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
