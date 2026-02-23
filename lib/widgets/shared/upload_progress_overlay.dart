import 'package:flutter/material.dart';

class UploadProgressOverlay extends StatelessWidget {
  final int uploadedCount;
  final int totalCount;
  final String statusText;
  final VoidCallback? onCancel;
  final bool isError;
  final bool isSuccess;
  final VoidCallback? onRetry;

  const UploadProgressOverlay({
    super.key,
    required this.uploadedCount,
    required this.totalCount,
    this.statusText = 'Uploading...',
    this.onCancel,
    this.isError = false,
    this.isSuccess = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.1 * 255).round()),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isError && !isSuccess) ...[
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(strokeWidth: 6),
                ),
                const SizedBox(height: 24),
                Text(
                  'Uploading $uploadedCount of $totalCount',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  statusText,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),
                if (onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
              ] else if (isSuccess) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Upload Complete!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text('Saving changes...'),
              ] else if (isError) ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Upload Failed',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (onCancel != null)
                      TextButton(onPressed: onCancel, child: const Text('Cancel')),
                    if (onRetry != null)
                      ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show overlay as a dialog or manual blocker
  static void show(BuildContext context) {
    // Usually used as a Stack child in SellBook/EditProfile screens
    // but can be wrapped in a Dialog if needed.
  }
}
