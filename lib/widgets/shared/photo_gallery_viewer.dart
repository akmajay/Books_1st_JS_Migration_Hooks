import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

class PhotoGalleryViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTag;

  const PhotoGalleryViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag,
  });

  static void show(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
    String? heroTag,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withAlpha((0.9 * 255).toInt()),
        pageBuilder: (context, animation, secondaryAnimation) => PhotoGalleryViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
          heroTag: heroTag,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<PhotoGalleryViewer> createState() => _PhotoGalleryViewerState();
}

class _PhotoGalleryViewerState extends State<PhotoGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _onShare() async {
    final url = widget.imageUrls[_currentIndex];
    await SharePlus.share('Check out this photo: $url');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Main Gallery with Swipe Dismiss
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > 20) {
                Navigator.pop(context);
              }
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() {
                _currentIndex = index;
                _transformationController.value = Matrix4.identity();
              }),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  onInteractionEnd: (_) {
                    // Reset zoom if snapped back? No, let user control.
                  },
                  child: Center(
                    child: Hero(
                      tag: widget.heroTag ?? widget.imageUrls[index],
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrls[index],
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top Bars (Close, Share, Counter)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.5 * 255).toInt()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imageUrls.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
