import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isAvatar;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.isAvatar = false,
  });

  /// Variant for User Avatars
  factory AppCachedImage.avatar({
    required String? url,
    double size = 40,
  }) {
    return AppCachedImage(
      imageUrl: url,
      width: size,
      height: size,
      isAvatar: true,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  /// Variant for Book Covers (3:4 aspect ratio placeholder)
  factory AppCachedImage.bookCover({
    required String? url,
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return AppCachedImage(
      imageUrl: url,
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _shimmerPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _buildError(),
        fadeInDuration: const Duration(milliseconds: 200),
        memCacheWidth: width != null ? (width! * 2).toInt() : null,
      ),
    );
  }

  Widget _shimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Icon(
        isAvatar ? Icons.person : Icons.book,
        color: Colors.grey[400],
        size: width != null ? width! * 0.4 : 24,
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.grey[400],
        size: width != null ? width! * 0.4 : 24,
      ),
    );
  }
}
