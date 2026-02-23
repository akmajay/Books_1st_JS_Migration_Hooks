import 'package:flutter/material.dart';

class ScrollToTopButton extends StatefulWidget {
  final ScrollController scrollController;
  final double threshold;

  const ScrollToTopButton({
    super.key,
    required this.scrollController,
    this.threshold = 500,
  });

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!mounted) return;
    final isVisible = widget.scrollController.hasClients &&
        widget.scrollController.offset > widget.threshold;
    if (isVisible != _isVisible) {
      setState(() => _isVisible = isVisible);
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: FloatingActionButton.small(
            onPressed: _scrollToTop,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            child: const Icon(Icons.arrow_upward_rounded),
          ),
        ),
      ),
    );
  }
}
