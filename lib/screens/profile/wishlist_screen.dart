import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../../services/pocketbase_service.dart';
import '../../controllers/paginated_controller.dart';
import '../../widgets/shared/paginated_list_view.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final PocketBase _pb = PocketBaseService.instance.pb;
  final AuthService _authService = AuthService();

  late final PaginatedController<RecordModel> _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = PaginatedController<RecordModel>(
      fetcher: (page, perPage) => _pb.collection('wishlists').getList(
        page: page,
        perPage: perPage,
        filter: 'user = "${_authService.currentUser?.id}"',
        expand: 'book,book.seller',
        sort: '-created',
      ),
      mapper: (record) => record,
    )..loadInitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _removeFromWishlist(String id) async {
    try {
      await _pb.collection('wishlists').delete(id);
      _controller.removeItemById(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from wishlist')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: PaginatedListView<RecordModel>(
        controller: _controller,
        emptyWidget: _buildEmptyState(),
        padding: const EdgeInsets.all(16),
        itemBuilder: (item, index) => _buildWishlistItem(item),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            'Your wishlist is empty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap ❤️ on any book to save it for later.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Browse Books'),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(RecordModel item) {
    final book = item.get<List<RecordModel>>('expand.book').first;
    final currentPrice = book.get<int>('selling_price');
    final savedPrice = item.get<int>('price_at_save');
    final isPriceDropped = currentPrice < savedPrice;
    
    final photos = book.get<List<dynamic>>('photos');
    final imageUrl = photos.isNotEmpty 
        ? PocketBaseService.instance.getFileUrl(book, photos.first)
        : '';

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(onDismissed: () => _removeFromWishlist(item.id)),
        children: [
          SlidableAction(
            onPressed: (_) => _removeFromWishlist(item.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Remove',
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: InkWell(
          onTap: () => context.push('/book/${book.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 70, height: 70,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[100]),
                        )
                      : Container(width: 70, height: 70, color: Colors.grey[100], child: const Icon(Icons.book, color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.getStringValue('title'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '₹$currentPrice',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 15),
                          ),
                          if (isPriceDropped) ...[
                            const SizedBox(width: 8),
                            Text(
                              '₹$savedPrice',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (isPriceDropped) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '📉 Price dropped!',
                            style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
