import 'package:flutter/material.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_button.dart';

class ProductFilter extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final List<String> brands;
  final List<String> selectedBrands;
  final String? selectedSortOption;
  final Function(Map<String, dynamic>) onApplyFilter;
  final VoidCallback onResetFilter;

  const ProductFilter({
    super.key,
    this.minPrice = 0,
    this.maxPrice = 100000000,
    required this.brands,
    this.selectedBrands = const [],
    this.selectedSortOption,
    required this.onApplyFilter,
    required this.onResetFilter,
  });

  @override
  State<ProductFilter> createState() => _ProductFilterState();
}

class _ProductFilterState extends State<ProductFilter> {
  late RangeValues _currentRangeValues;
  late List<String> _selectedBrands;
  String? _selectedSortOption;

  final List<String> _sortOptions = [
    'Giá tăng dần',
    'Giá giảm dần',
    'Mới nhất',
    'Bán chạy',
    'Đánh giá cao nhất',
  ];

  @override
  void initState() {
    super.initState();
    _currentRangeValues = RangeValues(
      widget.minPrice,
      widget.maxPrice > 0 ? widget.maxPrice : 100000000,
    );
    _selectedBrands = List.from(widget.selectedBrands);
    _selectedSortOption = widget.selectedSortOption;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bộ lọc',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          // Giá
          Text(
            'Khoảng giá',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          RangeSlider(
            values: _currentRangeValues,
            min: widget.minPrice,
            max: widget.maxPrice,
            divisions: 100,
            labels: RangeLabels(
              '${_formatCurrency(_currentRangeValues.start.round())} VND',
              '${_formatCurrency(_currentRangeValues.end.round())} VND',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatCurrency(_currentRangeValues.start.round())} VND',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${_formatCurrency(_currentRangeValues.end.round())} VND',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Thương hiệu
          if (widget.brands.isNotEmpty) ...[
            Text(
              'Thương hiệu',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  widget.brands.map((brand) {
                    final isSelected = _selectedBrands.contains(brand);
                    return FilterChip(
                      label: Text(brand),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedBrands.add(brand);
                          } else {
                            _selectedBrands.remove(brand);
                          }
                        });
                      },
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: theme.colorScheme.primary,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Sắp xếp
          Text(
            'Sắp xếp theo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _sortOptions.map((option) {
                  final isSelected = _selectedSortOption == option;
                  return ChoiceChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSortOption = selected ? option : null;
                      });
                    },
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Đặt lại',
                  onPressed: () {
                    setState(() {
                      _currentRangeValues = RangeValues(
                        widget.minPrice,
                        widget.maxPrice,
                      );
                      _selectedBrands = [];
                      _selectedSortOption = null;
                    });
                    widget.onResetFilter();
                  },
                  type: ButtonType.outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Áp dụng',
                  onPressed: () {
                    final Map<String, dynamic> filters = {
                      'minPrice': _currentRangeValues.start,
                      'maxPrice': _currentRangeValues.end,
                      'brands': _selectedBrands,
                      'sortOption': _selectedSortOption,
                    };
                    widget.onApplyFilter(filters);
                    Navigator.pop(context);
                  },
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
