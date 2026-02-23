import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../widgets/login_gate.dart';
import 'package:pocketbase/pocketbase.dart';
import 'tap_bounce.dart';

class BookCard extends StatelessWidget {
  final RecordModel book;
  final UserModel? currentUser;
  /// Pre-calculated distance in km (from LocationService). Null = unknown.
  final double? distanceKm;

  const BookCard({
    super.key,
    required this.book,
    this.currentUser,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final photos = book.getListValue<String>('photos');
    final String? imageUrl = photos.isNotEmpty
        ? '${AuthService().pb.baseURL}/api/files/${book.collectionId}/${book.id}/${photos.first}'
        : null;

    final double sellingPrice = book.getDoubleValue('selling_price');
    final double mrp = book.getDoubleValue('mrp');
    final bool isFree = sellingPrice == 0;
    final int discount = mrp > 0 ? (((mrp - sellingPrice) / mrp) * 100).round() : 0;

    final String condition = book.getStringValue('condition');
    final bool isPriority = book.getBoolValue('is_priority');

    return TapBounce(
      onTap: () => context.push('/book/${book.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Hero(
                  tag: 'book_image_${book.id}',
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.book, size: 40, color: Colors.grey),
                          ),
                  ),
                ),

                // Priority Badge
                if (isPriority)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flash_on, size: 12, color: Colors.white),
                          Text(
                            'Featured',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Wishlist Button
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {
                        if (!AuthService().isLoggedIn) {
                          LoginGate.show(context);
                        } else {
                          // Toggle wishlist logic
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and Discount
                  Row(
                    children: [
                      if (isFree)
                        const Text(
                          'FREE',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                        )
                      else
                        Text(
                          '₹${sellingPrice.toInt()}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(width: 4),
                      if (mrp > sellingPrice && !isFree) ...[
                        Text(
                          '₹${mrp.toInt()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$discount% off',
                          style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Product Title
                  Hero(
                    tag: 'book_title_${book.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        book.getStringValue('title'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Condition + Distance Row
                  Row(
                    children: [
                      _buildConditionChip(condition),
                      const Spacer(),
                      _buildDistanceChip(),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Location area
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          book.getStringValue('handover_area').isNotEmpty
                              ? book.getStringValue('handover_area')
                              : 'Location not set',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  /// Color-coded distance chip: green ≤5km, orange ≤15km, grey >15km.
  Widget _buildDistanceChip() {
    if (distanceKm == null) {
      // No distance data
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 11, color: Colors.grey[400]),
          const SizedBox(width: 2),
          Text('—', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
        ],
      );
    }

    final category = LocationService.categorize(distanceKm!);
    final Color color = switch (category) {
      DistanceCategory.nearby => Colors.green,
      DistanceCategory.moderate => Colors.orange,
      DistanceCategory.far => Colors.grey,
    };

    return Container(
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
            LocationService.formatDistance(distanceKm!),
            style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionChip(String condition) {
    Color color;
    String label = condition;
    switch (condition.toLowerCase()) {
      case 'new':
      case 'like_new':
        color = Colors.green;
        label = 'Like New';
        break;
      case 'good':
        color = Colors.blue;
        label = 'Good';
        break;
      case 'fair':
        color = Colors.orange;
        label = 'Fair';
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
