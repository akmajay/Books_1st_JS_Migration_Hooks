import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/app_config_service.dart';

/// Global announcement banner shown at the top of Home screen.
/// Reads from [AppConfigService.current.announcement].
/// Colors: info=blue, warning=orange, critical=red.
class AnnouncementBanner extends StatefulWidget {
  const AnnouncementBanner({super.key});

  @override
  State<AnnouncementBanner> createState() => _AnnouncementBannerState();
}

class _AnnouncementBannerState extends State<AnnouncementBanner> {
  /// Track dismissed announcement text so we don't show again until it changes.
  static String _dismissedText = '';

  @override
  Widget build(BuildContext context) {
    final config = AppConfigService.instance.current;
    final text = config.announcement.trim();

    if (text.isEmpty || text == 'none' || text == _dismissedText) {
      return const SizedBox.shrink();
    }

    final (Color bg, Color fg, Color border, IconData icon) = switch (config.announcementType) {
      'warning' => (Colors.orange.withAlpha(20), Colors.orange[900]!, Colors.orange.withAlpha(60), Icons.warning_amber_rounded),
      'critical' => (Colors.red.withAlpha(20), Colors.red[900]!, Colors.red.withAlpha(60), Icons.error_outline),
      _ => (Colors.blue.withAlpha(20), Colors.blue[900]!, Colors.blue.withAlpha(60), Icons.campaign_outlined),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _dismissedText = text),
            child: Icon(Icons.close, color: fg.withAlpha(150), size: 18),
          ),
        ],
      ),
    );
  }
}

/// Dismissible bottom sheet for optional update prompt (once per session).
void showOptionalUpdateSheet(BuildContext context) {
  final config = AppConfigService.instance.current;
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
          const Icon(Icons.new_releases_outlined, size: 42, color: Colors.green),
          const SizedBox(height: 14),
          const Text(
            'New Version Available!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Update to v${config.latestAppVersion} for the latest features and improvements.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Later'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (config.playStoreUrl.isNotEmpty) {
                      launchUrl(Uri.parse(config.playStoreUrl), mode: LaunchMode.externalApplication);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text('Update'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
