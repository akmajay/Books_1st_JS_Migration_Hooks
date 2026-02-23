import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// A persistent banner shown at the top of screens when the user's account is restricted.
class RestrictedBanner extends StatelessWidget {
  const RestrictedBanner({super.key});

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Account Restricted',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your account has been temporarily restricted due to multiple reports from other users. '
              'While restricted, the following features are disabled:',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildDisabledFeature(Icons.add_box_outlined, 'Creating new listings'),
            _buildDisabledFeature(Icons.chat_outlined, 'Sending messages'),
            _buildDisabledFeature(Icons.local_offer_outlined, 'Making offers'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: 'support@jayganga.com',
                    query: 'subject=Account Restriction Appeal',
                  );
                  launchUrl(uri);
                },
                icon: const Icon(Icons.email),
                label: const Text('Contact Support'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _buildDisabledFeature(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.red[300]),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Icon(Icons.block, size: 16, color: Colors.red[300]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.orange.withAlpha(25),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '⚠️ Your account is restricted. Some features are disabled.',
                style: TextStyle(fontSize: 12, color: Colors.orange[800], fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.orange[800], size: 18),
          ],
        ),
      ),
    );
  }
}
