import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_nlq_tdtu/core/theme/app_colors.dart';
import 'package:team_nlq_tdtu/features/product/domain/enums/review_sort_option.dart';
import 'package:team_nlq_tdtu/features/product/presentation/providers/review_provider.dart';

class ReviewSortOptions extends StatelessWidget {
  final String productId;

  const ReviewSortOptions({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);

    return PopupMenuButton<ReviewSortOption>(
      onSelected: (ReviewSortOption sortOption) {
        reviewProvider.sortReviews(productId, sortOption);
      },
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          context: context,
          title: 'Mới nhất',
          option: ReviewSortOption.newest,
          currentOption: reviewProvider.sortOption,
        ),
        _buildPopupMenuItem(
          context: context,
          title: 'Cũ nhất',
          option: ReviewSortOption.oldest,
          currentOption: reviewProvider.sortOption,
        ),
        _buildPopupMenuItem(
          context: context,
          title: 'Đánh giá cao nhất',
          option: ReviewSortOption.highestRating,
          currentOption: reviewProvider.sortOption,
        ),
        _buildPopupMenuItem(
          context: context,
          title: 'Đánh giá thấp nhất',
          option: ReviewSortOption.lowestRating,
          currentOption: reviewProvider.sortOption,
        ),
        _buildPopupMenuItem(
          context: context,
          title: 'Hữu ích nhất',
          option: ReviewSortOption.mostHelpful,
          currentOption: reviewProvider.sortOption,
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, size: 20),
            SizedBox(width: 4),
            Text('Sắp xếp'),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<ReviewSortOption> _buildPopupMenuItem({
    required BuildContext context,
    required String title,
    required ReviewSortOption option,
    required ReviewSortOption currentOption,
  }) {
    final isSelected = option == currentOption;

    return PopupMenuItem<ReviewSortOption>(
      value: option,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : Colors.black87,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.check,
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }
}
