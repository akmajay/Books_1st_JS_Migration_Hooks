import 'package:flutter/material.dart';
import '../../models/app_error.dart';

class ErrorStateWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  IconData _iconForType(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.server:
        return Icons.dns_outlined;
      case ErrorType.auth:
        return Icons.lock_outline_rounded;
      case ErrorType.notFound:
        return Icons.search_off_rounded;
      case ErrorType.validation:
        return Icons.error_outline_rounded;
      case ErrorType.rateLimited:
        return Icons.hourglass_empty_rounded;
      case ErrorType.unknown:
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconForType(error.type),
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              error.message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (error.detail != null) ...[
              const SizedBox(height: 12),
              Text(
                error.detail!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 32),
            if (onRetry != null && error.isRetryable)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
            else if (error.type == ErrorType.auth)
              ElevatedButton(
                onPressed: () {
                  // This usually triggers a redirect to login
                  // For now, retry might suffice if the app shell handles redirection
                  onRetry?.call();
                },
                child: const Text('Sign In'),
              )
            else if (Navigator.of(context).canPop())
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
          ],
        ),
      ),
    );
  }
}
