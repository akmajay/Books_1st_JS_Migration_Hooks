import 'package:flutter/material.dart';

class AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration delay;
  
  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
  });
  
  @override
  Widget build(BuildContext context) {
    // Stagger: each item starts with a delay based on its index
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      // Note: Future.delayed isn't ideal inside build, 
      // but for simple staggered animations, we can use an AnimationController 
      // or simply rely on the index in a parent custom builder if we need complex sync.
      // Here we use the tween builder which doesn't natively support staggered start easily without a parent controller.
      // Better approach for staggering:
      child: child,
    );
  }
}

/// A more robust staggered animation wrapper
class StaggeredListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delay;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOut)),
    );

    _offset = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic)),
    );

    final startDelay = Duration(milliseconds: (widget.index * widget.delay.inMilliseconds).clamp(0, 600));
    Future.delayed(startDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: FractionalTranslation(
            translation: _offset.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
