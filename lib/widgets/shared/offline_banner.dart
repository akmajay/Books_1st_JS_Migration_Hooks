import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/connectivity_service.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        if (connectivity.isOnline && !connectivity.isShowingReconnect) {
          return const SizedBox.shrink();
        }

        final isBackOnline = connectivity.isOnline && connectivity.isShowingReconnect;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: 32,
          color: isBackOnline ? Colors.green : Colors.red[700],
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBackOnline ? Icons.check_circle_outline : Icons.wifi_off_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isBackOnline ? 'Back online!' : 'No internet connection',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isBackOnline) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => connectivity.checkNow(),
                  child: const Text(
                    'RETRY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
