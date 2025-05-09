import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_button.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';
import 'package:team_nlq_tdtu/core/widgets/product_card.dart';
import 'package:team_nlq_tdtu/features/cart/presentation/providers/cart_provider.dart';
import 'package:team_nlq_tdtu/features/cart/data/models/cart_item_model.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/product_model.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/review_model.dart';
import 'package:team_nlq_tdtu/features/product/presentation/widgets/review_item.dart';
import 'package:go_router/go_router.dart';
import 'package:team_nlq_tdtu/core/routes/app_router.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Product? _product;
  List<Product> _relatedProducts = [];
  List<Review> _reviews = [];
  final bool _hasMoreReviews = true;
  int _quantity = 1;
  bool _isExpanded = false;
  int _selectedImageIndex = 0;

  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load product details - In real app, replace with API call
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          'Dell XPS 13 Plus 9320 là chiếc laptop cao cấp với thiết kế mỏng nhẹ, màn hình InfinityEdge 13.4 inch, bàn phím cảm ứng và tích hợp nhiều công nghệ tiên tiến.\n\nCấu hình mạnh mẽ với CPU Intel Core i7-1280P, RAM 16GB LPDDR5, SSD 512GB PCIe NVMe và đồ họa Intel Iris Xe. Pin lên đến 13 giờ sử dụng liên tục và hệ thống làm mát tiên tiến.',
      images: [
        'https://via.placeholder.com/800x600?text=XPS+13+Main',
        'https://via.placeholder.com/800x600?text=XPS+13+Side',
        'https://via.placeholder.com/800x600?text=XPS+13+Back',
        'https://via.placeholder.com/800x600?text=XPS+13+Keyboard',
      ],
      brand: 'Dell',
      categoryId: 'cat_laptop',
      stock: 15,
      rating: 4.7,
      reviewCount: 42,
      isOnSale: true,
      features: [
        {'title': 'Màn hình', 'value': '13.4" 3.5K (3456 x 2160) OLED Touch'},
        {'title': 'CPU', 'value': 'Intel Core i7-1280P (14 nhân, 20 luồng)'},
        {'title': 'RAM', 'value': '16GB LPDDR5 5200MHz'},
        {'title': 'Ổ cứng', 'value': 'SSD 512GB M.2 PCIe NVMe'},
        {'title': 'Card đồ họa', 'value': 'Intel Iris Xe Graphics'},
        {'title': 'Kết nối', 'value': 'Wifi 6E, Bluetooth 5.2'},
        {'title': 'Hệ điều hành', 'value': 'Windows 11 Home'},
        {'title': 'Pin', 'value': 'Pin 55Whr, sạc 60W'},
      ],
      specifications: {
        'CPU': 'Intel Core i7-1280P (14 nhân, 20 luồng, up to 4.8GHz)',
        'RAM': '16GB LPDDR5 5200MHz (Onboard)',
        'Ổ cứng': 'SSD 512GB M.2 PCIe NVMe',
        'Màn hình': '13.4" 3.5K (3456 x 2160) OLED Touch, 400 nits',
        'Đồ họa': 'Intel Iris Xe Graphics',
        'Cổng kết nối': '2x Thunderbolt 4',
        'Không dây': 'Wifi 6E (802.11ax), Bluetooth 5.2',
        'Kích thước': '295.3 x 199.04 x 15.28 mm',
        'Trọng lượng': '1.24 kg',
        'Pin': '55Whr, sạc 60W',
        'Hệ điều hành': 'Windows 11 Home',
      },
    );

    // Mock related products
    final relatedProducts = List.generate(
      4,
      (index) => Product(
        id: 'rel_$index',
        name:
            'Laptop ${index % 2 == 0 ? 'Dell' : 'HP'} ${['Inspiron', 'Envy', 'Latitude', 'Pavilion'][index % 4]} ${1000 + index * 100}',
        price: 20000000 + (index * 2000000),
        originalPrice: index % 2 == 0 ? 22000000 + (index * 2000000) : null,
        description: 'Mô tả laptop ${index + 1}',
        images: ['https://via.placeholder.com/300?text=Laptop+${index + 1}'],
        brand: index % 2 == 0 ? 'Dell' : 'HP',
        categoryId: 'cat_laptop',
        stock: 10 + index,
        rating: 4.0 + (index % 10) / 10,
        reviewCount: 10 + (index * 5),
        isOnSale: index % 2 == 0,
      ),
    );

    // Mock reviews
    final reviews = List.generate(
      5,
      (index) => Review(
        id: 'rev_$index',
        productId: widget.productId,
        userId: 'user_$index',
        userName: 'Người dùng ${index + 1}',
        rating: 4 + (index % 2),
        comment:
            'Đây là một đánh giá rất ${index % 2 == 0 ? 'tốt' : 'hài lòng'} về sản phẩm. Tôi rất thích ${index % 2 == 0 ? 'hiệu suất và thiết kế' : 'chất lượng màn hình và bàn phím'} của nó.',
        createdAt: DateTime.now().subtract(Duration(days: index * 5)),
        userAvatar: index % 3 == 0 ? 'https://via.placeholder.com/150' : null,
        images:
            index % 2 == 0
                ? [
                  'https://via.placeholder.com/300?text=Review+Image+${index + 1}',
                ]
                : null,
        helpfulCount: index * 3,
        verified: index % 3 == 0,
      ),
    );

    setState(() {
      _product = product;
      _relatedProducts = relatedProducts;
      _reviews = reviews;
      _isLoading = false;
    });
  }

  void _incrementQuantity() {
    if (_quantity < (_product?.stock ?? 1)) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() {
    if (_product != null) {
      // Tạo cart item từ sản phẩm hiện tại
      final cartItem = CartItemModel(
        id: DateTime.now().toString(), // Thông thường ID sẽ được tạo từ backend
        productId: _product!.id,
        name: _product!.name,
        image: _product!.images.isNotEmpty ? _product!.images[0] : '',
        price: _product!.price,
        originalPrice: _product!.originalPrice ?? _product!.price,
        quantity: _quantity,
        selectedOptions: const {}, // Thêm thuộc tính nếu cần
      );

      // Thêm vào giỏ hàng
      try {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.addItem(cartItem);

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_product!.name} (x$_quantity) đã được thêm vào giỏ hàng',
            ),
            action: SnackBarAction(
              label: 'XEM GIỎ',
              onPressed: () {
                // Điều hướng đến trang giỏ hàng
                context.goNamed(AppRouter.cart);
              },
            ),
          ),
        );
      } catch (e) {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi khi thêm vào giỏ hàng: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _buyNow() {
    if (_product != null) {
      // Here you would add the product to the cart and navigate to checkout

      // For now, just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tính năng mua ngay đang được phát triển'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: const Center(
          child: LoadingIndicator(
            size: LoadingSize.large,
            message: 'Đang tải thông tin sản phẩm...',
          ),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
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
                onPressed: () {
                  context.goNamed(AppRouter.productList);
                },
                child: const Text('Quay lại danh sách sản phẩm'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App bar with product images
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Share product
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      // Add to wishlist
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: PageView.builder(
                    itemCount: _product!.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: _product!.images[index],
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) =>
                                      const Center(child: Icon(Icons.error)),
                            ),
                          ),
                          if (_product!.isOnSale)
                            Positioned(
                              top: 60,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'GIẢM GIÁ',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Image indicators
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _product!.images.length,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImageIndex = index;
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 44,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  _selectedImageIndex == index
                                      ? theme.colorScheme.primary
                                      : Colors.grey.withOpacity(0.3),
                              width: _selectedImageIndex == index ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: CachedNetworkImage(
                              imageUrl: _product!.images[index],
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error, size: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Product info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand
                      if (_product!.brand != null) ...[
                        Text(
                          _product!.brand!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Name
                      Text(
                        _product!.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

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
                              size: 20,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${_product!.rating}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${_product!.reviewCount} đánh giá)',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_formatCurrency(_product!.price)} VND',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_product!.originalPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${_formatCurrency(_product!.originalPrice!)} VND',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${((_product!.originalPrice! - _product!.price) / _product!.originalPrice! * 100).round()}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stock status
                      Row(
                        children: [
                          Icon(
                            _product!.isInStock
                                ? Icons.check_circle
                                : Icons.remove_circle,
                            color:
                                _product!.isInStock ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _product!.isInStock
                                ? 'Còn hàng (${_product!.stock})'
                                : 'Hết hàng',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  _product!.isInStock
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quantity
                      Row(
                        children: [
                          Text('Số lượng:', style: theme.textTheme.bodyLarge),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.5,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: _decrementQuantity,
                                  iconSize: 16,
                                ),
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$_quantity',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: _incrementQuantity,
                                  iconSize: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Mô tả sản phẩm',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _product!.description,
                        style: theme.textTheme.bodyMedium,
                        maxLines: _isExpanded ? null : 3,
                        overflow: _isExpanded ? null : TextOverflow.ellipsis,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(_isExpanded ? 'Thu gọn' : 'Xem thêm'),
                      ),

                      const Divider(),

                      // Features
                      if (_product!.features != null) ...[
                        Text(
                          'Tính năng nổi bật',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(_product!.features!.map(
                          (feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature['title'] + ': ' + feature['value'],
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                        const Divider(),
                      ],
                    ],
                  ),
                ),
              ),

              // Tabs for details, specifications, reviews
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Thông số kỹ thuật'),
                        Tab(text: 'Đánh giá'),
                        Tab(text: 'Sản phẩm liên quan'),
                      ],
                    ),
                    SizedBox(
                      height: 500, // Fixed height or calculate based on content
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Specifications tab
                          _buildSpecificationsTab(),

                          // Reviews tab
                          _buildReviewsTab(),

                          // Related products tab
                          _buildRelatedProductsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom spacing for the floating add to cart button
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),

          // Bottom add to cart bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Thêm vào giỏ hàng',
                      onPressed: _addToCart,
                      type: ButtonType.outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Mua ngay',
                      onPressed: _buyNow,
                      type: ButtonType.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    final theme = Theme.of(context);

    if (_product?.specifications == null) {
      return const Center(child: Text('Không có thông số kỹ thuật'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            _product!.specifications!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildReviewsTab() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Rating summary
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    '${_product!.rating}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
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
                  ),
                  Text(
                    '${_product!.reviewCount} đánh giá',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final starCount = 5 - index;
                    // Mock percentage based on star count
                    final percentage =
                        starCount == 5
                            ? 0.6
                            : starCount == 4
                            ? 0.25
                            : starCount == 3
                            ? 0.1
                            : starCount == 2
                            ? 0.03
                            : 0.02;

                    return Row(
                      children: [
                        Text('$starCount', style: theme.textTheme.bodySmall),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(percentage * 100).toInt()}%',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // Review button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () {
              // Show review dialog
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Viết đánh giá'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ),

        const Divider(height: 32),

        // Reviews list
        Expanded(
          child:
              _reviews.isEmpty
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
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _reviews.length + (_hasMoreReviews ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _reviews.length) {
                        return Center(
                          child: TextButton(
                            onPressed: () {
                              // Load more reviews
                            },
                            child: const Text('Xem thêm đánh giá'),
                          ),
                        );
                      }

                      return ReviewItem(
                        review: _reviews[index],
                        onMarkHelpful: (id) {
                          // Mark review as helpful
                          setState(() {
                            final index = _reviews.indexWhere(
                              (r) => r.id == id,
                            );
                            if (index != -1) {
                              _reviews[index] = _reviews[index].copyWith(
                                helpfulCount: _reviews[index].helpfulCount + 1,
                              );
                            }
                          });
                        },
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildRelatedProductsTab() {
    if (_relatedProducts.isEmpty) {
      return const Center(child: Text('Không có sản phẩm liên quan'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _relatedProducts.length,
      itemBuilder: (context, index) {
        final product = _relatedProducts[index];
        return ProductCard(
          id: product.id,
          name: product.name,
          price: product.price,
          originalPrice: product.originalPrice,
          imageUrl: product.images.isNotEmpty ? product.images[0] : null,
          brand: product.brand,
          isOnSale: product.isOnSale,
          onTap: () {
            // Navigate to related product
          },
          onAddToCart: () {
            // Add related product to cart
          },
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
