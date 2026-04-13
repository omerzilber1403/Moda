import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/clothing_item.dart';
import '../shop/filter_sheet.dart' show genderOptions, genderLabel;
import '../../providers/items_provider.dart';
import '../../services/image_compress_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import '../../services/supabase_service.dart';
import '../../providers/shop_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_input.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _priceController = TextEditingController(text: '25');

  String _selectedSize = 'M';
  int _selectedCategory = 1;
  String _selectedCondition = 'good';
  String _selectedGender = 'unisex';
  final List<CompressedImage> _compressedImages = [];
  bool _isCompressing = false;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_compressedImages.length >= 5) return;

    setState(() => _isCompressing = true);
    try {
      final result = await ImageCompressService.pickAndCompress(source: source);
      if (result != null) {
        setState(() => _compressedImages.add(result));
      }
    } finally {
      setState(() => _isCompressing = false);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: Text('Camera', style: GoogleFonts.plusJakartaSans()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('Gallery', style: GoogleFonts.plusJakartaSans()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() => _compressedImages.removeAt(index));
  }

  Future<void> _submit() async {
    final price = int.tryParse(_priceController.text.trim());
    if (_titleController.text.isEmpty || _compressedImages.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add a title, at least one photo, and a valid price',
            style: GoogleFonts.plusJakartaSans(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;

      // Upload each compressed image to Supabase Storage
      final imageUrls = <String>[];
      for (final img in _compressedImages) {
        final path = '$uid/${DateTime.now().millisecondsSinceEpoch}_${img.filename}';
        await supabase.storage
            .from('item-images')
            .uploadBinary(path, img.bytes,
                fileOptions: FileOptions(contentType: 'image/jpeg', upsert: false));
        final url = supabase.storage
            .from('item-images')
            .getPublicUrl(path);
        imageUrls.add(url);
      }

      await ref.read(myItemsProvider.notifier).addItem(
            title: _titleController.text,
            description: _descController.text.isEmpty ? null : _descController.text,
            brand: _brandController.text.isEmpty ? null : _brandController.text,
            size: _selectedSize,
            categoryId: _selectedCategory,
            condition: _selectedCondition,
            color: _colorController.text.isEmpty ? null : _colorController.text,
            images: imageUrls,
            priceInCoins: price,
            gender: _selectedGender,
          );

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed. Please try again.',
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
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.black,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Upload Item',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontLg,
                          fontWeight: FontWeight.w600,
                          letterSpacing: AppTypography.letterSpacingTitle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.screenPaddingH,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: 'Photos', icon: Icons.photo_library_outlined),
            const SizedBox(height: AppSpacing.md),

            // Image picker row
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._compressedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final img = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: Image.memory(
                              img.bytes,
                              width: 82,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Remove button
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                          // Size badge
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${img.sizeKB.toStringAsFixed(0)}KB',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (_compressedImages.length < 5)
                    GestureDetector(
                      onTap: _isCompressing ? null : _showImageSourceSheet,
                      child: Container(
                        width: 82,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: _isCompressing
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Add Photo',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textTertiary,
                                      fontSize: AppTypography.fontXs,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            _SectionLabel(label: 'Item Details', icon: Icons.info_outline_rounded),
            const SizedBox(height: AppSpacing.md),

            GlassInput(
              controller: _titleController,
              hintText: 'Title — e.g. "Vintage Levi\'s 501"',
            ),
            const SizedBox(height: AppSpacing.md),

            GlassInput(
              controller: _descController,
              hintText: 'Description (optional)',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: GlassInput(
                    controller: _brandController,
                    hintText: 'Brand',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GlassInput(
                    controller: _colorController,
                    hintText: 'Color',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            _SectionLabel(label: 'Price', icon: Icons.monetization_on_outlined),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: GlassInput(
                    controller: _priceController,
                    hintText: 'Price in Style Coins',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Text(
                    'SC',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontSize: AppTypography.fontMd,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            _SectionLabel(label: 'Gender', icon: Icons.wc_outlined),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: genderOptions.map((g) {
                final selected = _selectedGender == g;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGender = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : AppShadows.sm,
                    ),
                    child: Text(
                      genderLabel(g),
                      style: GoogleFonts.plusJakartaSans(
                        color: selected ? AppColors.white : AppColors.textSecondary,
                        fontSize: AppTypography.fontSm,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            _SectionLabel(label: 'Size', icon: Icons.straighten_outlined),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: clothingSizes.map((size) {
                final selected = _selectedSize == size;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSize = size),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : AppShadows.sm,
                    ),
                    child: Text(
                      size,
                      style: GoogleFonts.plusJakartaSans(
                        color: selected ? AppColors.white : AppColors.textSecondary,
                        fontSize: AppTypography.fontSm,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            _SectionLabel(label: 'Category', icon: Icons.category_outlined),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: ref.watch(shopProvider).categories.map((cat) {
                final selected = _selectedCategory == cat.id;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryLight : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.border,
                        width: 1,
                      ),
                      boxShadow: selected ? null : AppShadows.sm,
                    ),
                    child: Text(
                      '${cat.icon ?? ''} ${cat.name}',
                      style: GoogleFonts.plusJakartaSans(
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                        fontSize: AppTypography.fontSm,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            _SectionLabel(label: 'Condition', icon: Icons.star_outline_rounded),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: ItemCondition.values.map((cond) {
                final selected = _selectedCondition == cond.value;
                final condColor = _conditionColor(cond.value);
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCondition = cond.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? condColor.withValues(alpha: 0.12)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: selected
                            ? condColor.withValues(alpha: 0.5)
                            : AppColors.border,
                        width: 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: condColor.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : AppShadows.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: condColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Text(
                          cond.label,
                          style: GoogleFonts.plusJakartaSans(
                            color: selected ? condColor : AppColors.textSecondary,
                            fontSize: AppTypography.fontSm,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            GlassButton(
              label: _isUploading ? 'Uploading…' : 'Upload Item',
              icon: _isUploading ? Icons.hourglass_top_rounded : Icons.upload_rounded,
              onPressed: _isUploading ? null : _submit,
              width: double.infinity,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Color _conditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'new_with_tags':
      case 'new with tags':
        return AppColors.primary;
      case 'like_new':
      case 'like new':
        return AppColors.success;
      case 'good':
        return AppColors.warning;
      case 'fair':
        return AppColors.gray400;
      default:
        return AppColors.gray500;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
