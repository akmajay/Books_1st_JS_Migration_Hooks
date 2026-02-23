import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/notification_provider.dart';
import '../../widgets/shared/paginated_list_view.dart';
import 'package:pocketbase/pocketbase.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'new_message': return Icons.chat_bubble_outline;
      case 'new_offer': return Icons.monetization_on_outlined;
      case 'offer_accepted': return Icons.check_circle_outline;
      case 'offer_declined': return Icons.cancel_outlined;
      case 'handover_ready': return Icons.qr_code_2;
      case 'transaction_complete': return Icons.celebration;
      case 'new_review': return Icons.star_outline;
      case 'price_drop': return Icons.trending_down;
      case 'badge_earned': return Icons.emoji_events_outlined;
      default: return Icons.notifications_none;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'new_message': return Colors.blue;
      case 'new_offer': return Colors.green;
      case 'offer_accepted': return Colors.green;
      case 'offer_declined': return Colors.red;
      case 'handover_ready': return Colors.orange;
      case 'transaction_complete': return Colors.purple;
      case 'new_review': return Colors.amber;
      case 'price_drop': return Colors.green;
      case 'badge_earned': return Colors.amber;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationProvider>().markAllAsRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return PaginatedListView<RecordModel>(
            controller: provider.controller,
            padding: EdgeInsets.zero,
            emptyWidget: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'All caught up! 🎉\nNo new notifications.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
            itemBuilder: (notif, index) {
              final type = notif.getStringValue('type');
              final isRead = notif.getBoolValue('is_read');

              return ListTile(
                onTap: () {
                  provider.markAsRead(notif.id);
                },
                leading: CircleAvatar(
                  backgroundColor: _getColorForType(type).withAlpha(30),
                  child: Icon(_getIconForType(type), color: _getColorForType(type)),
                ),
                title: Text(
                  notif.getStringValue('title'),
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif.getStringValue('body'), style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(DateTime.parse(notif.getStringValue('created'))),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                trailing: isRead 
                    ? null 
                    : Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
              );
            },
          );
        },
      ),
    );
  }
}
