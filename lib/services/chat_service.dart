import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'pocketbase_service.dart';
import 'auth_service.dart';
import 'transaction_service.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final PocketBase _pb = PocketBaseService.instance.pb;

  Future<ResultList<RecordModel>> getChats({int page = 1, int perPage = 20}) {
    return _pb.collection('chats').getList(
      page: page,
      perPage: perPage,
      sort: '-updated',
      expand: 'buyer,seller,book',
    );
  }

  Future<ResultList<RecordModel>> getMyChats() {
    return getChats();
  }

  Future<ResultList<RecordModel>> getMessages(String chatId, {int page = 1, int perPage = 50}) {
    return _pb.collection('messages').getList(
      page: page,
      perPage: perPage,
      filter: 'chat = "$chatId"',
      sort: '-created',
    );
  }

  Future<void> markAsRead(String chatId) async {
    final userId = AuthService().currentUser?.id;
    if (userId == null) return;

    try {
      // Find unread messages where I am the recipient
      final unread = await _pb.collection('messages').getList(
        page: 1,
        perPage: 50,
        filter: 'chat = "$chatId" && receiver = "$userId" && is_read = false',
      );

      for (final msg in unread.items) {
        await _pb.collection('messages').update(msg.id, body: {
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        });
      }

      // Reset unread count for me in chat record
      final chat = await _pb.collection('chats').getOne(chatId);
      final isBuyer = chat.getStringValue('buyer') == userId;
      if (isBuyer) {
        // Unread count logic might be more complex if tracked per user, 
        // but for now we follow the schema's unread_count.
        await _pb.collection('chats').update(chatId, body: {'unread_count': 0});
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Future<void> sendMessage(
    String chatId, {
    String? content,
    List<dynamic>? files,
    Map<String, dynamic>? offer,
  }) async {
    final userId = AuthService().currentUser?.id;
    if (userId == null) throw 'User not logged in';

    try {
      final chat = await _pb.collection('chats').getOne(chatId);
      final buyerId = chat.getStringValue('buyer');
      final sellerId = chat.getStringValue('seller');
      final receiverId = userId == buyerId ? sellerId : buyerId;

      final body = <String, dynamic>{
        'chat': chatId,
        'sender': userId,
        'receiver': receiverId,
        'content': content ?? '',
        'is_read': false,
      };

      if (offer != null) {
        body['type'] = 'offer';
        body['offer_amount'] = offer['amount'];
      } else {
        body['type'] = files != null && files.isNotEmpty ? 'image' : 'text';
      }

      final List<http.MultipartFile> multipartFiles = [];
      if (files != null) {
        for (final file in files) {
          if (file is http.MultipartFile) {
            multipartFiles.add(file);
          }
        }
      }

      await _pb.collection('messages').create(
        body: body,
        files: multipartFiles,
      );

      // Update chat meta
      await _pb.collection('chats').update(chatId, body: {
        'last_message': content ?? (offer != null ? 'Offer: ₹${offer['amount']}' : 'Image'),
        'last_message_at': DateTime.now().toIso8601String(),
        'last_sender': userId,
        // Increment unread_count logic would be handled by a collection hook on server usually,
        // but adding here for immediate local visibility if needed.
      });
    } catch (e) {
      throw 'Failed to send message: $e';
    }
  }

  void subscribeToMessages(String chatId, Function(RecordModel) onMessage) {
    _pb.collection('messages').subscribe('*', (e) {
      if (e.action == 'create' && e.record?.getStringValue('chat') == chatId) {
        onMessage(e.record!);
      }
    });
  }

  void unsubscribeFromMessages(String chatId) {
    _pb.collection('messages').unsubscribe('*');
  }

  Future<void> respondToOffer(String messageId, String action, {double? agreedPrice}) async {
    try {
      // action: "accepted", "declined"
      final msg = await _pb.collection('messages').update(messageId, body: {
        'offer_status': action,
      });

      if (action == 'accepted') {
        final chatId = msg.getStringValue('chat');
        final chat = await _pb.collection('chats').getOne(chatId, expand: 'book');
        
        // Update chat with agreed price
        await _pb.collection('chats').update(chatId, body: {
          'offer_status': 'accepted',
          'agreed_price': agreedPrice ?? msg.getDoubleValue('offer_amount'),
        });

        final bookId = chat.getStringValue('book');
        final buyerId = chat.getStringValue('buyer');
        final sellerId = chat.getStringValue('seller');
        final finalPrice = agreedPrice ?? msg.getDoubleValue('offer_amount');

        // Create transaction
        await TransactionService().initiateTransaction(
          chatId: chatId,
          bookId: bookId,
          buyerId: buyerId,
          sellerId: sellerId,
          amount: finalPrice.toInt(),
        );
      }
    } catch (e) {
      throw 'Failed to respond to offer: $e';
    }
  }

  Future<RecordModel?> getOrCreateChat(String bookId, String sellerId) async {
    final buyerId = AuthService().currentUser?.id;
    if (buyerId == null) throw 'User not logged in';
    if (buyerId == sellerId) throw 'You cannot chat with yourself';

    try {
      // 1. Check for existing chat between these users for this specific book
      final result = await _pb.collection('chats').getList(
        page: 1,
        perPage: 1,
        filter: 'book = "$bookId" && buyer = "$buyerId" && seller = "$sellerId"',
      );

      if (result.items.isNotEmpty) {
        return result.items.first;
      }

      // 2. Create new chat if not found
      final data = {
        'book': bookId,
        'buyer': buyerId,
        'seller': sellerId,
        'last_message': 'Chat started',
      };
      
      return await _pb.collection('chats').create(body: data);
    } catch (e) {
      throw 'Failed to get or create chat: $e';
    }
  }

  Future<void> blockUser(String userId) async {
    final myId = AuthService().currentUser?.id;
    if (myId == null) return;

    try {
      await _pb.collection('blocked_users').create(body: {
        'blocker': myId,
        'blocked': userId,
      });
    } catch (e) {
      throw 'Failed to block user: $e';
    }
  }
}
