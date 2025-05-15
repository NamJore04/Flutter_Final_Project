import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:team_nlq_tdtu/core/routes/app_router.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_text_field.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';

class ProductsManagementScreen extends StatefulWidget {
  const ProductsManagementScreen({super.key});

  @override
  State<ProductsManagementScreen> createState() =>
      _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  bool _inStockOnly = false;
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];

  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final TextEditingController _searchController = TextEditingController();

  // Danh sách danh mục giả định
  final List<String> _categories = [
    'Tất cả',
    'Điện thoại',
    'Laptop',
    'Máy tính bảng',
    'Phụ kiện',
    'Khác'
  ];

  @override
  void initState() {
    super.initState();
    _loadMockProducts();

    _searchController.addListener(() {
      _filterProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMockProducts() async {
    // Giả lập thời gian tải dữ liệu
    await Future.delayed(const Duration(seconds: 1));

    // Tạo dữ liệu sản phẩm giả lập
    _products = List.generate(20, (index) => _createMockProduct(index));
    _filteredProducts = List.from(_products);

    setState(() {
      _isLoading = false;
    });
  }

  ProductModel _createMockProduct(int index) {
    // Danh sách tên sản phẩm giả định
    final List<String> productNames = [
      'iPhone 15 Pro Max',
      'Samsung Galaxy S23 Ultra',
      'MacBook Pro 14"',
      'Dell XPS 13',
      'iPad Pro 12.9"',
      'Samsung Galaxy Tab S9',
      'AirPods Pro 2',
      'Galaxy Buds Pro 2',
      'Apple Watch Series 9',
      'Xiaomi Mi Watch',
    ];

    // Danh sách danh mục giả định
    final List<String> categories = [
      'Điện thoại',
      'Điện thoại',
      'Laptop',
      'Laptop',
      'Máy tính bảng',
      'Máy tính bảng',
      'Phụ kiện',
      'Phụ kiện',
      'Phụ kiện',
      'Phụ kiện',
    ];

    // Lấy vị trí cho danh sách sản phẩm
    final int nameIndex = index % productNames.length;

    // Tạo giá bán với một số biến động
    final double price =
        5000000 + (nameIndex * 3000000) + (index % 3 == 0 ? 2000000 : 0);

    // Tạo số lượng tồn
    final int stockAmount = index % 5 == 0 ? 0 : (10 + index % 50);

    // Tạo ngày tạo sản phẩm
    final DateTime createdAt =
        DateTime.now().subtract(Duration(days: 10 + index % 100));

    // Tạo đánh giá trung bình và tổng số đánh giá
    final double avgRating = 3.5 + (index % 3) * 0.5;
    final int reviewCount = 10 + index * 5;

    return ProductModel(
      id: 'PRD${10000 + index}',
      name: productNames[nameIndex],
      description:
          'Đây là mô tả cho sản phẩm ${productNames[nameIndex]}. Sản phẩm này có nhiều tính năng hấp dẫn và chất lượng cao.',
      price: price,
      discountPrice: index % 3 == 0 ? price * 0.9 : null,
      category: categories[nameIndex],
      images: [
        'https://via.placeholder.com/500x500?text=${Uri.encodeComponent(productNames[nameIndex])}',
      ],
      stockAmount: stockAmount,
      createdAt: createdAt,
      isActive: index % 7 != 0,
      avgRating: avgRating,
      reviewCount: reviewCount,
    );
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        // Lọc theo tìm kiếm
        final nameMatch =
            product.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final idMatch =
            product.id.toLowerCase().contains(_searchQuery.toLowerCase());
        final searchMatch = nameMatch || idMatch;

        // Lọc theo danh mục
        final categoryMatch = _selectedCategory == 'Tất cả' ||
            product.category == _selectedCategory;

        // Lọc theo tình trạng tồn kho
        final stockMatch = !_inStockOnly || product.stockAmount > 0;

        return searchMatch && categoryMatch && stockMatch;
      }).toList();
    });
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _isLoading = true;
    });

    await _loadMockProducts();
    _filterProducts();
  }

  void _showProductOptionsDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quản lý: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Xem chi tiết'),
              onTap: () {
                Navigator.pop(context);
                // Chuyển đến trang chi tiết sản phẩm
                context.pushNamed(
                  AppRouter.productDetail,
                  pathParameters: {'id': product.id},
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Thêm logic để chỉnh sửa sản phẩm
              },
            ),
            ListTile(
              leading: Icon(
                product.isActive ? Icons.unpublished : Icons.check_circle,
                color: product.isActive ? Colors.red : Colors.green,
              ),
              title: Text(product.isActive ? 'Hủy xuất bản' : 'Xuất bản'),
              onTap: () {
                setState(() {
                  // Cập nhật trạng thái sản phẩm
                  final index = _products.indexOf(product);
                  if (index != -1) {
                    // Cập nhật sản phẩm với trạng thái mới
                    final updatedProduct =
                        product.copyWith(isActive: !product.isActive);
                    _products[index] = updatedProduct;

                    // Cập nhật danh sách đã lọc
                    final filteredIndex = _filteredProducts.indexOf(product);
                    if (filteredIndex != -1) {
                      _filteredProducts[filteredIndex] = updatedProduct;
                    }
                  }
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog(product);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc chắn muốn xóa sản phẩm "${product.name}" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Xóa sản phẩm khỏi danh sách
                _products.remove(product);
                _filteredProducts.remove(product);
              });
              Navigator.pop(context);

              // Hiển thị thông báo sau khi xóa
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa sản phẩm "${product.name}"'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProducts,
            tooltip: 'Làm mới dữ liệu',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: LoadingIndicator(
                size: LoadingSize.large,
                message: 'Đang tải dữ liệu sản phẩm...',
              ),
            )
          : Column(
              children: [
                _buildSearchAndFilters(),
                _buildProductCountInfo(),
                const Divider(height: 1),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : _buildProductList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Thêm logic để thêm sản phẩm mới
        },
        tooltip: 'Thêm sản phẩm mới',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ô tìm kiếm
          CustomTextField(
            controller: _searchController,
            hintText: 'Tìm kiếm theo tên hoặc mã sản phẩm',
            labelText: 'Tìm kiếm sản phẩm',
            prefixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _filterProducts();
                      });
                    },
                  )
                : null,
          ),

          const SizedBox(height: 16),

          // Bộ lọc
          Row(
            children: [
              // Lọc theo danh mục
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                        _filterProducts();
                      });
                    }
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Kiểm tra tình trạng tồn kho
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Còn hàng'),
                  value: _inStockOnly,
                  onChanged: (value) {
                    setState(() {
                      _inStockOnly = value ?? false;
                      _filterProducts();
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCountInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hiển thị ${_filteredProducts.length} / ${_products.length} sản phẩm',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (_filteredProducts.isNotEmpty)
            Row(
              children: [
                const Text('Sắp xếp:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: 'newest',
                  items: const [
                    DropdownMenuItem(
                      value: 'newest',
                      child: Text('Mới nhất'),
                    ),
                    DropdownMenuItem(
                      value: 'oldest',
                      child: Text('Cũ nhất'),
                    ),
                    DropdownMenuItem(
                      value: 'price_high',
                      child: Text('Giá cao → thấp'),
                    ),
                    DropdownMenuItem(
                      value: 'price_low',
                      child: Text('Giá thấp → cao'),
                    ),
                  ],
                  onChanged: (value) {
                    // TODO: Thêm logic sắp xếp
                  },
                  underline: Container(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80), // Khoảng cách với FAB
      itemCount: _filteredProducts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductItem(product);
      },
    );
  }

  Widget _buildProductItem(ProductModel product) {
    final hasDiscount = product.discountPrice != null;
    final priceText = _currencyFormat.format(product.price);
    final discountPriceText =
        hasDiscount ? _currencyFormat.format(product.discountPrice) : null;

    return InkWell(
      onTap: () => _showProductOptionsDialog(product),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.images.first,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),

            const SizedBox(width: 16),

            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID sản phẩm
                  Text(
                    product.id,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Tên sản phẩm
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Danh mục
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Trạng thái sản phẩm
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.isActive
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.isActive ? 'Đang bán' : 'Ẩn',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.isActive
                                ? Colors.green.shade900
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Hàng cuối: Giá và tồn kho
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Giá bán
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Giá gốc (đã gạch ngang nếu có giảm giá)
                          if (hasDiscount)
                            Text(
                              priceText,
                              style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),

                          // Giá sau giảm giá hoặc giá gốc
                          Text(
                            hasDiscount ? discountPriceText! : priceText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: hasDiscount ? Colors.red : Colors.black,
                            ),
                          ),
                        ],
                      ),

                      // Thông tin tồn kho
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product.avgRating.toStringAsFixed(1)} (${product.reviewCount})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.stockAmount > 0
                                ? 'Còn ${product.stockAmount} sản phẩm'
                                : 'Hết hàng',
                            style: TextStyle(
                              fontSize: 12,
                              color: product.stockAmount > 0
                                  ? Colors.green.shade700
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Nút tùy chọn
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showProductOptionsDialog(product),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedCategory != 'Tất cả' ||
                    _inStockOnly
                ? 'Không tìm thấy sản phẩm phù hợp với bộ lọc'
                : 'Chưa có sản phẩm nào',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedCategory != 'Tất cả' ||
                    _inStockOnly
                ? 'Hãy thử thay đổi bộ lọc hoặc từ khóa tìm kiếm'
                : 'Hãy thêm sản phẩm đầu tiên của bạn',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty ||
              _selectedCategory != 'Tất cả' ||
              _inStockOnly)
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'Tất cả';
                  _inStockOnly = false;
                  _filterProducts();
                });
              },
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Xóa bộ lọc'),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Thêm logic để thêm sản phẩm mới
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm sản phẩm mới'),
            ),
        ],
      ),
    );
  }
}
