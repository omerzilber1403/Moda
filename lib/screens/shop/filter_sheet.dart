import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/clothing_item.dart';
import '../../providers/shop_provider.dart';
import '../../services/mock_api.dart';
import '../../theme/tokens.dart';

/// Airbnb-style filter bottom sheet for the Shop marketplace.
///
/// Displays filter sections for category, size, price range, and condition.
/// Reads initial values from the current [ShopFilterState] and applies
/// all selections at once when the user taps "Apply Filters".
class FilterSheet extends StatefulWidget {
  final int? initialCategory;
  final String? initialSize;
  final String? initialCondition;
  final int initialPriceMin;
  final int initialPriceMax;
  final void Function(
    int? category,
    String? size,
    String? condition,
    int priceMin,
    int priceMax,
  ) onApply;

  const FilterSheet({
    super.key,
    this.initialCategory,
    this.initialSize,
    this.initialCondition,
    this.initialPriceMin = 0,
    this.initialPriceMax = 100,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late int? _selectedCategory;
  late String? _selectedSize;
  late String? _selectedCondition;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedSize = widget.initialSize;
    _selectedCondition = widget.initialCondition;
    _priceRange = RangeValues(
      widget.initialPriceMin.toDouble(),
      widget.initialPriceMax.toDouble(),
    );
  }

  void _clearAll() {
    setState(() {
      _selectedCategory = null;
      _selectedSize = null;
      _selectedCondition = null;
      _priceRange = const RangeValues(0, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),

          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: AppTypography.fontXl,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: AppTypography.letterSpacingTight,
                  ),
                ),
                GestureDetector(
                  onTap: _clearAll,
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppTypography.fontSm,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable filter sections
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category section
                  _buildSectionTitle('Category'),
                  const SizedBox(height: AppSpacing.md),
                  _buildCategoryChips(),
                  const SizedBox(height: AppSpacing.xl),

                  // Size section
                  _buildSectionTitle('Size'),
                  const SizedBox(height: AppSpacing.md),
                  _buildSizeChips(),
                  const SizedBox(height: AppSpacing.xl),

                  // Price range section
                  _buildSectionTitle('Price Range (SC)'),
                  const SizedBox(height: AppSpacing.md),
                  _buildPriceRangeSlider(),
                  const SizedBox(height: AppSpacing.xl),

                  // Condition section
                  _buildSectionTitle('Condition'),
                  const SizedBox(height: AppSpacing.md),
                  _buildConditionChips(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Apply button
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.lg,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _selectedCategory,
                    _selectedSize,
                    _selectedCondition,
                    _priceRange.start.round(),
                    _priceRange.end.round(),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: AppTypography.fontMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: AppTypography.fontMd,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCategoryChips() {
    const categories = MockApi.categories;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category.id;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _FilterChip(
              label: category.name,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedCategory =
                      isSelected ? null : category.id;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSizeChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: clothingSizes.map((size) {
          final isSelected = _selectedSize == size;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _FilterChip(
              label: size,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedSize = isSelected ? null : size;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRangeSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_priceRange.start.round()} SC',
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppTypography.fontSm,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${_priceRange.end.round()} SC',
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppTypography.fontSm,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.12),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
            ),
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 10,
            ),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
          ),
          child: RangeSlider(
            values: _priceRange,
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConditionChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ItemCondition.values.map((condition) {
          final isSelected = _selectedCondition == condition.value;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _FilterChip(
              label: condition.label,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedCondition =
                      isSelected ? null : condition.value;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// A single filter chip with selected/unselected styling.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppTypography.fontSm,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Shows the filter bottom sheet pre-populated with the current filter state
/// from [shopProvider]. On apply, updates the provider with all selected values.
void showFilterSheet(BuildContext context, WidgetRef ref) {
  final filters = ref.read(shopProvider).filters;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return FilterSheet(
        initialCategory: filters.categoryFilter,
        initialSize: filters.sizeFilter,
        initialCondition: filters.conditionFilter,
        initialPriceMin: filters.priceMin,
        initialPriceMax: filters.priceMax,
        onApply: (category, size, condition, priceMin, priceMax) {
          final notifier = ref.read(shopProvider.notifier);
          notifier.setCategory(category);
          notifier.setSize(size);
          notifier.setCondition(condition);
          notifier.setPriceRange(priceMin, priceMax);
        },
      );
    },
  );
}
