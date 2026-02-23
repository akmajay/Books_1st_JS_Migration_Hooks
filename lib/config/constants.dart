/// App-wide constants for JayGanga Books.
class AppConstants {
  AppConstants._();

  // ── Radius Options (in km) ──────────────────────────────────
  static const List<double> radiusOptions = [2.0, 5.0, 8.0, 10.0];
  static const double defaultRadius = 5.0;

  // ── Cache Durations ─────────────────────────────────────────
  static const Duration cacheTTL = Duration(hours: 72);

  // ── Listing Limits ──────────────────────────────────────────
  static const int maxListingsPerDay = 5;
  static const int maxPhotosPerListing = 3;
  static const int maxPhotoSizeKB = 500;
  static const int maxPhotoWidth = 1080;

  // ── QR Code ─────────────────────────────────────────────────
  static const Duration qrValidDuration = Duration(minutes: 10);

  // ── Pagination ──────────────────────────────────────────────
  static const int pageSize = 15;

  // ── Offer ───────────────────────────────────────────────────
  static const Duration offerExpiryDuration = Duration(hours: 24);

  // ── Auto-Archive ────────────────────────────────────────────
  static const int autoArchiveDays = 60;
}
