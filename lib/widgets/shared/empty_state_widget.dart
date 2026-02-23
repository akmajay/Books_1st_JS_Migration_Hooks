import 'package:flutter/material.dart';

enum EmptyStateType {
  noSearch,
  noResults,
  noNotifications,
  noOrders,
  noWishlist,
  noListings,
  noChats
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? factoryType;
  final EmptyStateType? type;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.factoryType,
    this.type,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
