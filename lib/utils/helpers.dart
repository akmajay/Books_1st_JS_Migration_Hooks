import 'package:intl/intl.dart';

/// Common helper utilities for JayGanga Books.
class Helpers {
  Helpers._();

  // ── Formatters ──────────────────────────────────────────────

  /// Format a price value as Indian Rupee string.
  /// Example: `formatPrice(250)` → `₹250`
  static String formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return '₹${price.toInt()}';
    }
    return '₹${price.toStringAsFixed(2)}';
  }

  /// Format a [DateTime] as a relative time string.
  /// Example: "2 hours ago", "3 days ago", "Just now"
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  /// Format a [DateTime] to a readable date string.
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  // ── Validators ──────────────────────────────────────────────

  /// Validate an email address.
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate a phone number (Indian format).
  static bool isValidPhone(String phone) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phone.replaceAll(' ', ''));
  }

  /// Validate that a string is non-empty after trimming.
  static bool isNotBlank(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  // ── Truncation ──────────────────────────────────────────────

  /// Truncate a string to [maxLength] and add ellipsis.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }
}
