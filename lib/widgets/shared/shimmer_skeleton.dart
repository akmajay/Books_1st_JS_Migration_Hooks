import 'package:flutter/material.dart';

class ShimmerSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  
  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _gradientPosition = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    
    return AnimatedBuilder(
      animation: _gradientPosition,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_gradientPosition.value - 1, 0),
              end: Alignment(_gradientPosition.value, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

// Preset Skeletons

class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerSkeleton(
            width: double.infinity, 
            height: 150,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerSkeleton(width: 140, height: 14),
                const SizedBox(height: 8),
                const ShimmerSkeleton(width: 100, height: 12),
                const SizedBox(height: 8),
                const ShimmerSkeleton(width: 60, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookListTileSkeleton extends StatelessWidget {
  const BookListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const ShimmerSkeleton(width: 60, height: 80, borderRadius: BorderRadius.all(Radius.circular(8))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerSkeleton(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                const ShimmerSkeleton(width: 150, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubbleSkeleton extends StatelessWidget {
  final bool isMe;
  const ChatBubbleSkeleton({super.key, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: ShimmerSkeleton(
          width: 150 + (isMe ? 20.0 : 50.0),
          height: 40,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
      ),
    );
  }
}

class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const ShimmerSkeleton(width: 64, height: 64, borderRadius: BorderRadius.all(Radius.circular(32))),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerSkeleton(width: 120, height: 18),
              SizedBox(height: 8),
              ShimmerSkeleton(width: 80, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const ShimmerSkeleton(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerSkeleton(width: double.infinity, height: 14),
                SizedBox(height: 4),
                ShimmerSkeleton(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
