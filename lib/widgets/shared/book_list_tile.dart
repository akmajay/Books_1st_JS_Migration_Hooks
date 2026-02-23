import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';

class BookListTile extends StatelessWidget {
  final RecordModel book;
  final VoidCallback onTap;
  final Function(String) onDelete;
  final Function(String) onMarkSold;
  final Function(String) onRelist;
  final double? distanceKm;

  const BookListTile({
    super.key,
    required this.book,
    required this.onTap,
    required this.onDelete,
    required this.onMarkSold,
    required this.onRelist,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final pb = AuthService().pb;
    final photos = book.getListValue<String>('photos');
    final imageUrl = photos.isNotEmpty 
        ? '${pb.baseURL}/api/files/${book.collectionId}/${book.id}/${photos[0]}?thumb=100x100'
        : '';
    
    final status = book.getStringValue('status');
    final price = book.getDoubleValue('selling_price');
    final views = book.getListValue('views').length; 
    final created = DateTime.tryParse(book.getStringValue('created')) ?? DateTime.now();
    final soldAtStr = book.getStringValue('sold_at');
    final soldAt = soldAtStr.isNotEmpty ? DateTime.tryParse(soldAtStr) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Slidable(
        key: ValueKey(book.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            if (status == 'active' || status == 'reserved')
              SlidableAction(
                onPressed: (_) => onMarkSold(book.id),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.check_circle_outline,
                label: 'Mark Sold',
              ),
            if (status == 'sold')
              SlidableAction(
                onPressed: (_) => onRelist(book.id),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.refresh,
                label: 'Relist',
              ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _confirmDelete(context),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'Delete',
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 80, height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[100]),
                        )
                      : Container(width: 80, height: 80, color: Colors.grey[100], child: const Icon(Icons.book, color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.getStringValue('title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                        price == 0 ? 'FREE' : '₹${price.toStringAsFixed(0)}',
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _statusChip(status),
                          if (distanceKm != null) ..._buildDistanceChip(distanceKm!),
                          const Spacer(),
                          Text(
                            status == 'sold' && soldAt != null
                                ? 'Sold on ${DateFormat('MMM d').format(soldAt)}'
                                : 'Listed ${DateFormat('MMM d').format(created)}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                    Text('$views', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = Colors.blue;
    if (status == 'sold') color = Colors.green;
    if (status == 'reserved') color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withAlpha(128))),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  List<Widget> _buildDistanceChip(double km) {
    final category = LocationService.categorize(km);
    final Color color = switch (category) {
      DistanceCategory.nearby => Colors.green,
      DistanceCategory.moderate => Colors.orange,
      DistanceCategory.far => Colors.grey,
    };
    return [
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 10, color: color),
            const SizedBox(width: 2),
            Text(
              LocationService.formatDistance(km),
              style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ];
  }

  void _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('This action cannot be undone. All photos and data will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) onDelete(book.id);
  }
}
