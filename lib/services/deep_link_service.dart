import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../config/deeplink_config.dart';

class DeepLinkService {
  static final DeepLinkService instance = DeepLinkService._();
  DeepLinkService._();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  static const String _referralBox = 'referral_meta';
  static const String _pendingCodeKey = 'pending_code';

  Future<void> initialize() async {
    // 1. Initialize Hive box for pending referrals
    await Hive.openBox(_referralBox);

    // 2. Handle initial link (Cold Start)
    if (!kIsWeb) {
      try {
        final initialUri = await _appLinks.getInitialLink();
        if (initialUri != null) {
          _handleUri(initialUri);
        }
      } catch (e) {
        debugPrint('Error getting initial deep link: $e');
      }
    }

    // 3. Handle incoming links (Warm Start / Background)
    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    debugPrint('Received Deep Link: $uri (scheme: ${uri.scheme}, host: ${uri.host})');

    // Handle OAuth Callback (Custom Scheme)
    if (uri.scheme == 'jaygangabooks') {
      if (uri.host == 'auth-callback') {
        debugPrint('OAuth callback detected. PocketBase SDK will handle the resumption via internal listeners if any, or we log it here.');
        // The PocketBase SDK's authWithOAuth2 usually handles the redirect internally 
        // if the app is brought to foreground with the URI, but we need to ensure 
        // we don't return early and prevent other handlers from potentially seeing this.
        return;
      }
    }

    // Handle App Links (HTTPS)
    if (uri.host != DeepLinkConfig.domain && uri.scheme != 'jaygangabooks') return;
    
    final path = uri.pathSegments;
    if (path.isEmpty) return;

    debugPrint('Handling Deep Link: $uri');

    final router = AppRouter.router;
    final auth = AuthService();

    switch (path[0]) {
      case 'book':
        if (path.length >= 2) {
          router.push('/book/${path[1]}');
        }
        break;
      
      case 'seller':
        if (path.length >= 2) {
          router.push('/seller/${path[1]}');
        }
        break;
      
      case 'ref':
        if (path.length >= 2) {
          final code = path[1];
          if (!auth.isLoggedIn) {
            _savePendingReferral(code);
            // Redirect to home/login if needed, or just store it
            debugPrint('Pending referral code saved: $code');
          }
        }
        break;
      
      case 'txn':
        if (path.length >= 2) {
          if (auth.isLoggedIn) {
            router.push('/transaction/${path[1]}');
          } else {
            // GoRouter handles redirects usually, but we can nudge
            router.push('/settings'); // Or show login
          }
        }
        break;
    }
  }

  Future<void> _savePendingReferral(String code) async {
    final box = Hive.box(_referralBox);
    await box.put(_pendingCodeKey, code);
  }

  String? getPendingReferral() {
    final box = Hive.box(_referralBox);
    return box.get(_pendingCodeKey);
  }

  Future<void> clearPendingReferral() async {
    final box = Hive.box(_referralBox);
    await box.delete(_pendingCodeKey);
  }

  void dispose() {
    _sub?.cancel();
  }
}
