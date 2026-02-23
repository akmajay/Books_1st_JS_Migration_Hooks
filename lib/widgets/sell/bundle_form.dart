import 'package:flutter/material.dart';

class BundleItem {
  String title;
  String author;
  String condition;

  BundleItem({this.title = '', this.author = '', this.condition = 'good'});
}

class BundleForm extends StatefulWidget {
  final List<BundleItem> items;
  final Function(List<BundleItem>) onChanged;

  const BundleForm({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
  State<BundleForm> createState() => _BundleFormState();
}

class _BundleFormState extends State<BundleForm> {
  void _addItem() {
    setState(() {
      widget.items.add(BundleItem());
      widget.onChanged(widget.items);
    });
  }

  void _removeItem(int index) {
    if (widget.items.length <= 2) return; // Min 2 items for bundle
    setState(() {
      widget.items.removeAt(index);
      widget.onChanged(widget.items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Bundle Items',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.items.length,
          itemBuilder: (context, index) => _buildItemRow(index),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: TextButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Another Book to Bundle'),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Book #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              if (widget.items.length > 2)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _removeItem(index),
                ),
            ],
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Book Title', hintText: 'e.g., NCERT Mathematics'),
            onChanged: (val) {
              widget.items[index].title = val;
              widget.onChanged(widget.items);
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Author (optional)'),
                  onChanged: (val) {
                    widget.items[index].author = val;
                    widget.onChanged(widget.items);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Condition'),
                  initialValue: widget.items[index].condition,
                  items: ['like_new', 'good', 'fair'].map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 12)),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      widget.items[index].condition = val;
                      widget.onChanged(widget.items);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
