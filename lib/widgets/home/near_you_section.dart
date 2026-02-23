import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../shared/book_card.dart';
import '../shared/animated_list_item.dart';

/// Horizontal carousel showing books within 5 km of the user.
/// Hidden if location not granted or no nearby books found.
class NearYouSection extends StatefulWidget {
  const NearYouSection({super.key});

  @override
  State<NearYouSection> createState() => _NearYouSectionState();
}

class _NearYouSectionState extends State<NearYouSection> {
  List<_BookWithDistance> _nearbyBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyBooks();
  }

  Future<void> _loadNearbyBooks() async {
    final userPos = await LocationService.getLastKnown();
    if (userPos == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final pb = AuthService().pb;
      // Fetch active books that have coordinates
      final result = await pb.collection('books').getList(
        page: 1,
        perPage: 50, // fetch more to client-filter
        filter: 'status = "active" && location_lat != null && location_lon != null',
        sort: '-created',
        expand: 'seller,school',
      );

      final List<_BookWithDistance> withDistances = [];
      for (final book in result.items) {
        final lat = book.getDoubleValue('location_lat');
        final lon = book.getDoubleValue('location_lon');
        if (lat == 0 || lon == 0) continue;

        final km = LocationService.calculateDistance(
          userPos.latitude,
          userPos.longitude,
          lat,
          lon,
        );
        if (km <= 5.0) {
          withDistances.add(_BookWithDistance(book: book, distanceKm: km));
        }
      }

      // Sort nearest first, limit to 10
      withDistances.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      if (mounted) {
        setState(() {
          _nearbyBooks = withDistances.take(10).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _nearbyBooks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Near You 📍',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${_nearbyBooks.length} books',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _nearbyBooks.length,
            itemBuilder: (context, index) {
              final item = _nearbyBooks[index];
              return SizedBox(
                width: 170,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: StaggeredListItem(
                    index: index,
                    child: BookCard(
                      book: item.book,
                      currentUser: AuthService().currentUser,
                      distanceKm: item.distanceKm,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookWithDistance {
  final RecordModel book;
  final double distanceKm;
  const _BookWithDistance({required this.book, required this.distanceKm});
}
