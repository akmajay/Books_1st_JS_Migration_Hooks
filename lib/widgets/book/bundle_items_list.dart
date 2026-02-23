import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/auth_service.dart';

class BundleItemsList extends StatefulWidget {
  final String bundleId;
  const BundleItemsList({super.key, required this.bundleId});

  @override
  State<BundleItemsList> createState() => _BundleItemsListState();
}

class _BundleItemsListState extends State<BundleItemsList> {
  List<RecordModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBundleItems();
  }

  Future<void> _fetchBundleItems() async {
    try {
      final pb = AuthService().pb;
      final result = await pb.collection('bundle_items').getList(
        filter: 'bundle = "${widget.bundleId}"',
      );
      if (mounted) {
        setState(() {
          _items = result.items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
    if (_items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
             '📦 Bundle Materials (${_items.length} sessions)',
             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _items.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = _items[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.book, size: 20),
              ),
              title: Text(item.getStringValue('title'), style: const TextStyle(fontSize: 14)),
              subtitle: Text(item.getStringValue('author'), style: const TextStyle(fontSize: 12)),
              trailing: _buildSmallChip(item.getStringValue('condition')),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSmallChip(String condition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        condition.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
