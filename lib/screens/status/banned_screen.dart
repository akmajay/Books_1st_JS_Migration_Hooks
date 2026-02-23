import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../services/pocketbase_service.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

  void _launchAppeal(BuildContext context) {
    final user = AuthService().currentUser;
    final userId = user?.id ?? 'unknown';
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@jayganga.com',
      query: 'subject=Ban Appeal - $userId',
    );
    launchUrl(uri);
  }

  Future<void> _logout(BuildContext context) async {
    PocketBaseService.instance.pb.authStore.clear();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final reason = user?.banReason ?? 'Violating community guidelines';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block, size: 56, color: Colors.red),
                ),
                const SizedBox(height: 24),
                Text(
                  'Account Banned',
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your account has been banned for violating our community guidelines.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Reason: $reason',
                          style: const TextStyle(fontSize: 13, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchAppeal(context),
                    icon: const Icon(Icons.email),
                    label: const Text('Appeal Ban'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
