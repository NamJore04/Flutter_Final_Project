import 'package:flutter/material.dart';
import 'package:team_nlq_tdtu/core/routes/app_router.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_button.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  bool _isLoading = false;
  bool _isEditingAddress = false;
  int? _editingIndex;

  // Mock address data
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': 'addr1',
      'name': 'Nguyễn Văn A',
      'phone': '0987654321',
      'address': '123 Đường Lê Lợi, Phường Bến Nghé',
      'district': 'Quận 1',
      'city': 'TP. Hồ Chí Minh',
      'isDefault': true,
    },
    {
      'id': 'addr2',
      'name': 'Nguyễn Văn A',
      'phone': '0987654321',
      'address': '456 Đường Nguyễn Huệ, Phường Bến Nghé',
      'district': 'Quận 1',
      'city': 'TP. Hồ Chí Minh',
      'isDefault': false,
    },
  ];

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _addNewAddress() {
    _resetForm();
    setState(() {
      _isEditingAddress = true;
      _editingIndex = null;
    });
  }

  void _editAddress(int index) {
    final address = _addresses[index];
    _nameController.text = address['name'];
    _phoneController.text = address['phone'];
    _addressController.text = address['address'];
    _districtController.text = address['district'];
    _cityController.text = address['city'];
    _isDefault = address['isDefault'];

    setState(() {
      _isEditingAddress = true;
      _editingIndex = index;
    });
  }

  Future<void> _deleteAddress(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa địa chỉ'),
        content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
        actions: [
          TextButton(
            onPressed: () => context.safePop(),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () {
              context.safePop();
              setState(() {
                // In real app, would call API to delete
                _addresses.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa địa chỉ'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _districtController.clear();
    _cityController.clear();
    _isDefault = false;
  }

  void _cancelEdit() {
    setState(() {
      _isEditingAddress = false;
      _editingIndex = null;
    });
    _resetForm();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        final newAddress = {
          'id': _editingIndex != null
              ? _addresses[_editingIndex!]['id']
              : 'addr${_addresses.length + 1}',
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'district': _districtController.text,
          'city': _cityController.text,
          'isDefault': _isDefault,
        };

        setState(() {
          if (_isDefault) {
            // Set all addresses to non-default
            for (var address in _addresses) {
              address['isDefault'] = false;
            }
          }

          if (_editingIndex != null) {
            // Update existing address
            _addresses[_editingIndex!] = newAddress;
          } else {
            // Add new address
            _addresses.add(newAddress);
          }

          _isEditingAddress = false;
          _editingIndex = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingIndex != null
                ? 'Địa chỉ đã được cập nhật'
                : 'Đã thêm địa chỉ mới'),
            backgroundColor: Colors.green,
          ),
        );

        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ địa chỉ'),
        actions: [
          if (!_isEditingAddress)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addNewAddress,
              tooltip: 'Thêm địa chỉ mới',
            ),
        ],
      ),
      body: Stack(
        children: [
          _isEditingAddress
              ? _buildAddressForm()
              : _addresses.isEmpty
                  ? _buildEmptyState()
                  : _buildAddressList(),
          if (_isLoading) const FullScreenLoading(message: 'Đang xử lý...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Bạn chưa có địa chỉ nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Thêm địa chỉ để dễ dàng thanh toán'),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Thêm địa chỉ mới',
            onPressed: _addNewAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        address['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (address['isDefault'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Mặc định',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(address['phone']),
                const SizedBox(height: 8),
                Text(
                  '${address['address']}, ${address['district']}, ${address['city']}',
                  style: const TextStyle(height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Sửa'),
                      onPressed: () => _editAddress(index),
                    ),
                    const SizedBox(width: 8),
                    if (!address['isDefault'])
                      TextButton.icon(
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Xóa'),
                        onPressed: () => _deleteAddress(index),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    if (!address['isDefault']) const SizedBox(width: 8),
                    if (!address['isDefault'])
                      TextButton.icon(
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Đặt làm mặc định'),
                        onPressed: () {
                          setState(() {
                            for (var addr in _addresses) {
                              addr['isDefault'] = false;
                            }
                            address['isDefault'] = true;
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingIndex != null ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Họ tên',
                hintText: 'Họ tên người nhận',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateNotEmpty(value, 'họ tên'),
            ),
            const SizedBox(height: 16),

            // Phone field
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                hintText: 'Số điện thoại liên hệ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => _validateNotEmpty(value, 'số điện thoại'),
            ),
            const SizedBox(height: 16),

            // Address field
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                hintText: 'Số nhà, tên đường, phường/xã',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateNotEmpty(value, 'địa chỉ'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // District field
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: 'Quận/Huyện',
                hintText: 'Quận/Huyện',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateNotEmpty(value, 'quận/huyện'),
            ),
            const SizedBox(height: 16),

            // City field
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Tỉnh/Thành phố',
                hintText: 'Tỉnh/Thành phố',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateNotEmpty(value, 'tỉnh/thành phố'),
            ),
            const SizedBox(height: 16),

            // Default checkbox
            CheckboxListTile(
              title: const Text('Đặt làm địa chỉ mặc định'),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Hủy',
                    onPressed: _cancelEdit,
                    type: ButtonType.outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Lưu',
                    onPressed: _saveAddress,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
