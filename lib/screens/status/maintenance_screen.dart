import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../services/app_config_service.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  Timer? _autoRetryTimer;
  int _countdown = 60;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _startAutoRetry();
  }

  @override
  void dispose() {
    _autoRetryTimer?.cancel();
    super.dispose();
  }

  void _startAutoRetry() {
    _countdown = 60;
    _autoRetryTimer?.cancel();
    _autoRetryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        _retry();
      }
    });
  }

  Future<void> _retry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    try {
      final config = await AppConfigService.instance.fetch();
      if (!mounted) return;

      if (!config.maintenanceMode) {
        context.go('/');
      } else {
        _startAutoRetry();
      }
    } catch (_) {
      if (mounted) _startAutoRetry();
    } finally {
      if (mounted) setState(() => _isRetrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfigService.instance.current;
    final message = config.maintenanceMessage.isNotEmpty
        ? config.maintenanceMessage
        : 'We\'re performing scheduled maintenance. We\'ll be back soon!';
    final eta = config.maintenanceEta;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.construction_rounded, size: 56, color: Colors.orange),
                  ),
                  const SizedBox(height: 28),

                  // Title
                  Text(
                    'Under Maintenance',
                    style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                  ),
                  const SizedBox(height: 14),

                  // Message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                  ),

                  // ETA
                  if (eta.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withAlpha(40)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, color: Colors.orange[700], size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Estimated time: $eta',
                            style: TextStyle(color: Colors.orange[800], fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Retry button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isRetrying ? null : _retry,
                      icon: _isRetrying
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.refresh),
                      label: Text(_isRetrying ? 'Checking...' : 'Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Auto-retry countdown
                  Text(
                    'Auto-retry in ${_countdown}s',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
