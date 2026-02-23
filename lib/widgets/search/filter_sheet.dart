import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  final Map<String, dynamic> _selectedFilters = {};

  final List<Map<String, String>> _categories = [
    {'label': 'School', 'value': 'school'},
    {'label': 'College', 'value': 'college'},
    {'label': 'JEE/Eng.', 'value': 'jee_engineering'},
    {'label': 'NEET/Med.', 'value': 'neet_medical'},
    {'label': 'Govt. Exams', 'value': 'govt_upsc'},
    {'label': 'Other', 'value': 'other'},
  ];

  final List<Map<String, String>> _boards = [
    {'label': 'CBSE', 'value': 'CBSE'},
    {'label': 'ICSE', 'value': 'ICSE'},
    {'label': 'State Board', 'value': 'State Board'},
    {'label': 'IB', 'value': 'IB'},
    {'label': 'Other', 'value': 'Other'},
  ];

  final List<Map<String, String>> _conditions = [
    {'label': 'Like New', 'value': 'like_new'},
    {'label': 'Good', 'value': 'good'},
    {'label': 'Fair', 'value': 'fair'},
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<SearchProvider>();
    _selectedFilters.addAll(provider.filters);
  }

  void _onApply() {
    context.read<SearchProvider>().updateFilters(_selectedFilters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filters', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => setState(() => _selectedFilters.clear()),
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFilterSection('categories', 'Category', _categories),
                  _buildDivider(),
                  _buildFilterSection('boards', 'Board', _boards),
                  _buildDivider(),
                  _buildMultiSelectSection('classes', 'Class', ['6', '7', '8', '9', '10', '11', '12', 'Bachelor', 'Masters']),
                  _buildDivider(),
                  _buildFilterSection('conditions', 'Condition', _conditions),
                  _buildDivider(),
                  ListTile(
                    title: const Text('Only Free Books', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Switch(
                      value: _selectedFilters['price_range'] == 'free',
                      onChanged: (val) {
                        setState(() {
                          if (val) {
                            _selectedFilters['price_range'] = 'free';
                          } else {
                            _selectedFilters.remove('price_range');
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 32);

  Widget _buildFilterSection(String key, String title, List<Map<String, String>> options) {
    final List<String> current = (_selectedFilters[key] as List?)?.cast<String>() ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final value = opt['value']!;
            final label = opt['label']!;
            final isSelected = current.contains(value);
            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFilters[key] = [...current, value];
                  } else {
                    final updated = [...current]..remove(value);
                    if (updated.isEmpty) {
                      _selectedFilters.remove(key);
                    } else {
                      _selectedFilters[key] = updated;
                    }
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultiSelectSection(String key, String title, List<String> options) {
    final List<String> current = (_selectedFilters[key] as List?)?.cast<String>() ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = current.contains(opt);
            return FilterChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFilters[key] = [...current, opt];
                  } else {
                    final updated = [...current]..remove(opt);
                    if (updated.isEmpty) {
                      _selectedFilters.remove(key);
                    } else {
                      _selectedFilters[key] = updated;
                    }
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
