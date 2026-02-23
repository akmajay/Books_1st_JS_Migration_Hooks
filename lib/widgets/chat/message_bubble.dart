import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../../services/pocketbase_service.dart';

class MessageBubble extends StatelessWidget {
  final RecordModel message;
  final Function(String response, int amount)? onOfferResponse;

  const MessageBubble({
    super.key,
    required this.message,
    this.onOfferResponse,
  });

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.id;
    final isMe = message.get<String>('sender') == userId;
    final type = message.get<String>('type');
    final content = message.get<String>('content');
    final created = message.get<String>('created');
    final isRead = message.get<bool>('is_read');

    if (type == 'system') {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
          child: Text(content, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (type == 'offer')
            _buildOfferBubble(context, isMe, isRead)
          else if (type == 'photo')
            _buildPhotoBubble(context, isMe, isRead)
          else
            _buildTextBubble(context, isMe, content, isRead),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
            child: Text(
              DateFormat('h:mm a').format(DateTime.parse(created).toLocal()),
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBubble(BuildContext context, bool isMe, String content, bool isRead) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
          bottomRight: isMe ? Radius.zero : const Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(content, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
          ),
          if (isMe)
            Positioned(
              bottom: -2,
              right: -4,
              child: Icon(
                isRead ? Icons.done_all : Icons.done,
                size: 14,
                color: isRead ? Colors.white : Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoBubble(BuildContext context, bool isMe, bool isRead) {
    final photos = message.get<List<dynamic>>('photos');
    if (photos.isEmpty) return const SizedBox.shrink();
    
    final photoUrl = PocketBaseService.instance.getFileUrl(message, photos.first);

    return InkWell(
      onTap: () => _viewFullScreenPhoto(context, photoUrl),
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(imageUrl: photoUrl, placeholder: (context, url) => Container(color: Colors.grey[100], height: 200, width: 200)),
            ),
            if (isMe)
              Positioned(
                bottom: 4,
                right: 4,
                child: Icon(
                  isRead ? Icons.done_all : Icons.done,
                  size: 16,
                  color: isRead ? Colors.blue : Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferBubble(BuildContext context, bool isMe, bool isRead) {
    final amount = message.get<int>('offer_amount');
    
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withAlpha(50)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          const Icon(Icons.sell_outlined, color: Colors.blue, size: 32),
          const SizedBox(height: 8),
          const Text('Offered Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
          Text('₹$amount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
          if (!isMe && onOfferResponse != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onOfferResponse!('decline', amount),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onOfferResponse!('accept', amount),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
          if (isMe) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(isRead ? 'Read' : 'Sent', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(width: 4),
                Icon(isRead ? Icons.done_all : Icons.done, size: 12, color: isRead ? Colors.blue : Colors.grey),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _viewFullScreenPhoto(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain)),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}
