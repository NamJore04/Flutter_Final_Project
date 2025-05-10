import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/review_model.dart';

class ReviewItem extends StatelessWidget {
  final Review review;
  final Function(String)? onMarkHelpful;
  final bool showProductInfo;

  const ReviewItem({
    super.key,
    required this.review,
    this.onMarkHelpful,
    this.showProductInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User avatar
              if (review.userAvatar != null)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: CachedNetworkImageProvider(
                    review.userAvatar!,
                  ),
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // User name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (review.verified)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.verified,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      dateFormatter.format(review.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${review.rating}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.star,
                      size: 14,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Product info if needed
          if (showProductInfo) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.network(
                        'https://via.placeholder.com/80',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Laptop Dell XPS 13 Plus 9320',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Review text
          Text(review.comment, style: theme.textTheme.bodyMedium),

          // Review images
          if (review.images != null && review.images!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: GestureDetector(
                        onTap: () {
                          _showFullScreenImage(context, review.images!, index);
                        },
                        child: CachedNetworkImage(
                          imageUrl: review.images![index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                width: 80,
                                height: 80,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                width: 80,
                                height: 80,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.error),
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Helpful button
          if (onMarkHelpful != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => onMarkHelpful!(review.id),
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text('Hữu ích (${review.helpfulCount})'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: theme.textTheme.bodySmall,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // Show report dialog
                    _showReportDialog(context);
                  },
                  icon: const Icon(Icons.flag_outlined, size: 16),
                  label: const Text('Báo cáo'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog.fullscreen(
            child: Stack(
              children: [
                // Image viewer
                PageView.builder(
                  itemCount: images.length,
                  controller: PageController(initialPage: initialIndex),
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: images[index],
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          errorWidget:
                              (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    );
                  },
                ),
                // Close button
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Báo cáo đánh giá'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Vui lòng chọn lý do báo cáo:'),
                const SizedBox(height: 16),
                ListView(
                  shrinkWrap: true,
                  children: [
                    _buildReportOption(context, 'Ngôn từ không phù hợp'),
                    _buildReportOption(context, 'Thông tin sai sự thật'),
                    _buildReportOption(context, 'Quảng cáo, spam'),
                    _buildReportOption(context, 'Nội dung xúc phạm'),
                    _buildReportOption(context, 'Lý do khác'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('HỦY'),
              ),
            ],
          ),
    );
  }

  Widget _buildReportOption(BuildContext context, String reason) {
    return ListTile(
      title: Text(reason),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi báo cáo về đánh giá này với lý do: $reason'),
          ),
        );
      },
    );
  }
}
