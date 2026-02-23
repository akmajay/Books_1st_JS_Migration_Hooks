import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AdStrip extends StatefulWidget {
  const AdStrip({super.key});

  @override
  State<AdStrip> createState() => _AdStripState();
}

class _AdStripState extends State<AdStrip> {
  List<RecordModel> _ads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAds();
  }

  Future<void> _fetchAds() async {
    try {
      final pb = AuthService().pb;
      final result = await pb.collection('advertisements').getList(
        filter: 'is_active = true',
        sort: 'sort_order',
      );
      if (mounted) {
        setState(() {
          _ads = result.items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmer();
    }

    if (_ads.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _ads.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final ad = _ads[index];
          final logoUrl = '${AuthService().pb.baseURL}/api/files/${ad.collectionId}/${ad.id}/${ad.getStringValue('logo')}';

          return GestureDetector(
            onTap: () async {
              final link = ad.getStringValue('link');
              final phone = ad.getStringValue('phone');
              if (phone.isNotEmpty) {
                 final phoneUri = Uri.parse('tel:$phone');
                 if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
              } else if (link.isNotEmpty) {
                final uri = Uri.tryParse(link);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: logoUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ad.getStringValue('business_name'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ad.getStringValue('tagline'),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 150,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
