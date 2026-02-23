import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../../services/pocketbase_service.dart';

class ChatListTile extends StatelessWidget {
  final RecordModel chat;
  final VoidCallback onTap;
  final Function(RecordModel) onDelete;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.id;
    final isBuyer = chat.get<String>('buyer') == userId;
    final otherUser = isBuyer ? chat.get<List<RecordModel>>('expand.seller').first : chat.get<List<RecordModel>>('expand.buyer').first;
    final book = chat.get<List<RecordModel>>('expand.book').first;
    
    final lastMessage = chat.get<String>('last_message');
    final lastMessageAt = chat.get<String>('last_message_at');
    final unreadCount = chat.get<int>('unread_count');
    final lastSender = chat.get<String>('last_sender');
    final isUnread = unreadCount > 0 && lastSender != userId;

    // Removal of unnecessary null check

    String avatarUrl = PocketBaseService.instance.getFileUrl(otherUser, otherUser.get<String>('avatar'));
    String bookThumbnail = PocketBaseService.instance.getFileUrl(book, (book.get<List<dynamic>>('photos')).first);

    return Slidable(
      key: ValueKey(chat.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () => onDelete(chat)),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(chat),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Hero(
          tag: 'avatar_${otherUser.id}',
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.withAlpha(20),
            backgroundImage: avatarUrl.isNotEmpty ? CachedNetworkImageProvider(avatarUrl) : null,
            child: avatarUrl.isEmpty ? Text(otherUser.get<String>('name')[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)) : null,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(otherUser.get<String>('name'), style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
            ),
            if (lastMessageAt.isNotEmpty)
              Text(timeago.format(DateTime.parse(lastMessageAt), locale: 'en_short'), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removal of unnecessary null check
            Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 2),
                child: Text('About: ${book.get<String>('title')}', style: TextStyle(color: Colors.blue[700], fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    lastMessage.isEmpty ? 'Start a conversation' : lastMessage,
                    style: TextStyle(color: isUnread ? Colors.black87 : Colors.grey[700], fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isUnread)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  ),
              ],
            ),
          ],
        ),
        trailing: bookThumbnail.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(imageUrl: bookThumbnail, width: 40, height: 40, fit: BoxFit.cover, placeholder: (context, url) => Container(color: Colors.grey[200])),
              )
            : null,
      ),
    );
  }
}
