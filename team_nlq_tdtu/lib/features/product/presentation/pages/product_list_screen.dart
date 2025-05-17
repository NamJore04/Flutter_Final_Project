import 'package:flutter/material.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_text_field.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';
import 'package:team_nlq_tdtu/core/widgets/product_card.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/category_model.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/product_model.dart';
import 'package:team_nlq_tdtu/features/product/presentation/widgets/category_card.dart';
import 'package:team_nlq_tdtu/features/product/presentation/widgets/product_filter_widget.dart';
import 'package:go_router/go_router.dart';

class ProductListScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ProductListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Product> _products = [];
  List<Category> _categories = [];

  String? _selectedCategoryId;
  double _minPrice = 0;
  double _maxPrice = 100000000;
  List<String> _brands = [];
  List<String> _selectedBrands = [];
  String? _sortOption;

  int _currentPage = 1;
  bool _hasMorePages = true;
  final int _pageSize = 10;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;

    _scrollController.addListener(_scrollListener);

    // Mock data for initial UI - Replace with actual API calls
    _loadMockData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMorePages) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadMockData() async {
    // In real implementation, replace with API calls to your repository
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      // Mock categories
      _categories = List.generate(
        8,
        (index) => Category(
          id: 'cat_$index',
          name: 'Danh mục ${index + 1}',
          imageUrl: index % 3 == 0 ? null : 'https://via.placeholder.com/150',
          productCount: (index + 1) * 10,
          featured: index < 3,
        ),
      );

      // Mock products
      _products = List.generate(
        15,
        (index) => Product(
          id: 'prod_$index',
          name:
              'Sản phẩm ${index + 1} với tên dài hơn một chút để test giao diện',
          price: 1000000 + (index * 500000),
          originalPrice: index % 3 == 0 ? 1500000 + (index * 500000) : null,
          description: 'Mô tả sản phẩm ${index + 1}',
          images: ['https://via.placeholder.com/300'],
          brand: 'Thương hiệu ${(index % 5) + 1}',
          categoryId: 'cat_${index % 8}',
          stock: index * 10,
          rating: (index % 5) + 1,
          reviewCount: index * 5,
          isOnSale: index % 3 == 0,
        ),
      );

      // Collect unique brands
      final Set<String> uniqueBrands = {};
      for (var product in _products) {
        if (product.brand != null) {
          uniqueBrands.add(product.brand!);
        }
      }
      _brands = uniqueBrands.toList();

      _isLoading = false;
    });
  }

  void _loadMoreProducts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Mock loading more data
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _currentPage++;

      // Add more mock products
      final newProducts = List.generate(
        5,
        (index) => Product(
          id: 'prod_${_products.length + index}',
          name: 'Sản phẩm ${_products.length + index + 1}',
          price: 1000000 + (index * 500000),
          originalPrice: index % 3 == 0 ? 1500000 + (index * 500000) : null,
          description: 'Mô tả sản phẩm ${_products.length + index + 1}',
          images: ['https://via.placeholder.com/300'],
          brand: 'Thương hiệu ${(index % 5) + 1}',
          categoryId: 'cat_${index % 8}',
          stock: index * 10,
          rating: (index % 5) + 1,
          reviewCount: index * 5,
          isOnSale: index % 3 == 0,
        ),
      );

      _products.addAll(newProducts);
      _isLoadingMore = false;

      // Check if we have more pages (this would be based on API response in real implementation)
      if (_currentPage >= 3) {
        _hasMorePages = false;
      }
    });
  }

  void _onSearch(String query) {
    // Implement search logic here
    setState(() {
      _isLoading = true;
    });

    // Mock search implementation
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _products = _products
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _isLoading = false;
      });
    });
  }

  void _onCategorySelected(String categoryId) {
    if (_selectedCategoryId == categoryId) {
      setState(() {
        _selectedCategoryId = null;
      });
    } else {
      setState(() {
        _selectedCategoryId = categoryId;
        _isLoading = true;
      });

      // Mock category filter
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _products = _products
              .where((product) => product.categoryId == categoryId)
              .toList();
          _isLoading = false;
        });
      });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => ProductFilter(
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          brands: _brands,
          selectedBrands: _selectedBrands,
          selectedSortOption: _sortOption,
          onApplyFilter: _applyFilter,
          onResetFilter: _resetFilter,
        ),
      ),
    );
  }

  void _applyFilter(Map<String, dynamic> filters) {
    setState(() {
      _minPrice = filters['minPrice'];
      _maxPrice = filters['maxPrice'];
      _selectedBrands = filters['brands'];
      _sortOption = filters['sortOption'];
      _isLoading = true;
    });

    // Mock filter implementation
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (_selectedBrands.isNotEmpty) {
          _products = _products
              .where((product) =>
                  product.brand != null &&
                  _selectedBrands.contains(product.brand))
              .toList();
        }

        _products = _products
            .where((product) =>
                product.price >= _minPrice && product.price <= _maxPrice)
            .toList();

        if (_sortOption != null) {
          if (_sortOption == 'Giá tăng dần') {
            _products.sort((a, b) => a.price.compareTo(b.price));
          } else if (_sortOption == 'Giá giảm dần') {
            _products.sort((a, b) => b.price.compareTo(a.price));
          } else if (_sortOption == 'Mới nhất') {
            // In real implementation, this would be based on date
            _products.shuffle();
          } else if (_sortOption == 'Bán chạy') {
            // In real implementation, this would be based on sales data
            _products.shuffle();
          } else if (_sortOption == 'Đánh giá cao nhất') {
            _products.sort((a, b) => b.rating.compareTo(a.rating));
          }
        }

        _isLoading = false;
      });
    });
  }

  void _resetFilter() {
    setState(() {
      _minPrice = 0;
      _maxPrice = 100000000;
      _selectedBrands = [];
      _sortOption = null;
    });

    // Reload products with no filters
    _loadMockData();
  }

  void _addToCart(Product product) {
    // Show a snackbar when product is added to cart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} đã được thêm vào giỏ hàng'),
        action: SnackBarAction(
          label: 'XEM GIỎ',
          onPressed: () {
            // Navigate to cart
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  void _onBackPressed() {
    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'Sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _searchController,
              labelText: 'Tìm kiếm sản phẩm',
              hintText: 'Nhập tên sản phẩm...',
              prefixIcon: const Icon(Icons.search),
              onChanged: _onSearch,
            ),
          ),

          // Categories horizontal list
          if (_categories.isNotEmpty) ...[
            Container(
              height: 120,
              padding: const EdgeInsets.only(left: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return CategoryCard(
                    category: category,
                    isSelected: _selectedCategoryId == category.id,
                    onTap: () => _onCategorySelected(category.id),
                    width: 100,
                    height: 120,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Products grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: LoadingIndicator(
                      size: LoadingSize.large,
                      message: 'Đang tải sản phẩm...',
                    ),
                  )
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy sản phẩm',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vui lòng thử lại với bộ lọc khác',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMockData,
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _products.length + (_hasMorePages ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _products.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final product = _products[index];
                            return ProductCard(
                              id: product.id,
                              name: product.name,
                              price: product.price,
                              originalPrice: product.originalPrice,
                              imageUrl: product.images.isNotEmpty
                                  ? product.images[0]
                                  : null,
                              brand: product.brand,
                              isOnSale: product.isOnSale,
                              onTap: () {
                                // Navigate to product details
                              },
                              onAddToCart: () => _addToCart(product),
                              isInCart: false, // Replace with actual cart check
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
