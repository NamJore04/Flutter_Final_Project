import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_nlq_tdtu/core/routes/app_router.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_button.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/product_model.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/review_model.dart';
import 'package:team_nlq_tdtu/features/product/presentation/widgets/review_item.dart';

class ReviewScreen extends StatefulWidget {
  final String productId;

  const ReviewScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _isLoading = true;
  Product? _product;
  List<Review> _reviews = [];
  bool _hasMoreReviews = true;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isLoadingMore = false;

  // Filter options
  int? _selectedRating;
  String _sortOption = 'newest'; // 'newest', 'oldest', 'highest', 'lowest'
  bool _showWithPhotos = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMockData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreReviews();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMockData() async {
    // Mock loading delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock product data
    final product = Product(
      id: widget.productId,
      name: 'Laptop Dell XPS 13 Plus 9320',
      price: 35900000,
      originalPrice: 40000000,
      description:
          'Dell XPS 13 Plus 9320 là chiếc laptop cao cấp với thiết kế mỏng nhẹ.',
      images: ['https://via.placeholder.com/800x600?text=XPS+13+Main'],
      brand: 'Dell',
      categoryId: 'cat_laptop',
      stock: 15,
      rating: 4.7,
      reviewCount: 42,
      isOnSale: true,
    );

    // Generate mock reviews
    final reviews = List.generate(
      20,
      (index) => Review(
        id: 'rev_$index',
        productId: widget.productId,
        userId: 'user_$index',
        userName: 'Người dùng ${index + 1}',
        rating: 5 - (index % 5), // Spread ratings from 1-5
        comment:
            'Đây là một đánh giá ${_getRatingText(5 - (index % 5))} về sản phẩm. ${index % 3 == 0 ? 'Sản phẩm đáng tiền, chất lượng tốt.' : ''} ${index % 2 == 0 ? 'Giao hàng nhanh, đóng gói cẩn thận.' : 'Sản phẩm đúng như mô tả, rất hài lòng.'}',
        createdAt: DateTime.now().subtract(Duration(days: index * 2)),
        userAvatar: index % 4 == 0 ? 'https://via.placeholder.com/150' : null,
        images: index % 3 == 0
            ? List.generate(
                index % 2 + 1,
                (i) =>
                    'https://via.placeholder.com/300?text=Review+Image+${index}_$i')
            : null,
        helpfulCount: index % 10,
        verified: index % 3 == 0,
      ),
    );

    // Only load the first page initially
    setState(() {
      _product = product;
      _reviews = reviews.take(_pageSize).toList();
      _isLoading = false;
      _hasMoreReviews = reviews.length > _pageSize;
    });
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'rất tệ';
      case 2:
        return 'tệ';
      case 3:
        return 'bình thường';
      case 4:
        return 'tốt';
      case 5:
        return 'rất tốt';
      default:
        return '';
    }
  }

  Future<void> _loadMoreReviews() async {
    if (!_hasMoreReviews || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate API call with delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate more mock reviews
    final moreReviews = List.generate(
      10,
      (index) {
        final actualIndex = index + (_currentPage * _pageSize);
        return Review(
          id: 'rev_$actualIndex',
          productId: widget.productId,
          userId: 'user_$actualIndex',
          userName: 'Người dùng ${actualIndex + 1}',
          rating: 5 - (actualIndex % 5),
          comment:
              'Đây là một đánh giá ${_getRatingText(5 - (actualIndex % 5))} về sản phẩm. ${actualIndex % 3 == 0 ? 'Sản phẩm đáng tiền, chất lượng tốt.' : ''} ${actualIndex % 2 == 0 ? 'Giao hàng nhanh, đóng gói cẩn thận.' : 'Sản phẩm đúng như mô tả, rất hài lòng.'}',
          createdAt: DateTime.now().subtract(Duration(days: actualIndex * 2)),
          userAvatar:
              actualIndex % 4 == 0 ? 'https://via.placeholder.com/150' : null,
          images: actualIndex % 3 == 0
              ? List.generate(
                  actualIndex % 2 + 1,
                  (i) =>
                      'https://via.placeholder.com/300?text=Review+Image+${actualIndex}_$i')
              : null,
          helpfulCount: actualIndex % 10,
          verified: actualIndex % 3 == 0,
        );
      },
    );

    setState(() {
      _reviews.addAll(moreReviews);
      _currentPage++;
      _isLoadingMore = false;
      _hasMoreReviews = _currentPage < 5; // Limit to 5 pages for mock data
    });
  }

  void _applyFilters() {
    setState(() {
      _isLoading = true;
    });

    // Simulate filtering delay
    Future.delayed(const Duration(milliseconds: 800), () {
      // In a real app, you would call your API with the filter parameters
      // For now, we'll just filter the current reviews

      setState(() {
        _isLoading = false;
      });
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedRating = null;
      _sortOption = 'newest';
      _showWithPhotos = false;

      // Re-apply filters (which now resets to default)
      _applyFilters();
    });
  }

  void _openReviewForm() {
    // Show review dialog or navigate to review form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh giá sản phẩm'),
        content:
            const Text('Tính năng đánh giá sản phẩm đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => GoRouter.of(context).pop(),
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Đánh giá sản phẩm'),
        ),
        body: const Center(
          child: LoadingIndicator(
            size: LoadingSize.large,
            message: 'Đang tải đánh giá...',
          ),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Đánh giá sản phẩm'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy sản phẩm',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.goNamed(AppRouter.productList),
                child: const Text('Quay lại danh sách sản phẩm'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Product summary
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: CachedNetworkImage(
                      imageUrl: _product!.images.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _product!.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Rating
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < _product!.rating.floor()
                                  ? Icons.star
                                  : index < _product!.rating
                                      ? Icons.star_half
                                      : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            '${_product!.rating}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' (${_product!.reviewCount})',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Active filters
          if (_selectedRating != null ||
              _showWithPhotos ||
              _sortOption != 'newest')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lọc: ${_getActiveFiltersText()}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Xóa bộ lọc'),
                  ),
                ],
              ),
            ),

          // Rating filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(5, (index) {
                final rating = 5 - index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      children: [
                        Text('$rating'),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                    selected: _selectedRating == rating,
                    onSelected: (selected) {
                      setState(() {
                        _selectedRating = selected ? rating : null;
                        _applyFilters();
                      });
                    },
                  ),
                );
              }),
            ),
          ),

          // Write review button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _openReviewForm,
              icon: const Icon(Icons.rate_review),
              label: const Text('Viết đánh giá'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),

          const Divider(height: 1),

          // Reviews list
          Expanded(
            child: _reviews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 48,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có đánh giá nào',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hãy là người đầu tiên đánh giá sản phẩm này',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _openReviewForm,
                          child: const Text('Viết đánh giá'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _reviews.length + (_hasMoreReviews ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _reviews.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: _isLoadingMore
                                ? const CircularProgressIndicator()
                                : TextButton(
                                    onPressed: _loadMoreReviews,
                                    child: const Text('Xem thêm đánh giá'),
                                  ),
                          ),
                        );
                      }

                      return ReviewItem(
                        review: _reviews[index],
                        onMarkHelpful: (id) {
                          // Mark review as helpful
                          setState(() {
                            final reviewIndex =
                                _reviews.indexWhere((r) => r.id == id);
                            if (reviewIndex != -1) {
                              _reviews[reviewIndex] =
                                  _reviews[reviewIndex].copyWith(
                                helpfulCount:
                                    _reviews[reviewIndex].helpfulCount + 1,
                              );
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getActiveFiltersText() {
    List<String> filters = [];

    if (_selectedRating != null) {
      filters.add('$_selectedRating sao');
    }

    if (_showWithPhotos) {
      filters.add('Có hình ảnh');
    }

    switch (_sortOption) {
      case 'newest':
        // This is the default, so we don't add it
        break;
      case 'oldest':
        filters.add('Cũ nhất');
        break;
      case 'highest':
        filters.add('Điểm cao nhất');
        break;
      case 'lowest':
        filters.add('Điểm thấp nhất');
        break;
    }

    return filters.join(', ');
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'Lọc đánh giá',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Rating filter
                  const Text(
                    'Đánh giá',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(5, (index) {
                      final rating = 5 - index;
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$rating'),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                        selected: _selectedRating == rating,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedRating = selected ? rating : null;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // With photos filter
                  Row(
                    children: [
                      const Text(
                        'Chỉ hiện đánh giá có hình ảnh',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(
                        value: _showWithPhotos,
                        onChanged: (value) {
                          setModalState(() {
                            _showWithPhotos = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sort options
                  const Text(
                    'Sắp xếp theo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: const Text('Mới nhất'),
                    value: 'newest',
                    groupValue: _sortOption,
                    onChanged: (value) {
                      setModalState(() {
                        _sortOption = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Cũ nhất'),
                    value: 'oldest',
                    groupValue: _sortOption,
                    onChanged: (value) {
                      setModalState(() {
                        _sortOption = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Đánh giá cao nhất'),
                    value: 'highest',
                    groupValue: _sortOption,
                    onChanged: (value) {
                      setModalState(() {
                        _sortOption = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Đánh giá thấp nhất'),
                    value: 'lowest',
                    groupValue: _sortOption,
                    onChanged: (value) {
                      setModalState(() {
                        _sortOption = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Xóa bộ lọc',
                          onPressed: () {
                            setModalState(() {
                              _selectedRating = null;
                              _showWithPhotos = false;
                              _sortOption = 'newest';
                            });
                          },
                          type: ButtonType.outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: 'Áp dụng',
                          onPressed: () {
                            setState(() {
                              // Update main state with filter options
                              _selectedRating = _selectedRating;
                              _showWithPhotos = _showWithPhotos;
                              _sortOption = _sortOption;

                              // Apply filters and close sheet
                              Navigator.pop(context);
                              _applyFilters();
                            });
                          },
                          type: ButtonType.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
