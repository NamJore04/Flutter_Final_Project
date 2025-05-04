import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'order_confirmation_screen.dart';

enum CheckoutStep {
  shipping,
  payment,
  review,
}

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';

  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  CheckoutStep _currentStep = CheckoutStep.shipping;

  // Giả lập dữ liệu địa chỉ
  final _addresses = [
    {
      'id': 'address-001',
      'name': 'Nguyễn Văn A',
      'phone': '0987654321',
      'address': '123 Đường ABC, Phường XYZ, Quận 1',
      'city': 'TP. Hồ Chí Minh',
      'isDefault': true,
    },
    {
      'id': 'address-002',
      'name': 'Nguyễn Văn A',
      'phone': '0987654321',
      'address': '456 Đường DEF, Phường UVW, Quận 2',
      'city': 'TP. Hồ Chí Minh',
      'isDefault': false,
    },
  ];

  // Giả lập dữ liệu phương thức thanh toán
  final _paymentMethods = [
    {
      'id': 'payment-001',
      'name': 'Thanh toán khi nhận hàng (COD)',
      'icon': Icons.money,
      'isDefault': true,
    },
    {
      'id': 'payment-002',
      'name': 'Thẻ tín dụng/Ghi nợ',
      'icon': Icons.credit_card,
      'isDefault': false,
    },
    {
      'id': 'payment-003',
      'name': 'Ví MoMo',
      'icon': Icons.account_balance_wallet,
      'isDefault': false,
    },
    {
      'id': 'payment-004',
      'name': 'Chuyển khoản ngân hàng',
      'icon': Icons.account_balance,
      'isDefault': false,
    },
  ];

  String? _selectedAddressId;
  String? _selectedPaymentMethodId;

  @override
  void initState() {
    super.initState();

    // Thiết lập giá trị mặc định
    _selectedAddressId = _addresses
        .firstWhere((address) => address['isDefault'] == true)['id'] as String;
    _selectedPaymentMethodId = _paymentMethods
        .firstWhere((method) => method['isDefault'] == true)['id'] as String;

    // Cập nhật địa chỉ giao hàng trong CartProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.setShippingAddress(_selectedAddressId!);
    });
  }

  void _goToNextStep() {
    setState(() {
      switch (_currentStep) {
        case CheckoutStep.shipping:
          _currentStep = CheckoutStep.payment;
          break;
        case CheckoutStep.payment:
          _currentStep = CheckoutStep.review;
          break;
        case CheckoutStep.review:
          _placeOrder();
          break;
      }
    });
  }

  void _goBack() {
    setState(() {
      switch (_currentStep) {
        case CheckoutStep.shipping:
          Navigator.of(context).pop();
          break;
        case CheckoutStep.payment:
          _currentStep = CheckoutStep.shipping;
          break;
        case CheckoutStep.review:
          _currentStep = CheckoutStep.payment;
          break;
      }
    });
  }

  void _placeOrder() {
    // Ở đây sẽ gọi API để tạo đơn hàng
    // Sau khi tạo thành công, chuyển đến màn hình xác nhận

    // Giả lập cho phát triển
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(
        OrderConfirmationScreen.routeName,
        arguments: {
          'orderId': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
          'addressId': _selectedAddressId,
          'paymentMethodId': _selectedPaymentMethodId,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: Column(
        children: [
          // Stepper
          _buildStepper(),

          // Nội dung bước hiện tại
          Expanded(
            child: _currentStep == CheckoutStep.shipping
                ? _buildShippingStep()
                : _currentStep == CheckoutStep.payment
                    ? _buildPaymentStep()
                    : _buildReviewStep(),
          ),

          // Nút tiếp tục
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${cartProvider.total.toStringAsFixed(0)}đ',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _goToNextStep,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    _currentStep == CheckoutStep.review
                        ? 'ĐẶT HÀNG'
                        : 'TIẾP TỤC',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hiển thị indicator khi đang xử lý
          if (cartProvider.isLoading) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepItem(
            step: CheckoutStep.shipping,
            title: 'Địa chỉ',
            icon: Icons.location_on_outlined,
          ),
          _buildStepDivider(
            isActive: _currentStep == CheckoutStep.payment ||
                _currentStep == CheckoutStep.review,
          ),
          _buildStepItem(
            step: CheckoutStep.payment,
            title: 'Thanh toán',
            icon: Icons.payment_outlined,
          ),
          _buildStepDivider(
            isActive: _currentStep == CheckoutStep.review,
          ),
          _buildStepItem(
            step: CheckoutStep.review,
            title: 'Xác nhận',
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required CheckoutStep step,
    required String title,
    required IconData icon,
  }) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep.index > step.index;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Chỉ cho phép quay lại các bước trước
          if (_currentStep.index > step.index) {
            setState(() {
              _currentStep = step;
            });
          }
        },
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive || isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.2),
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: isActive || isCompleted
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive || isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDivider({required bool isActive}) {
    return Container(
      width: 30,
      height: 1,
      color: isActive
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.primary.withOpacity(0.2),
    );
  }

  Widget _buildShippingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn địa chỉ giao hàng',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16.0),

          // Danh sách địa chỉ
          ..._addresses.map((address) => _buildAddressItem(address)),

          // Nút thêm địa chỉ mới
          const SizedBox(height: 16.0),
          OutlinedButton.icon(
            onPressed: () {
              // Mở màn hình thêm địa chỉ mới
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm địa chỉ mới'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(Map<String, dynamic> address) {
    final isSelected = _selectedAddressId == address['id'];
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 2.0,
        ),
      ),
      child: RadioListTile<String>(
        value: address['id'] as String,
        groupValue: _selectedAddressId,
        onChanged: (value) {
          setState(() {
            _selectedAddressId = value;
          });

          // Cập nhật địa chỉ giao hàng trong CartProvider
          final cartProvider =
              Provider.of<CartProvider>(context, listen: false);
          cartProvider.setShippingAddress(value!);
        },
        title: Text(
          address['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address['phone'] as String),
            Text(address['address'] as String),
            Text(address['city'] as String),
            if (address['isDefault'] == true)
              Container(
                margin: const EdgeInsets.only(top: 4.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  'Mặc định',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        isThreeLine: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        selected: isSelected,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn phương thức thanh toán',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16.0),

          // Danh sách phương thức thanh toán
          ..._paymentMethods.map((method) => _buildPaymentMethodItem(method)),

          // Chính sách thanh toán
          const SizedBox(height: 24.0),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chính sách thanh toán',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '• Thanh toán khi nhận hàng (COD): Kiểm tra hàng trước khi thanh toán\n'
                  '• Thẻ tín dụng/Ghi nợ: Thanh toán online qua cổng thanh toán bảo mật\n'
                  '• Ví MoMo: Quét mã QR hoặc đăng nhập tài khoản MoMo để thanh toán\n'
                  '• Chuyển khoản ngân hàng: Chuyển khoản theo thông tin được cung cấp',
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethodId == method['id'];
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 2.0,
        ),
      ),
      child: RadioListTile<String>(
        value: method['id'] as String,
        groupValue: _selectedPaymentMethodId,
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethodId = value;
          });
        },
        title: Text(
          method['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        secondary: Icon(
          method['icon'] as IconData,
          color: theme.colorScheme.primary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        selected: isSelected,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildReviewStep() {
    final cartProvider = Provider.of<CartProvider>(context);
    final theme = Theme.of(context);

    // Lấy thông tin địa chỉ đã chọn
    final selectedAddress = _addresses.firstWhere(
      (address) => address['id'] == _selectedAddressId,
      orElse: () => _addresses.first,
    );

    // Lấy thông tin phương thức thanh toán đã chọn
    final selectedPaymentMethod = _paymentMethods.firstWhere(
      (method) => method['id'] == _selectedPaymentMethodId,
      orElse: () => _paymentMethods.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xác nhận đơn hàng',
            style: theme.textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),

          // Thông tin giao hàng
          _buildSectionCard(
            title: 'Thông tin giao hàng',
            icon: Icons.location_on_outlined,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedAddress['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(selectedAddress['phone'] as String),
                Text(selectedAddress['address'] as String),
                Text(selectedAddress['city'] as String),
              ],
            ),
            onEditPressed: () {
              setState(() {
                _currentStep = CheckoutStep.shipping;
              });
            },
          ),

          // Phương thức thanh toán
          _buildSectionCard(
            title: 'Phương thức thanh toán',
            icon: Icons.payment_outlined,
            content: Row(
              children: [
                Icon(
                  selectedPaymentMethod['icon'] as IconData,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Text(selectedPaymentMethod['name'] as String),
              ],
            ),
            onEditPressed: () {
              setState(() {
                _currentStep = CheckoutStep.payment;
              });
            },
          ),

          // Danh sách sản phẩm
          _buildSectionCard(
            title: 'Sản phẩm đã chọn',
            icon: Icons.shopping_bag_outlined,
            content: Column(
              children: [
                ...cartProvider.cart!.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Image.network(
                              item.image,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'SL: ${item.quantity} x ${item.price.toStringAsFixed(0)}đ',
                                  style: const TextStyle(fontSize: 12.0),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item.totalPrice.toStringAsFixed(0)}đ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tạm tính'),
                    Text('${cartProvider.subtotal.toStringAsFixed(0)}đ'),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Giảm giá'),
                    Text(
                      '-${cartProvider.couponDiscount.toStringAsFixed(0)}đ',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Phí vận chuyển'),
                    cartProvider.shipping == 0
                        ? Text(
                            'Miễn phí',
                            style: TextStyle(color: theme.colorScheme.primary),
                          )
                        : Text('${cartProvider.shipping.toStringAsFixed(0)}đ'),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Thuế'),
                    Text('${cartProvider.tax.toStringAsFixed(0)}đ'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng cộng',
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${cartProvider.total.toStringAsFixed(0)}đ',
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onEditPressed: () {
              Navigator.of(context).pop();
            },
          ),

          // Ghi chú
          const SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Ghi chú (tùy chọn)',
              hintText: 'Nhập ghi chú cho đơn hàng',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            maxLines: 3,
          ),

          // Điều khoản và điều kiện
          const SizedBox(height: 16.0),
          Row(
            children: [
              Checkbox(
                value: true,
                onChanged: (value) {},
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'Tôi đã đọc và đồng ý với ',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    children: [
                      TextSpan(
                        text: 'điều khoản và điều kiện',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget content,
    required VoidCallback onEditPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onEditPressed,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Sửa'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8.0),
            content,
          ],
        ),
      ),
    );
  }
}
