import 'dart:math' as math;
import 'package:flutter/material.dart';

class SuccessCheckmark extends StatefulWidget {
  final double size;
  final Color? color;
  
  const SuccessCheckmark({
    super.key, 
    this.size = 100,
    this.color,
  });

  @override
  State<SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<SuccessCheckmark> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;
  late Animation<double> _circleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _circleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1, curve: Curves.easeOutCubic)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? Theme.of(context).colorScheme.primary;
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _CheckmarkPainter(
        color: themeColor,
        circleProgress: _circleAnimation.value,
        checkProgress: _checkAnimation.value,
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final Color color;
  final double circleProgress;
  final double checkProgress;

  _CheckmarkPainter({
    required this.color,
    required this.circleProgress,
    required this.checkProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw external circle
    if (circleProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * circleProgress,
        false,
        paint,
      );
    }

    // Draw checkmark
    if (checkProgress > 0) {
      final path = Path();
      final start = Offset(size.width * 0.25, size.height * 0.5);
      final mid = Offset(size.width * 0.45, size.height * 0.7);
      final end = Offset(size.width * 0.75, size.height * 0.35);

      path.moveTo(start.dx, start.dy);
      
      if (checkProgress < 0.5) {
        final p = checkProgress / 0.5;
        path.lineTo(
          start.dx + (mid.dx - start.dx) * p,
          start.dy + (mid.dy - start.dy) * p,
        );
      } else {
        path.lineTo(mid.dx, mid.dy);
        final p = (checkProgress - 0.5) / 0.5;
        path.lineTo(
          mid.dx + (end.dx - mid.dx) * p,
          mid.dy + (end.dy - mid.dy) * p,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ErrorShake extends StatefulWidget {
  final Widget child;
  final bool shouldShake;
  final Duration duration;

  const ErrorShake({
    super.key,
    required this.child,
    this.shouldShake = false,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<ErrorShake> createState() => _ErrorShakeState();
}

class _ErrorShakeState extends State<ErrorShake> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void didUpdateWidget(ErrorShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double offset = math.sin(_animation.value * math.pi * 3) * 10 * (1 - _animation.value);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class HeartPop extends StatefulWidget {
  final bool isActive;
  final double size;
  final VoidCallback? onTap;

  const HeartPop({
    super.key, 
    required this.isActive, 
    this.size = 24.0,
    this.onTap,
  });

  @override
  State<HeartPop> createState() => _HeartPopState();
}

class _HeartPopState extends State<HeartPop> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(HeartPop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.isActive ? Icons.favorite : Icons.favorite_border,
          color: widget.isActive ? Colors.red : Colors.grey,
          size: widget.size,
        ),
      ),
    );
  }
}
