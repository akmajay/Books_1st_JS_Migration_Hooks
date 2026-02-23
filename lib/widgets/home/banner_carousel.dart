import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  List<RecordModel> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    try {
      final pb = AuthService().pb;
      final result = await pb.collection('banners').getList(
        filter: 'is_active = true', // Simple filter for now
        sort: 'sort_order',
      );
      if (mounted) {
        setState(() {
          _banners = result.items;
          _isLoading = false;
        });
        if (_banners.isNotEmpty) {
          _startTimer();
        }
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_banners.isEmpty) return;
      _currentPage = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    if (_banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              final imageUrl = '${AuthService().pb.baseURL}/api/files/${banner.collectionId}/${banner.id}/${banner.getStringValue('image')}';
              
              return GestureDetector(
                onTap: () async {
                  final link = banner.getStringValue('link');
                  if (link.isNotEmpty) {
                    final uri = Uri.tryParse(link);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300],
                border: _currentPage == index ? null : Border.all(color: Colors.grey[400]!),
              ),
            );
          }),
        ),
      ],
    );
  }
}
