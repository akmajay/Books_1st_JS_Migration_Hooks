import 'package:flutter/material.dart';

class AppPageTransitions {
  /// Slide up from bottom
  static PageRouteBuilder slideUp(Widget page) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 0.3), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
  
  /// Fade through (for tab switches)
  static Widget fadeThrough(Widget child, Animation<double> animation, {Widget? secondaryAnimation}) {
    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
      child: child,
    );
  }
  
  /// Shared axis X (horizontal slide + fade)
  static PageRouteBuilder sharedAxisX(Widget page) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideTween = Tween(begin: const Offset(0.1, 0), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic));
      final fadeTween = Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeIn));
      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );

  /// Fade in (for overlays)
  static PageRouteBuilder fadeIn(Widget page) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}
