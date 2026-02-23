import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';

class SortSheet extends StatelessWidget {
  const SortSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildItem(context, 'Relevance', SortMode.relevance, searchProvider.sortMode),
          _buildItem(context, 'Price: Low to High', SortMode.priceLow, searchProvider.sortMode),
          _buildItem(context, 'Price: High to Low', SortMode.priceHigh, searchProvider.sortMode),
          _buildItem(context, 'Newest Arrivals', SortMode.newest, searchProvider.sortMode),
          _buildItem(context, 'Nearest First', SortMode.nearest, searchProvider.sortMode),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, SortMode mode, SortMode current) {
    final isSelected = mode == current;
    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        context.read<SearchProvider>().setSort(mode);
        Navigator.pop(context);
      },
    );
  }
}
