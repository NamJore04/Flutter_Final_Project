import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_text_field.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  bool _isLoading = true;
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  String _searchQuery = '';
  UserRole? _selectedRole;
  bool _showOnlyActive = false;

  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadMockData();

    _searchController.addListener(() {
      _filterUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMockData() async {
    // Giả lập thời gian tải dữ liệu
    await Future.delayed(const Duration(seconds: 1));

    // Tạo dữ liệu giả
    final List<UserModel> mockUsers = [
      UserModel(
        id: '001',
        name: 'Nguyễn Văn A',
        email: 'nguyenvana@gmail.com',
        phoneNumber: '0901234567',
        address: 'Số 123 Đường ABC, Quận 1, TP.HCM',
        role: UserRole.customer,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        orderCount: 5,
        totalSpent: 7500000,
      ),
      UserModel(
        id: '002',
        name: 'Trần Thị B',
        email: 'tranthib@gmail.com',
        phoneNumber: '0912345678',
        address: 'Số 456 Đường XYZ, Quận 2, TP.HCM',
        role: UserRole.customer,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        orderCount: 3,
        totalSpent: 5200000,
      ),
      UserModel(
        id: '003',
        name: 'Lê Văn C',
        email: 'levanc@gmail.com',
        phoneNumber: '0923456789',
        address: 'Số 789 Đường DEF, Quận 3, TP.HCM',
        role: UserRole.customer,
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        orderCount: 1,
        totalSpent: 2000000,
      ),
      UserModel(
        id: '004',
        name: 'Phạm Thị D',
        email: 'phamthid@gmail.com',
        phoneNumber: '0934567890',
        address: 'Số 101 Đường GHI, Quận 4, TP.HCM',
        role: UserRole.admin,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        orderCount: 0,
        totalSpent: 0,
      ),
      UserModel(
        id: '005',
        name: 'Hoàng Văn E',
        email: 'hoangvane@gmail.com',
        phoneNumber: '0945678901',
        address: 'Số 202 Đường JKL, Quận 5, TP.HCM',
        role: UserRole.staff,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 75)),
        orderCount: 0,
        totalSpent: 0,
      ),
    ];

    // Tạo thêm người dùng giả
    final List<String> firstNames = [
      'Nguyễn',
      'Trần',
      'Lê',
      'Phạm',
      'Hoàng',
      'Huỳnh',
      'Phan',
      'Vũ',
      'Võ',
      'Đặng',
      'Bùi',
      'Đỗ',
      'Hồ',
      'Ngô',
      'Dương',
      'Lý'
    ];
    final List<String> middleNames = [
      'Văn',
      'Thị',
      'Hoàng',
      'Hữu',
      'Đức',
      'Minh',
      'Quang',
      'Thành',
      'Thanh',
      'Ngọc',
      'Tuấn',
      'Anh',
      'Thu',
      'Thúy',
      'Quốc',
      'Kim'
    ];
    final List<String> lastNames = [
      'An',
      'Bình',
      'Cường',
      'Dũng',
      'Em',
      'Giang',
      'Hà',
      'Hưng',
      'Linh',
      'Mai',
      'Nam',
      'Phúc',
      'Quân',
      'Tâm',
      'Uyên',
      'Xuyến'
    ];
    final List<String> streets = [
      'Nguyễn Huệ',
      'Lê Lợi',
      'Trần Hưng Đạo',
      'Võ Văn Tần',
      'Điện Biên Phủ',
      'Cách Mạng Tháng Tám',
      'Nguyễn Văn Cừ',
      'Lý Tự Trọng'
    ];
    final List<String> districts = [
      'Quận 1',
      'Quận 2',
      'Quận 3',
      'Quận 4',
      'Quận 5',
      'Quận 6',
      'Quận 7',
      'Quận 8',
      'Quận 9',
      'Quận 10',
      'Thủ Đức'
    ];
    final List<String> cities = [
      'TP.HCM',
      'Hà Nội',
      'Đà Nẵng',
      'Cần Thơ',
      'Hải Phòng',
      'Nha Trang',
      'Vũng Tàu'
    ];

    for (int i = 6; i <= 30; i++) {
      final String firstName = firstNames[i % firstNames.length];
      final String middleName = middleNames[i % middleNames.length];
      final String lastName = lastNames[i % lastNames.length];
      final String name = '$firstName $middleName $lastName';

      final String normalizedName = name.toLowerCase().replaceAll(' ', '');
      final String email = '$normalizedName@gmail.com';

      final String phoneDigits = i.toString().padLeft(2, '0');
      final String phoneNumber =
          '09$phoneDigits${i % 10}${(i + 1) % 10}${(i + 2) % 10}${(i + 3) % 10}';

      final String streetNumber = '${(i * 10) % 300 + 1}';
      final String street = streets[i % streets.length];
      final String district = districts[i % districts.length];
      final String city = cities[i % cities.length];
      final String address = 'Số $streetNumber Đường $street, $district, $city';

      final UserRole role = i % 10 == 0
          ? UserRole.admin
          : (i % 5 == 0 ? UserRole.staff : UserRole.customer);
      final bool isActive = i % 7 != 0;

      final int daysAgo = (i * 5) % 365;
      final DateTime createdAt =
          DateTime.now().subtract(Duration(days: daysAgo));

      final int orderCount = role == UserRole.customer ? (i % 10) : 0;
      final double totalSpent =
          role == UserRole.customer ? orderCount * 1500000.0 : 0;

      mockUsers.add(
        UserModel(
          id: i.toString().padLeft(3, '0'),
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
          role: role,
          isActive: isActive,
          createdAt: createdAt,
          orderCount: orderCount,
          totalSpent: totalSpent,
        ),
      );
    }

    // Sắp xếp theo thời gian tạo mới nhất
    mockUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _users = mockUsers;
      _filteredUsers = mockUsers;
      _isLoading = false;
    });
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _selectRole(UserRole? role) {
    setState(() {
      _selectedRole = role;
      _applyFilters();
    });
  }

  void _toggleActiveFilter(bool? value) {
    setState(() {
      _showOnlyActive = value ?? false;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<UserModel> result = List.from(_users);

    // Lọc theo từ khóa tìm kiếm
    if (_searchQuery.isNotEmpty) {
      result = result.where((user) {
        return user.id.toLowerCase().contains(_searchQuery) ||
            user.name.toLowerCase().contains(_searchQuery) ||
            user.email.toLowerCase().contains(_searchQuery) ||
            user.phoneNumber.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Lọc theo vai trò
    if (_selectedRole != null) {
      result = result.where((user) => user.role == _selectedRole).toList();
    }

    // Lọc theo trạng thái hoạt động
    if (_showOnlyActive) {
      result = result.where((user) => user.isActive).toList();
    }

    setState(() {
      _filteredUsers = result;
    });
  }

  void _showUserDetailsDialog(UserModel user) {
    final numberFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thông tin người dùng: ${user.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('ID', user.id),
              _buildDetailItem('Email', user.email),
              _buildDetailItem('Số điện thoại', user.phoneNumber),
              _buildDetailItem('Địa chỉ', user.address),
              _buildDetailItem('Vai trò', _getRoleName(user.role)),
              _buildDetailItem('Trạng thái',
                  user.isActive ? 'Đang hoạt động' : 'Bị vô hiệu hóa'),
              _buildDetailItem('Ngày tạo', _dateFormat.format(user.createdAt)),
              if (user.role == UserRole.customer) ...[
                const SizedBox(height: 16),
                Text(
                  'Thông tin mua hàng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _buildDetailItem('Số đơn hàng', user.orderCount.toString()),
                _buildDetailItem(
                    'Tổng chi tiêu', numberFormat.format(user.totalSpent)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          if (user.role !=
              UserRole.admin) // Không cho phép vô hiệu hóa tài khoản admin
            ElevatedButton(
              onPressed: () {
                _toggleUserStatus(user);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    user.isActive ? Colors.redAccent : Colors.green,
              ),
              child: Text(user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(UserModel user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      setState(() {
        final updatedUser = _users[index].copyWith(isActive: !user.isActive);
        _users[index] = updatedUser;
        _applyFilters(); // Cập nhật lại danh sách đã lọc
      });

      // Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Đã ${user.isActive ? 'vô hiệu hóa' : 'kích hoạt'} tài khoản của ${user.name}'),
        ),
      );
    }
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.staff:
        return 'Nhân viên';
      case UserRole.customer:
        return 'Khách hàng';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.staff:
        return Colors.blue;
      case UserRole.customer:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý người dùng'),
        ),
        body: const Center(
          child: LoadingIndicator(
            size: LoadingSize.large,
            message: 'Đang tải danh sách người dùng...',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm và bộ lọc
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  controller: _searchController,
                  hintText: 'Tìm theo tên, email hoặc số điện thoại',
                  labelText: 'Tìm kiếm người dùng',
                  prefixIcon: const Icon(Icons.search),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('Tất cả'),
                              selected: _selectedRole == null,
                              onSelected: (_) => _selectRole(null),
                            ),
                            const SizedBox(width: 8),
                            ...UserRole.values.map((role) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(_getRoleName(role)),
                                  selected: role == _selectedRole,
                                  onSelected: (_) => _selectRole(role),
                                  backgroundColor:
                                      _getRoleColor(role).withOpacity(0.1),
                                  selectedColor:
                                      _getRoleColor(role).withOpacity(0.2),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _showOnlyActive,
                          onChanged: _toggleActiveFilter,
                        ),
                        const Text('Chỉ hiện hoạt động'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Số lượng người dùng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Tổng số ${_filteredUsers.length} người dùng',
                  style: theme.textTheme.titleMedium,
                ),
                if (_searchQuery.isNotEmpty ||
                    _selectedRole != null ||
                    _showOnlyActive) ...[
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Xóa bộ lọc'),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _selectedRole = null;
                        _showOnlyActive = false;
                        _filteredUsers = _users;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),

          // Danh sách người dùng
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy người dùng nào',
                      style: theme.textTheme.titleMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserItem(user, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(UserModel user, ThemeData theme) {
    final numberFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showUserDetailsDialog(user),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: _getRoleColor(user.role),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getRoleColor(user.role).withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            _getRoleName(user.role),
                            style: TextStyle(
                              color: _getRoleColor(user.role),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(user.phoneNumber),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          user.isActive
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          size: 16,
                          color: user.isActive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.isActive ? 'Đang hoạt động' : 'Bị vô hiệu hóa',
                          style: TextStyle(
                            color: user.isActive ? Colors.green : Colors.red,
                          ),
                        ),
                        const Spacer(),
                        if (user.role == UserRole.customer)
                          Text(
                            '${user.orderCount} đơn • ${numberFormat.format(user.totalSpent)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum UserRole {
  admin,
  staff,
  customer,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final int orderCount;
  final double totalSpent;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.orderCount = 0,
    this.totalSpent = 0,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    int? orderCount,
    double? totalSpent,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      orderCount: orderCount ?? this.orderCount,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}
