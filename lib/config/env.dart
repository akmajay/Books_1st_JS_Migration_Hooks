/// Environment configuration for JayGanga Books.
///
/// Uses compile-time constants via `--dart-define` for different environments.
class Env {
  Env._();

  /// PocketBase backend URL.
  /// Override at build time: `flutter run --dart-define=PB_URL=http://localhost:8090`
  static const String pocketbaseUrl = String.fromEnvironment(
    'PB_URL',
    defaultValue: 'https://api.jayganga.com',
  );

  /// Application display name.
  static const String appName = 'JayGanga Books';

  /// Application version (sync with pubspec.yaml).
  static const String appVersion = '1.0.0';

  /// Whether this is a debug build.
  static const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
}
