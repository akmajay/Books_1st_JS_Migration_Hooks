import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  bool _isShowingReconnect = false;
  bool get isShowingReconnect => _isShowingReconnect;

  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  
  ConnectivityService() {
    _init();
  }
  
  Future<void> _init() async {
    // Initial check
    final results = await Connectivity().checkConnectivity();
    _isOnline = !results.contains(ConnectivityResult.none);
    
    // Listen for changes
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = !results.contains(ConnectivityResult.none);
      
      if (wasOnline != _isOnline) {
        if (!wasOnline && _isOnline) {
          // Trigger the 'Back Online' transient banner
          _showReconnectBanner();
        }
        notifyListeners();
      }
    });
  }

  void _showReconnectBanner() {
    _isShowingReconnect = true;
    notifyListeners();
    Timer(const Duration(seconds: 3), () {
      _isShowingReconnect = false;
      notifyListeners();
    });
  }

  /// Force a manual check if needed
  Future<void> checkNow() async {
    final results = await Connectivity().checkConnectivity();
    final newStatus = !results.contains(ConnectivityResult.none);
    if (newStatus != _isOnline) {
      _isOnline = newStatus;
      if (_isOnline) _showReconnectBanner();
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
