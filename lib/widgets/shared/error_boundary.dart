import 'package:flutter/material.dart';
import '../../models/app_error.dart';
import 'empty_state_widget.dart';

class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Stream<AppError>? errorStream;
  final VoidCallback? onRetry;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorStream,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (errorStream == null) return child;

    return StreamBuilder<AppError>(
      stream: errorStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final error = snapshot.data!;
          
          if (error.type == ErrorType.network) {
            return Center(
              child: EmptyStateWidget(
                title: 'Connection Lost',
                message: 'Please check your internet and try again',
                type: EmptyStateType.noResults,
                onAction: onRetry,
                actionLabel: 'Retry',
              ),
            );
          }

          return Center(
            child: EmptyStateWidget(
              title: 'Something went wrong',
              message: error.message,
              type: EmptyStateType.noResults,
              onAction: onRetry,
              actionLabel: 'Retry',
            ),
          );
        }

        return child;
      },
    );
  }
}
