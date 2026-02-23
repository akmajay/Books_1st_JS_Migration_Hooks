import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class BadgeShowcaseScreen extends StatelessWidget {
  const BadgeShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Please login')));

    final userBadges = user.badges;
    
    final allBadges = [
      _Badge(
        id: 'helping_hand',
        name: 'Helping Hand',
        description: 'Completed your first successful transaction.',
        icon: Icons.handshake_outlined,
        color: Colors.green,
        requirement: '1 Transaction',
      ),
      _Badge(
        id: 'top_seller',
        name: 'Top Seller',
        description: 'Successfully sold 5 or more books.',
        icon: Icons.workspace_premium_outlined,
        color: Colors.orange,
        requirement: '5 Sales',
      ),
      _Badge(
        id: 'bookworm',
        name: 'Bookworm',
        description: 'Successfully purchased 5 or more books.',
        icon: Icons.menu_book_outlined,
        color: Colors.blue,
        requirement: '5 Purchases',
      ),
      _Badge(
        id: 'trusted_member',
        name: 'Trusted Member',
        description: 'Maintained a Trust Score of 4.5 or higher.',
        icon: Icons.verified_user_outlined,
        color: Colors.purple,
        requirement: '4.5+ Rating',
      ),
      _Badge(
        id: 'early_bird',
        name: 'Early Bird',
        description: 'Joined JayGanga Books during our launch phase.',
        icon: Icons.wb_sunny_outlined,
        color: Colors.amber,
        requirement: 'Launch User',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Badges')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earned ${userBadges.length} of ${allBadges.length} Badges',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: userBadges.length / allBadges.length,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: allBadges.length,
              itemBuilder: (context, index) {
                final badge = allBadges[index];
                final isEarned = userBadges.contains(badge.id);
                // special check for trusted_member based on live score
                final isTrusted = badge.id == 'trusted_member' && user.trustScore >= 4.5;
                final effectivelyEarned = isEarned || isTrusted;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: effectivelyEarned ? badge.color.withAlpha(15) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: effectivelyEarned ? badge.color.withAlpha(50) : Colors.grey[200]!,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        badge.icon,
                        size: 48,
                        color: effectivelyEarned ? badge.color : Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        badge.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: effectivelyEarned ? Colors.black87 : Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.requirement,
                        style: TextStyle(
                          fontSize: 11,
                          color: effectivelyEarned ? badge.color : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge.description,
                        style: TextStyle(
                          fontSize: 10,
                          color: effectivelyEarned ? Colors.black54 : Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String requirement;

  _Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requirement,
  });
}
