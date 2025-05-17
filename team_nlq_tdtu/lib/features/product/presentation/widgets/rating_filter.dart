import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_nlq_tdtu/core/theme/app_colors.dart';
import 'package:team_nlq_tdtu/features/product/presentation/providers/review_provider.dart';

class RatingFilter extends StatelessWidget {
  final String productId;

  const RatingFilter({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final selectedRating = reviewProvider.selectedRating;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            context: context,
            label: 'Tất cả',
            isSelected: selectedRating == null,
            onTap: () => reviewProvider.filterByRating(productId, null),
          ),
          const SizedBox(width: 8),
          for (int i = 5; i >= 1; i--)
            Row(
              children: [
                _buildFilterChip(
                  context: context,
                  label: '$i ⭐',
                  isSelected: selectedRating == i,
                  onTap: () => reviewProvider.filterByRating(productId, i),
                ),
                const SizedBox(width: 8),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
