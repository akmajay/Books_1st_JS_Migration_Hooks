import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../services/app_config_service.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  Future<String> _getCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '1.0.0';
    }
  }

  void _openStore() {
    final url = AppConfigService.instance.current.playStoreUrl;
    if (url.isNotEmpty) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfigService.instance.current;

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
                      color: Colors.blue.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.system_update_alt_rounded, size: 56, color: Colors.blue),
                  ),
                  const SizedBox(height: 28),

                  // Title
                  Text(
                    'Update Required',
                    style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 14),

                  // Message
                  Text(
                    'A new version of JayGanga Books is available. Please update to continue using the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Version info
                  FutureBuilder<String>(
                    future: _getCurrentVersion(),
                    builder: (context, snap) {
                      final currentVersion = snap.data ?? '...';
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withAlpha(40)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Your version', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                Text('v$currentVersion', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Required', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                Text(
                                  'v${config.minAppVersion}+',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Update button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openStore,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Update Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
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
