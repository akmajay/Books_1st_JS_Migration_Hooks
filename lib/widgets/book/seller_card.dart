import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';

class SellerCard extends StatelessWidget {
  final RecordModel seller;
  final bool isOwnListing;

  const SellerCard({
    super.key,
    required this.seller,
    this.isOwnListing = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = seller.getStringValue('avatar');
    final avatarUrl = avatar.isNotEmpty 
        ? '${AuthService().pb.baseURL}/api/files/users/${seller.id}/$avatar'
        : null;

    final name = seller.getStringValue('name').isEmpty 
        ? 'JayGanga User' 
        : seller.getStringValue('name');

    final memberSince = seller.getStringValue('created').isNotEmpty
        ? DateFormat('MMM yyyy').format(DateTime.parse(seller.getStringValue('created')))
        : 'Jan 2026';

    final double trustScore = seller.getDoubleValue('trust_score');
    final int reviewsCount = seller.getIntValue('reviews_count');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => /* GoRouter.of(context).push('/seller/${seller.id}') */ {},
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null ? Text(name[0].toUpperCase()) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (isOwnListing) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'YOU',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${trustScore.toStringAsFixed(1)} · $reviewsCount reviews',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    'Member since $memberSince',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
